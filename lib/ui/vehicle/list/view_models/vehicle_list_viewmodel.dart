import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:tala_app/utils/command.dart';

import '../../../../data/repositories/vehicle/vehicle_repository.dart';
import '../../../../domain/models/vehicle.dart';
import '../../../../utils/result.dart';

class VehicleListViewModel extends ChangeNotifier {
  VehicleListViewModel({required VehicleRepository vehicleRepository})
    : _vehicleRepository = vehicleRepository {
    fetchVehicles = Command0(_fetchVehicles)..execute();
  }

  final _log = Logger('VehicleListViewModel');
  final VehicleRepository _vehicleRepository;

  final List<Vehicle> _vehicles = <Vehicle>[];
  List<Vehicle> get vehicles => _vehicles;

  late Command0 fetchVehicles;

  Future<Result<void>> _fetchVehicles() async {
    final result = await _vehicleRepository.getVehicles();

    switch (result) {
      case Error<List<Vehicle>>():
        _log.severe('Error fetching vehicles: ${result.error}');
        return result;
      case Ok<List<Vehicle>>():
    }

    _vehicles.addAll(result.value);

    return result;
  }
}
