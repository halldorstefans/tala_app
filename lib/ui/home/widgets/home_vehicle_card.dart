import 'package:flutter/material.dart';

import '../../core/widgets/app_image.dart';

class HomeVehicleCard extends StatelessWidget {
  final String title;
  final String? nickname;
  final String? registration;
  final VoidCallback? onTap;
  final String? imageUrl;

  const HomeVehicleCard({
    super.key,
    required this.title,
    this.nickname,
    this.registration,
    this.onTap,
    this.imageUrl,
  });

  bool _meaningful(String? v) => v != null && v.isNotEmpty && v != 'null';

  @override
  Widget build(BuildContext context) {
    final String subtitle;
    if (_meaningful(nickname) && _meaningful(registration)) {
      subtitle = '$nickname - Reg: $registration';
    } else if (_meaningful(nickname)) {
      subtitle = nickname!;
    } else if (_meaningful(registration)) {
      subtitle = 'Reg: $registration';
    } else {
      subtitle = '';
    }

    final cardColor = Theme.of(context).cardColor;
    final borderColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1);
    final shadow = [
      BoxShadow(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
        blurRadius: 3,
        offset: const Offset(0, 1),
      ),
    ];

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(2),
          boxShadow: shadow,
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Container(
                width: 96,
                height: 72,
                color: Colors.grey.shade200,
                child: AppImage(
                  path: imageUrl,
                  fit: BoxFit.cover,
                  placeholderIcon: Icons.directions_car,
                  placeholderColor: Colors.black26,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
