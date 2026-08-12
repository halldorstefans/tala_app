import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/data/database/app_database.dart' show AppDatabase;
import 'package:tala_app/data/repositories/vehicle/vehicle_repository_local.dart';
import 'package:tala_app/domain/models/vehicle.dart';
import 'package:tala_app/ui/home/view_models/home_viewmodel.dart';

/// The home vehicle list is backed by a Drift watch stream, so adds and deletes
/// from anywhere show up without a manual refetch (the bug: needing an app
/// restart). Exercised end-to-end against a real in-memory database.
void main() {
  test('home list reflects inserts and deletes with no refetch', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = VehicleRepositoryLocal(database: db);
    final vm = HomeViewModel(vehicleRepository: repo);
    addTearDown(vm.dispose);

    await pumpEventQueue();
    expect(vm.vehicles, isEmpty);

    await repo.addVehicle(
      const Vehicle(id: 'v1', make: 'MG', model: 'B', year: 1974),
    );
    await pumpEventQueue();
    expect(vm.vehicles.map((v) => v.id), ['v1']);

    await repo.addVehicle(
      const Vehicle(id: 'v2', make: 'Saab', model: '900', year: 1989),
    );
    await pumpEventQueue();
    expect(vm.vehicles.map((v) => v.id), containsAll(['v1', 'v2']));

    await repo.deleteVehicle('v1');
    await pumpEventQueue();
    expect(vm.vehicles.map((v) => v.id), ['v2']);
  });
}
