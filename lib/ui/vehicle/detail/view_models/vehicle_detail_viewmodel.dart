import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:tala_app/utils/command.dart';

import '../../../../data/repositories/vehicle/vehicle_repository.dart';
import '../../../../domain/models/vehicle.dart';
import '../../../../utils/result.dart';

class VehicleDetailViewModel extends ChangeNotifier {
  VehicleDetailViewModel({required VehicleRepository vehicleRepository})
    : _vehicleRepository = vehicleRepository {
    fetchVehicle = Command1(_fetchVehicle);
    remove = Command1(_remove);
  }

  final _log = Logger('VehicleListViewModel');
  final VehicleRepository _vehicleRepository;

  Vehicle? _vehicle;
  Vehicle? get vehicle => _vehicle;

  late final Command1<void, String> fetchVehicle;
  late final Command1<void, String> remove;

  Future<Result<void>> _fetchVehicle(String vehicleId) async {
    final result = await _vehicleRepository.getVehicle(vehicleId);

    switch (result) {
      case Error<Vehicle>():
        _log.severe('Error fetching vehicles: ${result.error}');
        return result;
      case Ok<Vehicle>():
    }

    _vehicle = result.value;

    notifyListeners();

    return result;
  }

  Future<Result> _remove(String vehicleId) async {
    final result = await _vehicleRepository.deleteVehicle(vehicleId);
    switch (result) {
      case Ok<void>():
        return result;
      case Error<void>():
        return result;
    }
  }
}
