import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/domain/models/vehicle.dart';
import 'package:tala_app/ui/home/view_models/home_viewmodel.dart';

import '../../helpers/fake_vehicle_repository.dart';

Vehicle _car(String id) =>
    Vehicle(id: id, make: 'MG', model: 'B', year: 1974);

Future<void> _settle(HomeViewModel vm) async {
  while (vm.fetchVehicles.running) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  group('HomeViewModel', () {
    test('populates vehicles on first fetch', () async {
      final repo = FakeVehicleRepository()..vehicles = [_car('a'), _car('b')];
      final vm = HomeViewModel(vehicleRepository: repo);

      await _settle(vm);

      expect(vm.vehicles.map((v) => v.id), ['a', 'b']);
      expect(vm.fetchVehicles.completed, isTrue);
    });

    test('replaces list on re-fetch (does not append)', () async {
      final repo = FakeVehicleRepository()..vehicles = [_car('a')];
      final vm = HomeViewModel(vehicleRepository: repo);
      await _settle(vm);

      repo.vehicles = [_car('b'), _car('c')];
      await vm.fetchVehicles.execute();

      expect(vm.vehicles.map((v) => v.id), ['b', 'c']);
    });

    test('sets errorMessage on failure', () async {
      final repo = FakeVehicleRepository()..error = Exception('db down');
      final vm = HomeViewModel(vehicleRepository: repo);

      await _settle(vm);

      expect(vm.fetchVehicles.error, isTrue);
      expect(vm.errorMessage, contains('db down'));
      expect(vm.vehicles, isEmpty);
    });
  });
}
