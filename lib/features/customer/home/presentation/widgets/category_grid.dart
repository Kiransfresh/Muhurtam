import 'package:flutter/material.dart';
import '../../../../../shared/widgets/cards/glass_card.dart';
import '../../../../../shared/widgets/common/service_icon.dart';
import '../../../../../theme/app_colors.dart';
import '../../data/wedding_services.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    super.key,
    required this.services,
    required this.onSelected,
    this.plannedIds = const {},
  });

  final List<WeddingService> services;
  final ValueChanged<WeddingService> onSelected;
  final Set<String> plannedIds;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 8
            : constraints.maxWidth >= 340
            ? 4
            : 3;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: services.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent:
                118 * MediaQuery.textScalerOf(context).scale(1).clamp(1, 2),
          ),
          itemBuilder: (context, index) {
            final service = services[index];
            return Semantics(
              button: true,
              label: 'Explore ${service.title}',
              child: GlassCard(
                padding: EdgeInsets.zero,
                radius: 22,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onSelected(service),
                    borderRadius: BorderRadius.circular(22),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 12,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ServiceIcon(
                                icon: service.icon,
                                color: service.color,
                                size: 46,
                              ),
                              if (plannedIds.contains(service.id))
                                const Positioned(
                                  right: -4,
                                  bottom: -3,
                                  child: Icon(
                                    Icons.check_circle_rounded,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            service.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
