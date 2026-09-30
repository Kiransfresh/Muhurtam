import 'package:flutter/material.dart';
import '../../../../../shared/widgets/common/service_icon.dart';
import '../../../../../theme/app_colors.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, required this.onNotifications});
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const ServiceIcon(icon: Icons.favorite_rounded, size: 44),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Muhurtham',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
              Text(
                'WEDDINGS, MADE BEAUTIFUL',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Notifications',
          onPressed: onNotifications,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.7),
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: Colors.white),
          ),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }
}
