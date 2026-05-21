import 'package:flutter/material.dart';
import 'package:tala_app/ui/core/widgets/app_image.dart';
import '../../../../domain/models/vehicle.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback? onTap;
  const VehicleCard({super.key, required this.vehicle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: AppImage(
          path: vehicle.photoUrl,
          width: 56,
          height: 56,
          placeholderIcon: Icons.directions_car,
        ),
        title: Text('${vehicle.make} ${vehicle.model}'),
        subtitle: Text('Year: ${vehicle.year}'),
        onTap: onTap,
      ),
    );
  }
}
