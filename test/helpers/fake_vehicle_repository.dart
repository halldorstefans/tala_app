import 'dart:io';

import 'package:tala_app/data/repositories/vehicle/vehicle_repository.dart';
import 'package:tala_app/domain/models/vehicle.dart';
import 'package:tala_app/utils/result.dart';

class FakeVehicleRepository implements VehicleRepository {
  List<Vehicle>? vehicles;
  Exception? error;

  @override
  Future<Result<List<Vehicle>>> getVehicles() async {
    if (error != null) return Result.error(error!);
    return Result.ok(vehicles ?? []);
  }

  @override
  Future<Result<Vehicle>> getVehicle(String id) async {
    if (error != null) return Result.error(error!);
    return Result.ok(Vehicle(id: id, make: 'Test', model: 'Car', year: 2000));
  }

  @override
  Future<Result<String>> addVehicle(Vehicle vehicle) async {
    if (error != null) return Result.error(error!);
    return Result.ok('new-id');
  }

  @override
  Future<Result<Vehicle>> updateVehicle(Vehicle vehicle) async {
    if (error != null) return Result.error(error!);
    return Result.ok(vehicle);
  }

  @override
  Future<Result<void>> deleteVehicle(String id) async {
    if (error != null) return Result.error(error!);
    return Result.ok(null);
  }

  @override
  Future<Result<String>> uploadVehiclePhoto(String id, File photo) async {
    if (error != null) return Result.error(error!);
    return Result.ok('photos/test.jpg');
  }
}
