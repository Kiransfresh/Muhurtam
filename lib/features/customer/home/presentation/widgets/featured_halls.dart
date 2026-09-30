import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../shared/widgets/cards/glass_card.dart';
import '../../../../../shared/widgets/common/service_icon.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../halls/data/models/hall_model.dart';

class FeaturedHalls extends StatelessWidget {
  const FeaturedHalls({
    super.key,
    required this.halls,
    required this.savedIds,
    required this.onToggleSaved,
    required this.onSelected,
  });

  final List<HallModel> halls;
  final Set<int> savedIds;
  final ValueChanged<HallModel> onToggleSaved;
  final ValueChanged<HallModel> onSelected;

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
  });
  final HallModel hall;
  final bool saved;
  final VoidCallback onToggleSaved;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSelected,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const ServiceIcon(icon: Icons.other_houses_outlined, size: 60),
                const SizedBox(width: 14),
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
                            '₹${NumberFormat.decimalPattern('en_IN').format(hall.price)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            '${hall.capacity} guests',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
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
          ),
        ),
      ),
    );
  }
}
