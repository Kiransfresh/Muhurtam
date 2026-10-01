import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../shared/widgets/cards/glass_card.dart';
import '../../../../../shared/data/local_catalog.dart';
import '../../../../bookings/presentation/booking_form_page.dart';
import '../../../../bookings/presentation/bookings_list.dart';
import '../../../../halls/data/nearby_location.dart';
import '../../../../halls/presentation/listing_form_page.dart';
import '../widgets/nearby_filter_bar.dart';
import '../../../../../shared/widgets/cards/hero_banner.dart';
import '../../../../../shared/widgets/common/pink_glass_background.dart';
import '../../../../../shared/widgets/common/service_icon.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../halls/data/dummy_halls.dart';
import '../../../../halls/data/models/hall_model.dart';
import '../../data/wedding_services.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/category_grid.dart';
import '../widgets/featured_halls.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/search_bar_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.locationSource});
  final LocationSource? locationSource;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _search = TextEditingController();
  final Set<int> _savedIds = {};
  final Set<String> _plannedIds = {};
  final Set<String> _completedIds = {};
  SharedPreferences? _preferences;
  Future<void> _pendingSave = Future.value();
  bool _loading = true;
  int _tab = 0;
  String _query = '';
  LocalCatalog? _catalog;
  LocationPoint? _location;
  bool _nearby = false;
  bool _locating = false;
  bool _catalogBusy = false;
  String? _city;
  String? _locationMessage;
  double _radius = 25;
  List<HallModel> get _listings => _catalog?.listings ?? dummyHalls;
  LocationSource get _locationSource =>
      widget.locationSource ?? DeviceLocationSource();

  @override
  void initState() {
    super.initState();
    _restorePreferences();
  }

  Future<void> _restorePreferences() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final catalog = LocalCatalog(preferences)..load();
      if (!mounted) return;
      final knownIds = weddingServices.map((service) => service.id).toSet();
      setState(() {
        _preferences = preferences;
        _catalog = catalog;
        _savedIds.addAll(
          (preferences.getStringList('saved_venues') ?? [])
              .map(int.tryParse)
              .whereType<int>()
              .where((id) => catalog.listings.any((hall) => hall.id == id)),
        );
        _plannedIds.addAll(
          (preferences.getStringList('planned_services') ?? []).where(
            knownIds.contains,
          ),
        );
        _completedIds.addAll(
          (preferences.getStringList('completed_services') ?? []).where(
            _plannedIds.contains,
          ),
        );
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage(
        'Local storage is unavailable. Changes will last for this session.',
      );
    }
  }

  void _persist() {
    final preferences = _preferences;
    if (preferences == null) return;
    final saved = _savedIds.map((id) => id.toString()).toList();
    final planned = _plannedIds.toList();
    final completed = _completedIds.toList();
    // Serialize writes so rapid toggles cannot restore an older selection.
    _pendingSave = _pendingSave
        .then((_) async {
          final results = await Future.wait([
            preferences.setStringList('saved_venues', saved),
            preferences.setStringList('planned_services', planned),
            preferences.setStringList('completed_services', completed),
          ]);
          if (results.any((success) => !success)) {
            throw StateError('Storage write failed');
          }
        })
        .catchError((Object _) {
          if (mounted) {
            _showMessage(
              'Could not save changes on this device. Please try again.',
            );
          }
        });
  }

  Future<void> _openListing() async {
    final catalog = _catalog;
    if (catalog == null) {
      _showMessage('Local storage is not ready. Please reopen the app.');
      return;
    }
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ListingFormPage(
          locationSource: _locationSource,
          onSave: catalog.addListing,
        ),
      ),
    );
    if (saved == true && mounted) {
      setState(() {
        _nearby = false;
        _city = null;
        _locationMessage = null;
      });
      _changeTab(1);
      _showMessage('Listing saved to your local catalog');
    }
  }

  Future<void> _openBooking({
    String serviceId = 'venues',
    HallModel? listing,
  }) async {
    final catalog = _catalog;
    if (catalog == null) {
      _showMessage('Local storage is not ready. Please reopen the app.');
      return;
    }
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BookingFormPage(
          listings: _listings,
          serviceId: serviceId,
          listing: listing,
          onSave: catalog.addRequest,
        ),
      ),
    );
    if (saved == true && mounted) {
      _changeTab(3);
      _showMessage(
        'Request saved locally. It has not been sent to the provider.',
      );
    }
  }

  Future<void> _cancelRequest(String id) async {
    if (_catalogBusy || _catalog == null) return;
    setState(() => _catalogBusy = true);
    try {
      await _catalog!.cancelRequest(id);
      if (mounted) setState(() {});
    } catch (error) {
      if (mounted) _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _catalogBusy = false);
    }
  }

  Future<void> _useLocation() async {
    if (_locating) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _locating = true;
      _locationMessage = null;
    });
    try {
      final location = await _locationSource.currentLocation();
      if (!mounted) return;
      setState(() {
        _location = location;
        _nearby = true;
        _city = null;
        _locationMessage =
            'Approximate straight-line distances from saved coordinates. Sample venues are excluded.';
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _nearby = false;
          _locationMessage = error is LocationException
              ? error.message
              : 'Location is unavailable. Choose a city instead.';
        });
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _changeTab(int tab) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _tab = tab;
      _query = '';
      _search.clear();
    });
  }

  void _toggleSaved(HallModel hall) {
    setState(() {
      if (!_savedIds.add(hall.id)) _savedIds.remove(hall.id);
    });
    _persist();
  }

  void _addToPlan(WeddingService service) {
    setState(() => _plannedIds.add(service.id));
    _persist();
    _showMessage('${service.title} added to your plan');
  }

  void _showService(WeddingService service) {
    FocusManager.instance.primaryFocus?.unfocus();
    final alreadyPlanned = _plannedIds.contains(service.id);
    _showSheet(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ServiceIcon(icon: service.icon, color: service.color, size: 64),
          const SizedBox(height: 20),
          Text(service.title, style: _heading),
          const SizedBox(height: 10),
          Text(service.description, style: _body),
          const SizedBox(height: 24),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'A little planning tip',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(service.tip, style: _body),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _openBooking(serviceId: service.id);
              },
              icon: const Icon(Icons.calendar_month_outlined),
              label: const Text('Request this service'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                if (alreadyPlanned) {
                  _changeTab(4);
                } else {
                  _addToPlan(service);
                }
              },
              icon: Icon(
                alreadyPlanned ? Icons.checklist_rounded : Icons.add_rounded,
              ),
              label: Text(alreadyPlanned ? 'View my plan' : 'Add to my plan'),
            ),
          ),
          if (service.id == 'venues')
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _changeTab(1);
                },
                child: const Text('Explore sample venues'),
              ),
            ),
        ],
      ),
    );
  }

  void _showVenue(HallModel hall) {
    final service = weddingServices
        .where((service) => hall.serviceIds.contains(service.id))
        .firstOrNull;
    _showSheet(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ServiceIcon(
            icon: service?.icon ?? Icons.other_houses_outlined,
            color: service?.color ?? AppColors.primary,
            size: 64,
          ),
          const SizedBox(height: 20),
          Text(hall.name, style: _heading),
          const SizedBox(height: 10),
          Text(
            hall.capacity > 0
                ? '${hall.city} · Up to ${hall.capacity} guests'
                : hall.city,
            style: _body,
          ),
          const SizedBox(height: 20),
          GlassCard(
            child: Row(
              children: [
                const Icon(Icons.payments_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hall.price > 0
                        ? 'Indicative price\n₹${NumberFormat.decimalPattern('en_IN').format(hall.price)}'
                        : 'Price on request',
                    style: const TextStyle(
                      height: 1.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hall.isSample
                ? 'Sample listing. Prices and availability are illustrative.'
                : hall.address,
            style: _body,
          ),
          const SizedBox(height: 16),
          const Text(
            'Services you can request',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: weddingServices
                .where((service) => hall.serviceIds.contains(service.id))
                .map(
                  (service) => ActionChip(
                    avatar: Icon(service.icon, size: 16, color: service.color),
                    label: Text(service.title),
                    onPressed: () {
                      Navigator.pop(context);
                      _openBooking(serviceId: service.id, listing: hall);
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: Key('book-venue-${hall.id}'),
              onPressed: () {
                Navigator.pop(context);
                _openBooking(serviceId: hall.serviceIds.first, listing: hall);
              },
              icon: const Icon(Icons.calendar_month_outlined),
              label: const Text('Request booking'),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Requests are saved locally, not sent. Availability is not confirmed.',
            style: _body,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                _toggleSaved(hall);
                Navigator.pop(context);
              },
              icon: Icon(
                _savedIds.contains(hall.id)
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
              ),
              label: Text(
                _savedIds.contains(hall.id)
                    ? 'Remove from saved'
                    : 'Save venue',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllServices() {
    _showSheet(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Everything for your big day', style: _heading),
          const SizedBox(height: 20),
          CategoryGrid(
            services: weddingServices,
            plannedIds: _plannedIds,
            onSelected: (service) {
              Navigator.pop(context);
              _showService(service);
            },
          ),
        ],
      ),
    );
  }

  void _showSheet(Widget content) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            8,
            24,
            28 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: content,
        ),
      ),
    );
  }

  static const _heading = TextStyle(
    fontSize: 23,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
  );
  static const _body = TextStyle(
    fontSize: 14,
    height: 1.6,
    color: AppColors.textSecondary,
  );

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).appBarTheme.systemOverlayStyle!,
      child: Scaffold(
        bottomNavigationBar: SafeArea(
          top: false,
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: BottomNavbar(currentIndex: _tab, onTap: _changeTab),
              ),
            ),
          ),
        ),
        body: PinkGlassBackground(
          child: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                      child: HomeAppBar(
                        onNotifications: () => _showSheet(
                          const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ServiceIcon(
                                icon: Icons.notifications_none_rounded,
                                size: 64,
                              ),
                              SizedBox(height: 20),
                              Text('A quiet moment', style: _heading),
                              SizedBox(height: 10),
                              Text(
                                'No notifications yet. Start a plan and keep your '
                                'wedding ideas together here.',
                                textAlign: TextAlign.center,
                                style: _body,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _loading
                          ? const Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(
                              key: ValueKey('tab-$_tab'),
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                18,
                                20,
                                24,
                              ),
                              child: _buildTab(),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab() {
    switch (_tab) {
      case 1:
        return _discovery(explore: true);
      case 2:
        return _savedVenues();
      case 3:
        return BookingsList(
          requests: _catalog?.requests ?? [],
          onCreate: () => _openBooking(),
          onCancel: _cancelRequest,
          busy: _catalogBusy,
        );
      case 4:
        return _weddingPlan();
      default:
        return _discovery();
    }
  }

  Widget _discovery({bool explore = false}) {
    final services = weddingServices
        .where(
          (service) => '${service.title} ${service.description}'
              .toLowerCase()
              .contains(_query),
        )
        .toList();
    final halls = _listings
        .where(
          (hall) =>
              '${hall.name} ${hall.city} ${hall.address}'
                  .toLowerCase()
                  .contains(_query) &&
              (_city == null ||
                  hall.city.toLowerCase() == _city!.toLowerCase()),
        )
        .toList();
    final visibleHalls = _nearby && _location != null
        ? nearbyListings(halls, _location!, _radius)
        : halls;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          explore ? 'Find your perfect place.' : 'Let’s make it unforgettable.',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.7,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          explore
              ? 'Beautiful spaces for your favourite people.'
              : 'Your day. Your dreams. Every lovely detail.',
          style: _body,
        ),
        const SizedBox(height: 22),
        SearchBarWidget(
          controller: _search,
          hint: explore
              ? 'Search venues, vendors, or cities'
              : 'Search venues, services, or a city',
          onChanged: (value) =>
              setState(() => _query = value.trim().toLowerCase()),
        ),
        const SizedBox(height: 14),
        if (explore)
          NearbyFilterBar(
            cities: (_listings.map((hall) => hall.city).toSet().toList()
              ..sort()),
            city: _city,
            onCity: (city) => setState(() {
              _city = city;
              _nearby = false;
              _locationMessage = null;
            }),
            onLocation: _useLocation,
            nearby: _nearby,
            locating: _locating,
            radius: _radius,
            onRadius: (radius) => setState(() => _radius = radius),
            message: _locationMessage,
          ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            key: const Key('add-listing'),
            onPressed: _openListing,
            icon: const Icon(Icons.add_business_outlined, size: 18),
            label: const Text('Add a venue or vendor'),
          ),
        ),
        if (!explore && _query.isEmpty) ...[
          const SizedBox(height: 12),
          HeroBanner(onBook: () => _changeTab(1)),
        ],
        if (!explore && services.isNotEmpty) ...[
          const SizedBox(height: 26),
          _section(
            'Made for your big day',
            action: _query.isEmpty ? 'View all' : null,
            onAction: _showAllServices,
          ),
          const SizedBox(height: 14),
          CategoryGrid(
            services: services,
            plannedIds: _plannedIds,
            onSelected: _showService,
          ),
        ],
        if (visibleHalls.isNotEmpty) ...[
          const SizedBox(height: 26),
          _section(
            _nearby
                ? 'Near your location'
                : explore
                ? 'Venues & vendors'
                : 'Places to fall in love with',
            action: explore ? null : 'See all',
            onAction: () => _changeTab(1),
          ),
          const SizedBox(height: 5),
          const Text(
            'Your local listings and clearly marked sample venues.',
            style: _body,
          ),
          const SizedBox(height: 14),
          FeaturedHalls(
            halls: !explore && _query.isEmpty
                ? visibleHalls.take(2).toList()
                : visibleHalls,
            distances: _nearby && _location != null
                ? {
                    for (final hall in visibleHalls)
                      hall.id: distanceKm(_location!, hall),
                  }
                : const {},
            onBook: (hall) =>
                _openBooking(serviceId: hall.serviceIds.first, listing: hall),
            savedIds: _savedIds,
            onToggleSaved: _toggleSaved,
            onSelected: _showVenue,
          ),
        ],
        if (visibleHalls.isEmpty &&
            (explore || services.isEmpty || _nearby || _city != null)) ...[
          const SizedBox(height: 24),
          _empty(
            icon: Icons.search_off_rounded,
            title: _nearby
                ? 'No local listings nearby yet'
                : 'No matches just yet',
            message: _nearby
                ? 'Nearby search needs listings with coordinates. Increase the radius or add a venue at its location.'
                : 'Try another city, a venue name, or a wedding service.',
          ),
        ],
        if (!explore && _query.isEmpty) ...[
          const SizedBox(height: 16),
          GlassCard(
            child: Row(
              children: [
                const ServiceIcon(icon: Icons.checklist_rounded, size: 44),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'One little step at a time',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 5),
                      Text('Build a plan that feels like you.', style: _body),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Open my wedding plan',
                  onPressed: () => _changeTab(4),
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        const Center(
          child: Text(
            'A LITTLE MAGIC. A LIFETIME OF LOVE.',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _savedVenues() {
    final halls = _listings
        .where((hall) => _savedIds.contains(hall.id))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your lovely shortlist.', style: _heading),
        const SizedBox(height: 8),
        const Text('A home for the places you love.', style: _body),
        const SizedBox(height: 24),
        if (halls.isEmpty)
          _empty(
            icon: Icons.favorite_border_rounded,
            title: 'Love it? Save it.',
            message: 'Tap a heart on any venue to keep it here for later.',
            action: 'Explore venues',
            onAction: () => _changeTab(1),
          )
        else
          FeaturedHalls(
            halls: halls,
            savedIds: _savedIds,
            onToggleSaved: _toggleSaved,
            onSelected: _showVenue,
          ),
      ],
    );
  }

  Widget _weddingPlan() {
    final services = weddingServices
        .where((service) => _plannedIds.contains(service.id))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('A plan, made with love.', style: _heading),
        const SizedBox(height: 8),
        const Text('Little steps towards your biggest day.', style: _body),
        const SizedBox(height: 24),
        if (services.isEmpty)
          _empty(
            icon: Icons.checklist_rounded,
            title: 'Every beautiful day starts somewhere',
            message:
                'Choose a service and add it to your plan. Tick it off when you’re ready.',
            action: 'Add a wedding service',
            onAction: _showAllServices,
          )
        else ...[
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_completedIds.length} of ${services.length} details complete',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: _completedIds.length / services.length,
                    minHeight: 8,
                    backgroundColor: AppColors.blush,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          for (final service in services)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    Checkbox(
                      key: Key('complete-${service.id}'),
                      value: _completedIds.contains(service.id),
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _completedIds.add(service.id);
                          } else {
                            _completedIds.remove(service.id);
                          }
                        });
                        _persist();
                      },
                    ),
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            service.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              decoration: _completedIds.contains(service.id)
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: const Text(
                            'View planning tip',
                            style: TextStyle(fontSize: 12),
                          ),
                          onTap: () => _showService(service),
                        ),
                      ),
                    ),
                    IconButton(
                      key: Key('remove-plan-${service.id}'),
                      tooltip: 'Remove ${service.title} from plan',
                      onPressed: () {
                        setState(() {
                          _plannedIds.remove(service.id);
                          _completedIds.remove(service.id);
                        });
                        _persist();
                      },
                      icon: const Icon(Icons.close_rounded, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _showAllServices,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add a wedding service'),
          ),
        ],
        const SizedBox(height: 20),
        const Text(
          'Your shortlist and plan are saved on this device.',
          style: _body,
        ),
      ],
    );
  }

  Widget _section(String title, {String? action, VoidCallback? onAction}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 12),
            ),
            child: Text(action),
          ),
      ],
    );
  }

  Widget _empty({
    required IconData icon,
    required String title,
    required String message,
    String? action,
    VoidCallback? onAction,
  }) {
    return SizedBox(
      width: double.infinity,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            ServiceIcon(icon: icon, size: 64),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center, style: _body),
            if (action != null) ...[
              const SizedBox(height: 24),
              FilledButton(onPressed: onAction, child: Text(action)),
            ],
          ],
        ),
      ),
    );
  }
}
