import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tala_app/data/services/shared_preferences_service.dart';
import 'package:tala_app/domain/models/job.dart';
import 'package:tala_app/ui/job/form/view_models/job_form_view_model.dart';
import 'package:tala_app/utils/result.dart';

import '../../../helpers/fake_jobs_repository.dart';

Future<File?> _identityCompressor(File source) async => source;
Future<File?> _failingCompressor(File source) async => null;

void main() {
  group('JobFormViewModel.addJob', () {
    test('accepts a job with only title populated', () async {
      final repo = FakeJobsRepository()..nextId = 'job-42';
      final vm = JobFormViewModel(jobsRepository: repo, vehicleId: 'v1');

      final minimalJob = Job(id: '', vehicleId: 'v1', title: 'Oil change');
      await vm.addJob.execute(minimalJob);

      expect(repo.lastAdded?.title, 'Oil change');
      expect(repo.lastAdded?.category, isNull);
      expect(repo.lastAdded?.description, isNull);
      expect(repo.lastAdded?.odometer, isNull);
      expect(repo.lastAdded?.cost, isNull);
      expect(repo.lastAdded?.completionDate, isNull);
    });

    test('sets job id from repository on success', () async {
      final repo = FakeJobsRepository()..nextId = 'job-42';
      final vm = JobFormViewModel(jobsRepository: repo, vehicleId: 'v1');

      await vm.addJob.execute(
        Job(id: '', vehicleId: 'v1', title: 'Oil change'),
      );

      expect(vm.job, isNotNull);
      expect(vm.job!.id, 'job-42');
      expect(vm.job!.vehicleId, 'v1');
    });

    test('leaves vm.job null on failure (NPE regression guard)', () async {
      final repo = FakeJobsRepository()..error = Exception('db down');
      final vm = JobFormViewModel(jobsRepository: repo, vehicleId: 'v1');

      await vm.addJob.execute(
        Job(id: '', vehicleId: 'v1', title: 'Oil change'),
      );

      expect(vm.job, isNull);
      expect(vm.addJob.error, isTrue);
    });
  });

  group('JobFormViewModel.updateJob', () {
    test('persists updated job', () async {
      final repo = FakeJobsRepository();
      final existing = Job(id: 'job-1', vehicleId: 'v1', title: 'Original');
      repo.seed(existing);

      final vm = JobFormViewModel(
        jobsRepository: repo,
        vehicleId: 'v1',
        job: existing,
      );

      final updated = Job(
        id: 'job-1',
        vehicleId: 'v1',
        title: 'Renamed',
        category: 'maintenance',
      );
      await vm.updateJob.execute(updated);

      expect(repo.lastUpdated?.title, 'Renamed');
      expect(vm.job?.title, 'Renamed');
      expect(vm.job?.category, 'maintenance');
    });
  });

  group('JobFormViewModel.uploadJobPhotos', () {
    test('uploads each file once via the repository', () async {
      final repo = FakeJobsRepository();
      final vm = JobFormViewModel(
        jobsRepository: repo,
        vehicleId: 'v1',
        compressor: _identityCompressor,
      );

      final photos = [File('/tmp/a.jpg'), File('/tmp/b.jpg')];
      final result = await vm.uploadJobPhotos('v1', 'job-1', photos);

      expect(result, isA<Ok<void>>());
      expect(repo.uploadedPhotos.map((f) => f.path), [
        '/tmp/a.jpg',
        '/tmp/b.jpg',
      ]);
    });

    test('uses compressor output when it returns a file', () async {
      final repo = FakeJobsRepository();
      Future<File?> swappingCompressor(File source) async =>
          File('${source.path}.compressed');
      final vm = JobFormViewModel(
        jobsRepository: repo,
        vehicleId: 'v1',
        compressor: swappingCompressor,
      );

      await vm.uploadJobPhotos('v1', 'job-1', [File('/tmp/a.jpg')]);

      expect(repo.uploadedPhotos.single.path, '/tmp/a.jpg.compressed');
    });

    test('falls back to original when compressor returns null', () async {
      final repo = FakeJobsRepository();
      final vm = JobFormViewModel(
        jobsRepository: repo,
        vehicleId: 'v1',
        compressor: _failingCompressor,
      );

      await vm.uploadJobPhotos('v1', 'job-1', [File('/tmp/a.jpg')]);

      expect(repo.uploadedPhotos.single.path, '/tmp/a.jpg');
    });

    test('updates progress counters during upload', () async {
      final repo = FakeJobsRepository();
      final vm = JobFormViewModel(
        jobsRepository: repo,
        vehicleId: 'v1',
        compressor: _identityCompressor,
      );

      final observed = <(int, int)>[];
      vm.addListener(() {
        observed.add((vm.uploadedCount, vm.uploadTotal));
      });

      await vm.uploadJobPhotos('v1', 'job-1', [
        File('/tmp/a.jpg'),
        File('/tmp/b.jpg'),
      ]);

      expect(observed, [(0, 2), (1, 2), (2, 2), (0, 0)]);
      expect(vm.uploadedCount, 0);
      expect(vm.uploadTotal, 0);
    });

    test('no-op when photo list is empty', () async {
      final repo = FakeJobsRepository();
      final vm = JobFormViewModel(
        jobsRepository: repo,
        vehicleId: 'v1',
        compressor: _identityCompressor,
      );

      final result = await vm.uploadJobPhotos('v1', 'job-1', []);

      expect(result, isA<Ok<void>>());
      expect(repo.uploadedPhotos, isEmpty);
      expect(vm.uploadTotal, 0);
    });

    test('returns error but continues uploading on partial failure',
        () async {
      final repo = FakeJobsRepository()
        ..uploadError = Exception('disk full');
      final vm = JobFormViewModel(
        jobsRepository: repo,
        vehicleId: 'v1',
        compressor: _identityCompressor,
      );

      final result = await vm.uploadJobPhotos('v1', 'job-1', [
        File('/tmp/a.jpg'),
        File('/tmp/b.jpg'),
      ]);

      expect(result, isA<Error<void>>());
      expect(vm.uploadTotal, 0);
    });
  });

  group('JobFormViewModel.fetchJob', () {
    test('loads job into vm', () async {
      final repo = FakeJobsRepository();
      repo.seed(Job(id: 'job-1', vehicleId: 'v1', title: 'Stored'));

      final vm = JobFormViewModel(jobsRepository: repo, vehicleId: 'v1');
      await vm.fetchJob.execute(('v1', 'job-1'));

      expect(vm.job?.id, 'job-1');
      expect(vm.job?.title, 'Stored');
    });

    test('marks command as error when job missing', () async {
      final repo = FakeJobsRepository();
      final vm = JobFormViewModel(jobsRepository: repo, vehicleId: 'v1');

      await vm.fetchJob.execute(('v1', 'missing'));

      expect(vm.job, isNull);
      expect(vm.fetchJob.error, isTrue);
    });
  });

  group('JobFormViewModel.loadDefaultCategory', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('is a no-op when no preferences service is provided', () async {
      final vm = JobFormViewModel(
        jobsRepository: FakeJobsRepository(),
        vehicleId: 'v1',
      );

      await vm.loadDefaultCategory.execute();

      expect(vm.defaultCategory, isNull);
      expect(vm.loadDefaultCategory.error, isFalse);
    });

    test('loads the stored default category from prefs', () async {
      SharedPreferences.setMockInitialValues({
        'DEFAULT_JOB_CATEGORY': 'repair',
      });
      final vm = JobFormViewModel(
        jobsRepository: FakeJobsRepository(),
        vehicleId: 'v1',
        preferences: SharedPreferencesService(),
      );

      await vm.loadDefaultCategory.execute();

      expect(vm.defaultCategory, 'repair');
    });

    test('addJob persists the category as the new default', () async {
      final prefs = SharedPreferencesService();
      final vm = JobFormViewModel(
        jobsRepository: FakeJobsRepository()..nextId = 'j1',
        vehicleId: 'v1',
        preferences: prefs,
      );

      await vm.addJob.execute(
        Job(id: '', vehicleId: 'v1', title: 'Oil', category: 'maintenance'),
      );
      // Category write is fire-and-forget from addJob's perspective;
      // drain the microtask queue so the pref write completes.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(await prefs.getDefaultJobCategory(), 'maintenance');
    });

    test('addJob with null category clears the stored default', () async {
      SharedPreferences.setMockInitialValues({
        'DEFAULT_JOB_CATEGORY': 'repair',
      });
      final prefs = SharedPreferencesService();
      final vm = JobFormViewModel(
        jobsRepository: FakeJobsRepository()..nextId = 'j1',
        vehicleId: 'v1',
        preferences: prefs,
      );

      await vm.addJob.execute(Job(id: '', vehicleId: 'v1', title: 'Uncat'));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(await prefs.getDefaultJobCategory(), isNull);
    });
  });
}
