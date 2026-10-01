import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/cards/glass_card.dart';
import '../../../shared/widgets/common/service_icon.dart';
import '../../../theme/app_colors.dart';
import '../../customer/home/data/wedding_services.dart';
import '../data/booking_request.dart';

class BookingsList extends StatelessWidget {
  const BookingsList({
    super.key,
    required this.requests,
    required this.onCreate,
    required this.onCancel,
    this.busy = false,
  });
  final List<BookingRequest> requests;
  final VoidCallback onCreate;
  final ValueChanged<String> onCancel;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your day, taking shape.',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Booking requests saved on this device. No requests have been sent to providers.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          key: const Key('new-booking'),
          onPressed: onCreate,
          icon: const Icon(Icons.add_rounded),
          label: const Text('New booking request'),
        ),
        const SizedBox(height: 24),
        if (requests.isEmpty)
          const GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ServiceIcon(icon: Icons.calendar_month_outlined, size: 60),
                SizedBox(height: 20),
                Text(
                  'A date worth dreaming about.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 10),
                Text(
                  'Choose a venue or any wedding service, then save your event details here.',
                  style: TextStyle(color: AppColors.textSecondary, height: 1.6),
                ),
              ],
            ),
          ),
        ...requests.reversed.map((request) {
          final service = weddingServices
              .where((service) => service.id == request.serviceId)
              .firstOrNull;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ServiceIcon(
                        icon: service?.icon ?? Icons.calendar_month_outlined,
                        color: service?.color ?? AppColors.primary,
                        size: 44,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.providerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              service?.title ?? request.serviceId,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${DateFormat.yMMMd().format(request.eventDate)} · ${request.guests} guests',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    request.cancelled
                        ? 'Cancelled locally'
                        : 'Saved locally · Not sent',
                    key: Key('booking-status-${request.id}'),
                    style: TextStyle(
                      color: request.cancelled
                          ? AppColors.textSecondary
                          : AppColors.primary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'For ${request.customerName} · ${request.contact}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (request.notes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        request.notes,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  if (!request.cancelled)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextButton.icon(
                        key: Key('cancel-booking-${request.id}'),
                        onPressed: busy ? null : () => onCancel(request.id),
                        icon: const Icon(Icons.close_rounded, size: 16),
                        label: const Text('Cancel local request'),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
