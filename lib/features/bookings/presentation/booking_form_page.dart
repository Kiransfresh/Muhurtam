import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/cards/glass_card.dart';
import '../../../shared/data/local_catalog.dart';
import '../../../shared/widgets/common/pink_glass_background.dart';
import '../../../theme/app_colors.dart';
import '../../customer/home/data/wedding_services.dart';
import '../../halls/data/models/hall_model.dart';
import '../data/booking_request.dart';

class BookingFormPage extends StatefulWidget {
  const BookingFormPage({
    super.key,
    required this.listings,
    required this.onSave,
    this.serviceId = 'venues',
    this.listing,
  });
  final List<HallModel> listings;
  final Future<void> Function(BookingRequest) onSave;
  final String serviceId;
  final HallModel? listing;
  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final _form = GlobalKey<FormState>();
  final _provider = TextEditingController();
  final _customer = TextEditingController();
  final _contact = TextEditingController();
  final _guests = TextEditingController(text: '100');
  final _notes = TextEditingController();
  late String _serviceId;
  int? _listingId;
  DateTime? _date;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _serviceId = widget.serviceId;
    if (widget.listing?.serviceIds.contains(_serviceId) == true) {
      _listingId = widget.listing!.id;
      _provider.text = widget.listing!.name;
    }
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = await showDatePicker(
      context: context,
      initialDate: _date ?? today,
      firstDate: today,
      lastDate: DateTime(now.year + 5, 12, 31),
    );
    if (date != null && mounted) setState(() => _date = date);
  }

  Future<void> _save() async {
    final fieldsValid = _form.currentState!.validate();
    if (!fieldsValid || _date == null) {
      if (_date == null) setState(() => _error = 'Choose an event date.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final now = DateTime.now();
      await widget.onSave(
        BookingRequest(
          id: 'MR-${now.microsecondsSinceEpoch}',
          serviceId: _serviceId,
          venueId: _listingId,
          providerName: _provider.text.trim(),
          eventDate: _date!,
          guests: int.parse(_guests.text),
          customerName: _customer.text.trim(),
          contact: _contact.text.trim(),
          notes: _notes.text.trim(),
          createdAt: now,
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
      _provider,
      _customer,
      _contact,
      _guests,
      _notes,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providers = widget.listings
        .where((listing) => listing.serviceIds.contains(_serviceId))
        .toList();
    final selected = providers
        .where((listing) => listing.id == _listingId)
        .firstOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('Booking request')),
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
                        'Make room for your big day.',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const GlassCard(
                        child: Row(
                          children: [
                            Icon(
                              Icons.drafts_outlined,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Saved on this device, not sent to the provider. '
                                'This does not reserve a venue or confirm availability.',
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<String>(
                        key: const Key('booking-service'),
                        initialValue: _serviceId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Wedding service',
                        ),
                        items: weddingServices
                            .map(
                              (service) => DropdownMenuItem(
                                value: service.id,
                                child: Text(service.title),
                              ),
                            )
                            .toList(),
                        onChanged: _saving
                            ? null
                            : (value) => setState(() {
                                _serviceId = value!;
                                _listingId = null;
                                _provider.clear();
                              }),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        key: ValueKey('booking-provider-$_serviceId'),
                        initialValue: _listingId ?? 0,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Venue or provider',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: 0,
                            child: Text('Enter a provider name'),
                          ),
                          ...providers.map(
                            (listing) => DropdownMenuItem(
                              value: listing.id,
                              child: Text(
                                listing.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: _saving
                            ? null
                            : (value) => setState(() {
                                _listingId = value == 0 ? null : value;
                                _provider.text =
                                    providers
                                        .where((listing) => listing.id == value)
                                        .firstOrNull
                                        ?.name ??
                                    '';
                              }),
                      ),
                      const SizedBox(height: 16),
                      if (_listingId == null)
                        _field(
                          'booking-provider-name',
                          'Provider or venue name',
                          _provider,
                          validator: _required,
                        ),
                      if (selected?.isSample == true) ...[
                        const Text(
                          'Sample listing · this request is for planning only.',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      OutlinedButton.icon(
                        key: const Key('booking-date'),
                        onPressed: _saving ? null : _pickDate,
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: Text(
                          _date == null
                              ? 'Choose event date'
                              : DateFormat.yMMMd().format(_date!),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _field(
                        'booking-guests',
                        'Number of guests',
                        _guests,
                        keyboard: TextInputType.number,
                        validator: (value) {
                          final guests = int.tryParse(value ?? '');
                          if (guests == null || guests < 1) {
                            return 'Enter a positive whole number';
                          }
                          if (_serviceId == 'venues' &&
                              selected != null &&
                              selected.capacity > 0 &&
                              guests > selected.capacity) {
                            return 'This venue holds up to ${selected.capacity} guests';
                          }
                          return null;
                        },
                      ),
                      _field(
                        'booking-name',
                        'Your name',
                        _customer,
                        validator: _required,
                      ),
                      _field(
                        'booking-contact',
                        'Email or phone',
                        _contact,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter an email or phone number';
                          }
                          final text = value.trim();
                          final email = RegExp(
                            r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                          ).hasMatch(text);
                          final phone =
                              RegExp(r'^\+?[\d\s()\-]{7,}$').hasMatch(text) &&
                              text.replaceAll(RegExp(r'\D'), '').length >= 7;
                          return email || phone
                              ? null
                              : 'Enter a valid email or phone number';
                        },
                      ),
                      _field(
                        'booking-notes',
                        'Notes (optional)',
                        _notes,
                        lines: 3,
                      ),
                      if (_error != null) ...[
                        Text(
                          _error!,
                          key: const Key('booking-error'),
                          style: const TextStyle(color: AppColors.error),
                        ),
                        const SizedBox(height: 16),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          key: const Key('save-booking'),
                          onPressed: _saving ? null : _save,
                          icon: const Icon(Icons.bookmark_add_outlined),
                          label: Text(
                            _saving ? 'Saving…' : 'Save booking request',
                          ),
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

  Widget _field(
    String key,
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
    TextInputType? keyboard,
    int lines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        key: Key(key),
        controller: controller,
        validator: validator,
        enabled: !_saving,
        keyboardType: keyboard,
        maxLines: lines,
        decoration: InputDecoration(labelText: label, errorMaxLines: 3),
      ),
    );
  }
}
