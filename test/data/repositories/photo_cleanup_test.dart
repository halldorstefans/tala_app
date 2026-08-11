import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tala_app/data/database/app_database.dart' show AppDatabase;
import 'package:tala_app/data/repositories/jobs/jobs_repository_local.dart';
import 'package:tala_app/data/repositories/vehicle/vehicle_repository_local.dart';
import 'package:tala_app/domain/models/job.dart';
import 'package:tala_app/domain/models/vehicle.dart';
import 'package:tala_app/utils/result.dart';

/// Integration tests for on-disk photo cleanup on delete.
///
/// Unlike the ViewModel/widget suites, these exercise the *real* Drift schema
/// (via `NativeDatabase.memory()`) and the *real* filesystem (a temp dir stood
/// in for the app documents directory). That combination is the only way to
/// catch the leak class where a delete drops the photo row but leaves its file
/// behind — the in-memory fakes never touch either layer.
class _FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _FakePathProvider(this.root);

  final String root;

  @override
  Future<String?> getApplicationDocumentsPath() async => root;

  @override
  Future<String?> getTemporaryPath() async => root;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory docsDir;
  late AppDatabase db;
  late VehicleRepositoryLocal vehicleRepo;
  late JobsRepositoryLocal jobsRepo;

  setUp(() async {
    docsDir = await Directory.systemTemp.createTemp('tala_photo_cleanup_');
    PathProviderPlatform.instance = _FakePathProvider(docsDir.path);
    db = AppDatabase.forTesting(NativeDatabase.memory());
    vehicleRepo = VehicleRepositoryLocal(database: db);
    jobsRepo = JobsRepositoryLocal(database: db);
  });

  tearDown(() async {
    await db.close();
    if (await docsDir.exists()) await docsDir.delete(recursive: true);
  });

  /// A throwaway source image the repositories can copy into `photos/`.
  Future<File> makeSourceImage() async {
    final src = File(p.join(docsDir.path, 'source.jpg'));
    await src.writeAsBytes(const [0x1, 0x2, 0x3]);
    return src;
  }

  /// Resolves a stored relative path (`photos/<uuid>.jpg`) to its file on disk.
  File fileFor(String relativePath) => File(p.join(docsDir.path, relativePath));

  String unwrap(Result<String> result) => switch (result) {
    Ok<String>(:final value) => value,
    Error<String>(:final error) => throw error,
  };

  Future<String> seedVehicle({String id = 'veh-1'}) async {
    return unwrap(
      await vehicleRepo.addVehicle(
        Vehicle(id: id, make: 'Saab', model: '900', year: 1989),
      ),
    );
  }

  Future<String> seedJob(String vehicleId, {String id = 'job-1'}) async {
    return unwrap(
      await jobsRepo.addJob(
        vehicleId,
        Job(id: id, vehicleId: vehicleId, title: 'Head gasket'),
      ),
    );
  }

  test('deleteJob removes the photo files from disk and their rows', () async {
    final vehicleId = await seedVehicle();
    final jobId = await seedJob(vehicleId);

    final photoA = unwrap(
      await jobsRepo.uploadJobPhoto(vehicleId, jobId, await makeSourceImage()),
    );
    final photoB = unwrap(
      await jobsRepo.uploadJobPhoto(vehicleId, jobId, await makeSourceImage()),
    );
    expect(await fileFor(photoA).exists(), isTrue);
    expect(await fileFor(photoB).exists(), isTrue);

    final result = await jobsRepo.deleteJob(vehicleId, jobId);
    expect(result, isA<Ok<void>>());

    expect(
      await fileFor(photoA).exists(),
      isFalse,
      reason: 'job photo file should be deleted, not orphaned',
    );
    expect(await fileFor(photoB).exists(), isFalse);
    expect(await db.getAttachmentsForJob(jobId), isEmpty);
  });

  test(
    'deleteVehicle removes its job photos and its own cover photo from disk',
    () async {
      final vehicleId = await seedVehicle();

      final coverPath = unwrap(
        await vehicleRepo.uploadVehiclePhoto(vehicleId, await makeSourceImage()),
      );

      final jobId = await seedJob(vehicleId);
      final jobPhoto = unwrap(
        await jobsRepo.uploadJobPhoto(
          vehicleId,
          jobId,
          await makeSourceImage(),
        ),
      );

      expect(await fileFor(coverPath).exists(), isTrue);
      expect(await fileFor(jobPhoto).exists(), isTrue);

      final result = await vehicleRepo.deleteVehicle(vehicleId);
      expect(result, isA<Ok<void>>());

      expect(
        await fileFor(coverPath).exists(),
        isFalse,
        reason: 'vehicle cover photo should be deleted',
      );
      expect(
        await fileFor(jobPhoto).exists(),
        isFalse,
        reason: 'job photo should be deleted when the vehicle cascades',
      );
      expect(await db.getVehicleById(vehicleId), isNull);
      expect(await db.getAttachmentsForJob(jobId), isEmpty);
    },
  );

  test('replacing a vehicle photo deletes the previous file', () async {
    final vehicleId = await seedVehicle();

    final firstPath = unwrap(
      await vehicleRepo.uploadVehiclePhoto(vehicleId, await makeSourceImage()),
    );
    final secondPath = unwrap(
      await vehicleRepo.uploadVehiclePhoto(vehicleId, await makeSourceImage()),
    );

    expect(firstPath, isNot(secondPath));
    expect(
      await fileFor(firstPath).exists(),
      isFalse,
      reason: 'the replaced cover photo should not linger on disk',
    );
    expect(await fileFor(secondPath).exists(), isTrue);
  });
}
