import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../shared/widgets/cards/glass_card.dart';
import '../../../../../shared/widgets/common/service_icon.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../halls/data/models/hall_model.dart';
import '../../data/wedding_services.dart';

class FeaturedHalls extends StatelessWidget {
  const FeaturedHalls({
    super.key,
    required this.halls,
    required this.savedIds,
    required this.onToggleSaved,
    required this.onSelected,
    this.onBook,
    this.distances = const {},
  });
  final List<HallModel> halls;
  final Set<int> savedIds;
  final ValueChanged<HallModel> onToggleSaved;
  final ValueChanged<HallModel> onSelected;
  final ValueChanged<HallModel>? onBook;
  final Map<int, double> distances;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final hall in halls)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _VenueCard(
              hall: hall,
              saved: savedIds.contains(hall.id),
              onToggleSaved: () => onToggleSaved(hall),
              onSelected: () => onSelected(hall),
              onBook: onBook == null ? null : () => onBook!(hall),
              distance: distances[hall.id],
            ),
          ),
      ],
    );
  }
}

class _VenueCard extends StatelessWidget {
  const _VenueCard({
    required this.hall,
    required this.saved,
    required this.onToggleSaved,
    required this.onSelected,
    this.onBook,
    this.distance,
  });
  final HallModel hall;
  final bool saved;
  final VoidCallback onToggleSaved;
  final VoidCallback onSelected;
  final VoidCallback? onBook;
  final double? distance;

  @override
  Widget build(BuildContext context) {
    final service = weddingServices
        .where((service) => hall.serviceIds.contains(service.id))
        .firstOrNull;
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSelected,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ServiceIcon(
                      icon: service?.icon ?? Icons.other_houses_outlined,
                      color: service?.color ?? AppColors.primary,
                      size: 56,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hall.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            hall.city,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              Text(
                                hall.price > 0
                                    ? '₹${NumberFormat.decimalPattern('en_IN').format(hall.price)}'
                                    : 'Price on request',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              if (hall.capacity > 0)
                                Text(
                                  '${hall.capacity} guests',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              if (distance != null)
                                Text(
                                  '${distance!.toStringAsFixed(1)} km away',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.success,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      key: Key('save-venue-${hall.id}'),
                      tooltip: saved
                          ? 'Remove ${hall.name} from saved'
                          : 'Save ${hall.name}',
                      onPressed: onToggleSaved,
                      icon: Icon(
                        saved
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                      ),
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      hall.isSample ? 'SAMPLE LISTING' : 'LOCAL LISTING',
                      style: const TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.2,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (onBook != null)
                      TextButton.icon(
                        key: Key('request-listing-${hall.id}'),
                        onPressed: onBook,
                        icon: const Icon(
                          Icons.calendar_month_outlined,
                          size: 16,
                        ),
                        label: const Text(
                          'Request booking',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
