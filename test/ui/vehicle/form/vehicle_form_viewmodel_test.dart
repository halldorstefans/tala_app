import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/domain/models/vehicle.dart';
import 'package:tala_app/ui/vehicle/form/view_models/vehicle_form_viewmodel.dart';

import '../../../helpers/fake_vehicle_repository.dart';

Vehicle _vehicle({String id = '', String make = 'MG'}) =>
    Vehicle(id: id, make: make, model: 'B', year: 1974);

void main() {
  group('VehicleFormViewmodel.addVehicle', () {
    test('routes to repository.addVehicle when no vehicle is seeded', () async {
      final repo = FakeVehicleRepository()..nextId = 'veh-7';
      final vm = VehicleFormViewmodel(vehicleRepository: repo);

      await vm.addVehicle.execute(_vehicle(make: 'Triumph'));

      expect(repo.lastAdded?.make, 'Triumph');
      expect(repo.lastUpdated, isNull);
      expect(vm.vehicle?.id, 'veh-7');
    });

    test('leaves vm.vehicle null on failure', () async {
      final repo = FakeVehicleRepository()..error = Exception('db down');
      final vm = VehicleFormViewmodel(vehicleRepository: repo);

      await vm.addVehicle.execute(_vehicle());

      expect(vm.vehicle, isNull);
      expect(vm.addVehicle.error, isTrue);
    });
  });

  group('VehicleFormViewmodel.updateVehicle', () {
    test('routes to repository.updateVehicle when a vehicle is seeded',
        () async {
      final repo = FakeVehicleRepository();
      final existing = _vehicle(id: 'veh-1');
      final vm = VehicleFormViewmodel(
        vehicleRepository: repo,
        vehicle: existing,
      );

      final updated = Vehicle(
        id: 'veh-1',
        make: 'Austin',
        model: 'Healey',
        year: 1960,
      );
      await vm.updateVehicle.execute(updated);

      expect(repo.lastUpdated?.make, 'Austin');
      expect(repo.lastAdded, isNull);
      expect(vm.vehicle?.make, 'Austin');
    });
  });

  group('VehicleFormViewmodel.uploadVehiclePhoto', () {
    test('compresses the source file before handing it to the repo',
        () async {
      final repo = FakeVehicleRepository();
      Future<File?> swappingCompressor(File source) async =>
          File('${source.path}.compressed');
      final vm = VehicleFormViewmodel(
        vehicleRepository: repo,
        compressor: swappingCompressor,
      );

      await vm.uploadVehiclePhoto('veh-1', File('/tmp/orig.jpg'));

      expect(repo.uploadedPhotos.single.path, '/tmp/orig.jpg.compressed');
    });

    test('falls back to original file when compressor returns null',
        () async {
      final repo = FakeVehicleRepository();
      final vm = VehicleFormViewmodel(
        vehicleRepository: repo,
        compressor: (_) async => null,
      );

      await vm.uploadVehiclePhoto('veh-1', File('/tmp/orig.jpg'));

      expect(repo.uploadedPhotos.single.path, '/tmp/orig.jpg');
    });
  });

  group('VehicleFormViewmodel.fetchVehicle', () {
    test('loads vehicle into vm', () async {
      final repo = FakeVehicleRepository()
        ..seededVehicle = _vehicle(id: 'veh-9', make: 'Jaguar');
      final vm = VehicleFormViewmodel(vehicleRepository: repo);

      await vm.fetchVehicle.execute('veh-9');

      expect(vm.vehicle?.make, 'Jaguar');
    });
  });
}
