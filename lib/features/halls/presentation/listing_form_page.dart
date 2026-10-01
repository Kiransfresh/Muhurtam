import 'package:flutter/material.dart';
import '../../../shared/widgets/cards/glass_card.dart';
import '../../../shared/data/local_catalog.dart';
import '../../../shared/widgets/common/pink_glass_background.dart';
import '../../../theme/app_colors.dart';
import '../../customer/home/data/wedding_services.dart';
import '../data/models/hall_model.dart';
import '../data/nearby_location.dart';

class ListingFormPage extends StatefulWidget {
  const ListingFormPage({
    super.key,
    required this.onSave,
    required this.locationSource,
  });
  final Future<void> Function(HallModel) onSave;
  final LocationSource locationSource;
  @override
  State<ListingFormPage> createState() => _ListingFormPageState();
}

class _ListingFormPageState extends State<ListingFormPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  final _capacity = TextEditingController();
  final _price = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  final Set<String> _services = {'venues'};
  bool _saving = false;
  bool _locating = false;
  String? _error;

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  Future<void> _useLocation() async {
    setState(() {
      _locating = true;
      _error = null;
    });
    try {
      final location = await widget.locationSource.currentLocation();
      if (!mounted) return;
      _latitude.text = location.latitude.toStringAsFixed(6);
      _longitude.text = location.longitude.toStringAsFixed(6);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is LocationException
              ? error.message
              : 'Could not get location. Enter coordinates manually.',
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_services.isEmpty) {
      setState(() => _error = 'Select at least one service.');
      return;
    }
    if (_latitude.text.trim().isEmpty != _longitude.text.trim().isEmpty) {
      setState(
        () =>
            _error = 'Enter both latitude and longitude, or leave both empty.',
      );
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(
        HallModel(
          id: DateTime.now().microsecondsSinceEpoch,
          name: _name.text.trim(),
          city: _city.text.trim(),
          address: _address.text.trim(),
          image: '',
          rating: 0,
          capacity: _services.contains('venues')
              ? int.tryParse(_capacity.text.trim()) ?? 0
              : 0,
          price: double.tryParse(_price.text.trim()) ?? 0,
          featured: false,
          latitude: double.tryParse(_latitude.text.trim()),
          longitude: double.tryParse(_longitude.text.trim()),
          serviceIds: _services.toList(),
          isSample: false,
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error is CatalogException
              ? error.message
              : 'Could not save locally. Please try again.';
          _saving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _city,
      _address,
      _capacity,
      _price,
      _latitude,
      _longitude,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a venue or vendor')),
      body: PinkGlassBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'A beautiful find, worth keeping.',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Add a listing to your local catalog. Listings stay on this device.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _field(
                        'listing-name',
                        'Venue or business name',
                        _name,
                        validator: _required,
                      ),
                      _field(
                        'listing-city',
                        'City',
                        _city,
                        validator: _required,
                      ),
                      _field(
                        'listing-address',
                        'Address or locality',
                        _address,
                        validator: _required,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Services offered',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: weddingServices
                            .map(
                              (service) => FilterChip(
                                label: Text(service.title),
                                selected: _services.contains(service.id),
                                onSelected: _saving
                                    ? null
                                    : (selected) => setState(() {
                                        if (selected) {
                                          _services.add(service.id);
                                        } else {
                                          _services.remove(service.id);
                                        }
                                      }),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                      if (_services.contains('venues'))
                        _field(
                          'listing-capacity',
                          'Guest capacity',
                          _capacity,
                          keyboard: TextInputType.number,
                          validator: (value) =>
                              int.tryParse(value ?? '') != null &&
                                  int.parse(value!) > 0
                              ? null
                              : 'Enter a positive whole number',
                        ),
                      _field(
                        'listing-price',
                        'Indicative price in ₹ (optional)',
                        _price,
                        keyboard: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }
                          final number = double.tryParse(value);
                          return number != null &&
                                  number.isFinite &&
                                  number >= 0
                              ? null
                              : 'Enter a valid price of zero or more';
                        },
                      ),
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Make this listing discoverable nearby',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Coordinates are optional. Use your location only when you are at the venue or business.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _field(
                              'listing-latitude',
                              'Latitude (−90 to 90)',
                              _latitude,
                              keyboard: const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              validator: (value) => _coordinate(value, 90),
                            ),
                            _field(
                              'listing-longitude',
                              'Longitude (−180 to 180)',
                              _longitude,
                              keyboard: const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              validator: (value) => _coordinate(value, 180),
                            ),
                            OutlinedButton.icon(
                              onPressed: _locating || _saving
                                  ? null
                                  : _useLocation,
                              icon: const Icon(Icons.my_location_rounded),
                              label: Text(
                                _locating
                                    ? 'Getting location…'
                                    : 'Use my location',
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          key: const Key('listing-error'),
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          key: const Key('save-listing'),
                          onPressed: _saving || _locating ? null : _save,
                          icon: const Icon(Icons.add_business_outlined),
                          label: Text(_saving ? 'Saving…' : 'Save listing'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _coordinate(String? value, double limit) {
    if (value == null || value.trim().isEmpty) return null;
    final number = double.tryParse(value);
    return number != null && number.isFinite && number.abs() <= limit
        ? null
        : 'Enter a coordinate between −$limit and $limit';
  }

  Widget _field(
    String key,
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        key: Key(key),
        controller: controller,
        validator: validator,
        enabled: !_saving,
        keyboardType: keyboard,
        textCapitalization: keyboard == null
            ? TextCapitalization.words
            : TextCapitalization.none,
        decoration: InputDecoration(labelText: label, errorMaxLines: 3),
      ),
    );
  }
}
