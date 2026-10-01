import 'package:flutter/material.dart';
import '../../../../../shared/widgets/cards/glass_card.dart';
import '../../../../../theme/app_colors.dart';

class NearbyFilterBar extends StatelessWidget {
  const NearbyFilterBar({
    super.key,
    required this.cities,
    required this.city,
    required this.onCity,
    required this.onLocation,
    required this.nearby,
    required this.locating,
    required this.radius,
    required this.onRadius,
    this.message,
  });
  final List<String> cities;
  final String? city;
  final ValueChanged<String?> onCity;
  final VoidCallback onLocation;
  final bool nearby;
  final bool locating;
  final double radius;
  final ValueChanged<double> onRadius;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('city-filter-${city ?? 'all'}'),
            initialValue: city ?? '',
            isExpanded: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.location_on_outlined),
              labelText: 'Browse a city',
              contentPadding: EdgeInsets.all(12),
            ),
            items: [
              const DropdownMenuItem(value: '', child: Text('All cities')),
              ...cities.map(
                (city) => DropdownMenuItem(value: city, child: Text(city)),
              ),
            ],
            onChanged: (value) => onCity(value == '' ? null : value),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton.icon(
                key: const Key('use-location'),
                onPressed: locating ? null : onLocation,
                icon: Icon(
                  nearby ? Icons.near_me_rounded : Icons.my_location_outlined,
                  size: 18,
                ),
                label: Text(
                  locating
                      ? 'Finding you…'
                      : nearby
                      ? 'Location active'
                      : 'Use my location',
                ),
              ),
              if (nearby)
                DropdownButton<double>(
                  key: const Key('nearby-radius'),
                  value: radius,
                  underline: const SizedBox.shrink(),
                  items: [25.0, 50.0, 100.0]
                      .map(
                        (radius) => DropdownMenuItem(
                          value: radius,
                          child: Text(
                            'Within ${radius.toInt()} km',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => onRadius(value!),
                ),
            ],
          ),
          if (message != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                message!,
                key: const Key('location-message'),
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
