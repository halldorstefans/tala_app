import 'dart:io';

import '../../../domain/models/vehicle.dart';
import '../../../utils/result.dart';

abstract class VehicleRepository {
  Future<Result<Vehicle>> getVehicle(String vehicleId);
  Future<Result<List<Vehicle>>> getVehicles();

  /// A live view of the vehicle list that re-emits on any add/edit/delete, so
  /// screens stay current without manual refetching.
  Stream<List<Vehicle>> watchVehicles();

  Future<Result<String>> addVehicle(Vehicle vehicle);
  Future<Result<Vehicle>> updateVehicle(Vehicle vehicle);
  Future<Result<void>> deleteVehicle(String vehicleId);
  Future<Result<String>> uploadVehiclePhoto(String vehicleId, File photo);

  /// Clears the vehicle's cover photo — deletes the file and nulls the field.
  Future<Result<void>> removeVehiclePhoto(String vehicleId);
}
