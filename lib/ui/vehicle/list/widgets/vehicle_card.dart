import 'package:flutter/material.dart';
import '../../../../domain/models/vehicle.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback? onTap;
  const VehicleCard({super.key, required this.vehicle, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool hasValidImage =
        vehicle.photoUrl != null &&
        vehicle.photoUrl!.trim().isNotEmpty &&
        vehicle.photoUrl!.toLowerCase() != 'null' &&
        (vehicle.photoUrl!.startsWith('http://') ||
            vehicle.photoUrl!.startsWith('https://'));

    return Card(
      child: ListTile(
        leading: vehicle.photoUrl != null
            ? (hasValidImage
                  ? Image.network(
                      vehicle.photoUrl!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.directions_car, size: 40))
            : const Icon(Icons.directions_car, size: 40),
        title: Text('${vehicle.make} ${vehicle.model}'),
        subtitle: Text('Year: ${vehicle.year}'),
        onTap: onTap,
      ),
    );
  }
}
