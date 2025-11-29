import 'dart:io';

import '../../../domain/models/vehicle.dart';
import '../../../utils/result.dart';

abstract class VehicleRepository {
  Future<Result<Vehicle>> getVehicle(String vehicleId);
  Future<Result<List<Vehicle>>> getVehicles();
  Future<Result<void>> addVehicle(Vehicle vehicle);
  Future<Result<Vehicle>> updateVehicle(Vehicle vehicle);
  Future<Result<void>> deleteVehicle(String vehicleId);
  Future<Result<String>> uploadVehiclePhoto(String vehicleId, File photo);
}
