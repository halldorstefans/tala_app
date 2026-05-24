import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/domain/models/job.dart';
import 'package:tala_app/ui/job/form/view_models/job_form_view_model.dart';

import '../../../helpers/fake_jobs_repository.dart';

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
}
