import 'package:flutter/material.dart';
import 'package:tala_app/data/services/tala_api/api_config.dart';

class HomeVehicleCard extends StatelessWidget {
  final String title;
  final String? nickname;
  final String? registration;
  final String? lastWork;
  final VoidCallback? onTap;
  final String? imageUrl;

  const HomeVehicleCard({
    super.key,
    required this.title,
    this.nickname,
    this.registration,
    this.lastWork,
    this.onTap,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    String subtitle = '';

    if ((nickname != null && nickname!.isNotEmpty && nickname != 'null') &&
        (registration != null &&
            registration!.isNotEmpty &&
            registration != 'null')) {
      subtitle = [nickname, 'Reg: $registration'].join(' - ');
    } else if (nickname != null && nickname!.isNotEmpty && nickname != 'null') {
      subtitle = nickname!;
    } else if (registration != null &&
        registration!.isNotEmpty &&
        registration != 'null') {
      subtitle = 'Reg: $registration';
    }
    // Validate imageUrl to avoid passing invalid strings like "null" to Image.network
    final bool hasValidImage =
        imageUrl != null &&
        imageUrl!.trim().isNotEmpty &&
        imageUrl!.contains('null') == false &&
        imageUrl!.toLowerCase() != 'null' &&
        imageUrl!.startsWith('/uploads/');

    final cardColor = Theme.of(context).cardColor; // Aged paper tint
    final borderColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.1); // Subtle border color
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
            // Photo area
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Container(
                width: 96,
                height: 72,
                color: Colors.grey.shade200,
                child: hasValidImage
                    ? Image.network(
                        ApiConfig.getPhotoUrl(imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : const Icon(
                        Icons.directions_car,
                        size: 40,
                        color: Colors.black26,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // Text content
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
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  /*
                  Text(
                    '$lastWork',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  */
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
