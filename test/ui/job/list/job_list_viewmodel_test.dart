import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/domain/models/job.dart';
import 'package:tala_app/domain/models/job_category.dart';
import 'package:tala_app/domain/models/job_status.dart';
import 'package:tala_app/ui/job/list/view_models/job_list_viewmodel.dart';

import '../../../helpers/fake_jobs_repository.dart';

Job _job(
  String id, {
  String vehicleId = 'v1',
  String? status,
  String? category,
  DateTime? startDate,
}) => Job(
  id: id,
  vehicleId: vehicleId,
  title: id,
  status: status,
  category: category,
  startDate: startDate,
);

Future<void> _settle(JobListViewModel vm) async {
  while (vm.fetchJobs.running) {
    await Future<void>.delayed(Duration.zero);
  }
}

Future<JobListViewModel> _vmWithJobs(List<Job> seed) async {
  final repo = FakeJobsRepository();
  for (final j in seed) {
    repo.seed(j);
  }
  final vm = JobListViewModel(jobsRepository: repo, vehicleId: 'v1');
  await _settle(vm);
  return vm;
}

void main() {
  group('JobListViewModel filters', () {
    test('filteredJobs returns all when no filters active', () async {
      final vm = await _vmWithJobs([
        _job('a', status: JobStatus.planned),
        _job('b', status: JobStatus.completed),
      ]);

      expect(vm.hasActiveFilters, isFalse);
      expect(vm.filteredJobs.map((j) => j.id), unorderedEquals(['a', 'b']));
    });

    test('status filter narrows the list', () async {
      final vm = await _vmWithJobs([
        _job('a', status: JobStatus.planned),
        _job('b', status: JobStatus.completed),
        _job('c', status: JobStatus.inProgress),
      ]);

      vm.setStatusFilter({JobStatus.planned, JobStatus.completed});

      expect(vm.filteredJobs.map((j) => j.id), unorderedEquals(['a', 'b']));
    });

    test('category filter narrows the list', () async {
      final vm = await _vmWithJobs([
        _job('a', category: JobCategory.maintenance),
        _job('b', category: JobCategory.electrical),
        _job('c', category: 'timing belt'),
      ]);

      vm.setCategoryFilter({JobCategory.electrical});

      expect(vm.filteredJobs.map((j) => j.id), ['b']);
    });

    test('date range filter includes a job created later on the end day',
        () async {
      final vm = await _vmWithJobs([
        _job('today', startDate: DateTime(2026, 5, 25, 14, 30)),
      ]);

      vm.setDateRange(
        DateTimeRange(
          start: DateTime(2026, 5, 20),
          end: DateTime(2026, 5, 25),
        ),
      );

      expect(vm.filteredJobs.map((j) => j.id), ['today']);
    });

    test('date range filter excludes jobs outside the range', () async {
      final vm = await _vmWithJobs([
        _job('inside', startDate: DateTime(2026, 5, 10)),
        _job('before', startDate: DateTime(2026, 4, 1)),
        _job('after', startDate: DateTime(2026, 6, 1)),
        _job('noDate'),
      ]);

      vm.setDateRange(
        DateTimeRange(
          start: DateTime(2026, 5, 1),
          end: DateTime(2026, 5, 31),
        ),
      );

      expect(vm.filteredJobs.map((j) => j.id), ['inside']);
    });

    test('filters compose with AND semantics', () async {
      final vm = await _vmWithJobs([
        _job(
          'match',
          status: JobStatus.completed,
          category: JobCategory.maintenance,
          startDate: DateTime(2026, 5, 10),
        ),
        _job(
          'wrongStatus',
          status: JobStatus.planned,
          category: JobCategory.maintenance,
          startDate: DateTime(2026, 5, 10),
        ),
        _job(
          'wrongCategory',
          status: JobStatus.completed,
          category: JobCategory.electrical,
          startDate: DateTime(2026, 5, 10),
        ),
      ]);

      vm.setStatusFilter({JobStatus.completed});
      vm.setCategoryFilter({JobCategory.maintenance});
      vm.setDateRange(
        DateTimeRange(
          start: DateTime(2026, 5, 1),
          end: DateTime(2026, 5, 31),
        ),
      );

      expect(vm.filteredJobs.map((j) => j.id), ['match']);
    });

    test('clearFilters resets everything', () async {
      final vm = await _vmWithJobs([
        _job('a', status: JobStatus.planned),
      ]);

      vm.setStatusFilter({JobStatus.completed});
      vm.setCategoryFilter({JobCategory.maintenance});
      vm.setDateRange(
        DateTimeRange(
          start: DateTime(2026, 1, 1),
          end: DateTime(2026, 2, 1),
        ),
      );
      expect(vm.hasActiveFilters, isTrue);

      vm.clearFilters();

      expect(vm.hasActiveFilters, isFalse);
      expect(vm.filteredJobs.map((j) => j.id), ['a']);
    });

    test('filter setters notify listeners', () async {
      final vm = await _vmWithJobs([_job('a')]);
      var notified = 0;
      vm.addListener(() => notified++);

      vm.setStatusFilter({JobStatus.planned});
      vm.setCategoryFilter({JobCategory.maintenance});
      vm.setDateRange(
        DateTimeRange(
          start: DateTime(2026, 1, 1),
          end: DateTime(2026, 2, 1),
        ),
      );
      vm.clearFilters();

      expect(notified, 4);
    });

    test('filteredJobs preserves order from underlying list', () async {
      final vm = await _vmWithJobs([
        _job('first', status: JobStatus.planned),
        _job('second', status: JobStatus.completed),
        _job('third', status: JobStatus.planned),
      ]);

      vm.setStatusFilter({JobStatus.planned});

      expect(vm.filteredJobs.map((j) => j.id), ['first', 'third']);
    });
  });
}
