import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/data/database/app_database.dart' show AppDatabase;
import 'package:tala_app/data/repositories/jobs/jobs_repository_local.dart';
import 'package:tala_app/data/repositories/parts/parts_repository_local.dart';
import 'package:tala_app/data/repositories/vehicle/vehicle_repository_local.dart';
import 'package:tala_app/utils/app_exception.dart';
import 'package:tala_app/utils/result.dart';

/// End-to-end check that the repositories surface *typed* errors against a real
/// database — a missing record yields NotFoundException, not a generic failure
/// — so callers can branch on the kind rather than a message string.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  AppException errorOf(Result<Object?> result) {
    expect(result, isA<Error>());
    final error = (result as Error).error;
    expect(error, isA<AppException>());
    return error as AppException;
  }

  test('a missing vehicle is a NotFoundException', () async {
    final repo = VehicleRepositoryLocal(database: db);
    final error = errorOf(await repo.getVehicle('nope'));
    expect(error, isA<NotFoundException>());
    expect(error.toString(), 'Vehicle not found');
  });

  test('a missing job is a NotFoundException', () async {
    final repo = JobsRepositoryLocal(database: db);
    expect(await repo.getJob('v1', 'nope'), isA<Error>());
    final error = errorOf(await repo.getJob('v1', 'nope'));
    expect(error, isA<NotFoundException>());
  });

  test('a missing part is a NotFoundException', () async {
    final repo = PartsRepositoryLocal(database: db);
    final error = errorOf(await repo.getPart('nope'));
    expect(error, isA<NotFoundException>());
    expect(error.toString(), 'Part not found');
  });
}
