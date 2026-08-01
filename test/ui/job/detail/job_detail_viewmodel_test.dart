import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/domain/models/job.dart';
import 'package:tala_app/domain/models/job_part.dart';
import 'package:tala_app/domain/models/part.dart';
import 'package:tala_app/ui/job/detail/view_models/job_detail_viewmodel.dart';
import 'package:tala_app/utils/result.dart';

import '../../../helpers/fake_jobs_repository.dart';
import '../../../helpers/fake_parts_repository.dart';

JobDetailViewModel _vm(FakeJobsRepository jobs, FakePartsRepository parts) =>
    JobDetailViewModel(jobsRepository: jobs, partsRepository: parts);

Future<void> _settle(JobDetailViewModel vm) async {
  while (vm.fetchJob.running) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  group('JobDetailViewModel parts', () {
    test('fetchJob loads the job, its parts, and the cost breakdown', () async {
      final jobs = FakeJobsRepository()
        ..seed(
          const Job(id: 'j1', vehicleId: 'v1', title: 'Oil change', cost: 20),
        );
      final parts = FakePartsRepository()
        ..seedPart(const Part(id: 'p1', name: 'Filter'))
        ..seedJobPart(
          const JobPart(
            id: 'jp1',
            jobId: 'j1',
            partId: 'p1',
            unitCost: 10,
            quantity: 2,
          ),
        );
      final vm = _vm(jobs, parts);

      vm.fetchJob.execute(('v1', 'j1'));
      await _settle(vm);

      expect(vm.job?.title, 'Oil change');
      expect(vm.jobParts.length, 1);
      expect(vm.partsTotal, closeTo(20, 1e-9));
      expect(vm.otherCost, closeTo(20, 1e-9));
      expect(vm.totalCost, closeTo(40, 1e-9));
    });

    test('addPart creates a new part, links it, and reloads', () async {
      final jobs = FakeJobsRepository()
        ..seed(const Job(id: 'j1', vehicleId: 'v1', title: 'Service'));
      final parts = FakePartsRepository()..nextPartId = 'part-9';
      final vm = _vm(jobs, parts);
      vm.fetchJob.execute(('v1', 'j1'));
      await _settle(vm);

      final result = await vm.addPart(
        part: const Part(id: '', name: 'Spark plug'),
        unitCost: 5,
        quantity: 4,
      );

      expect(result, isA<Ok<void>>());
      expect(parts.lastAddedPart?.name, 'Spark plug');
      expect(parts.lastAddedJobPart?.partId, 'part-9');
      expect(vm.jobParts.length, 1);
      expect(vm.partsTotal, closeTo(20, 1e-9));
    });

    test('removePart drops the link and reloads', () async {
      final jobs = FakeJobsRepository()
        ..seed(const Job(id: 'j1', vehicleId: 'v1', title: 'Service'));
      final parts = FakePartsRepository()
        ..seedPart(const Part(id: 'p1', name: 'Filter'))
        ..seedJobPart(
          const JobPart(
            id: 'jp1',
            jobId: 'j1',
            partId: 'p1',
            unitCost: 3,
          ),
        );
      final vm = _vm(jobs, parts);
      vm.fetchJob.execute(('v1', 'j1'));
      await _settle(vm);
      expect(vm.jobParts.length, 1);

      await vm.removePart('jp1');

      expect(parts.lastDeletedJobPart, 'jp1');
      expect(vm.jobParts, isEmpty);
      expect(vm.partsTotal, 0);
    });

    test('loadCatalogue populates the catalogue', () async {
      final jobs = FakeJobsRepository()
        ..seed(const Job(id: 'j1', vehicleId: 'v1', title: 'Service'));
      final parts = FakePartsRepository()
        ..seedPart(const Part(id: 'p1', name: 'Filter'))
        ..seedPart(const Part(id: 'p2', name: 'Plug'));
      final vm = _vm(jobs, parts);
      vm.fetchJob.execute(('v1', 'j1'));
      await _settle(vm);

      await vm.loadCatalogue();

      expect(vm.catalogue.map((p) => p.id), unorderedEquals(['p1', 'p2']));
    });

    test('addPart with an existing part reuses it (no new part)', () async {
      final jobs = FakeJobsRepository()
        ..seed(const Job(id: 'j1', vehicleId: 'v1', title: 'Service'));
      final parts = FakePartsRepository()
        ..seedPart(const Part(id: 'p1', name: 'Filter'));
      final vm = _vm(jobs, parts);
      vm.fetchJob.execute(('v1', 'j1'));
      await _settle(vm);

      await vm.addPart(
        part: const Part(id: 'p1', name: 'Filter'),
        unitCost: 8,
        quantity: 2,
      );

      expect(parts.lastAddedPart, isNull); // existing part, not re-created
      expect(parts.lastAddedJobPart?.partId, 'p1');
      expect(vm.jobParts.length, 1);
      expect(vm.partsTotal, closeTo(16, 1e-9));
    });

    test('updateJobPart edits the line cost and reloads the total', () async {
      final jobs = FakeJobsRepository()
        ..seed(const Job(id: 'j1', vehicleId: 'v1', title: 'Service'));
      final parts = FakePartsRepository()
        ..seedPart(const Part(id: 'p1', name: 'Filter'))
        ..seedJobPart(
          // Added without a price.
          const JobPart(id: 'jp1', jobId: 'j1', partId: 'p1', quantity: 1),
        );
      final vm = _vm(jobs, parts);
      vm.fetchJob.execute(('v1', 'j1'));
      await _settle(vm);
      expect(vm.partsTotal, 0);

      await vm.updateJobPart(
        const JobPart(
          id: 'jp1',
          jobId: 'j1',
          partId: 'p1',
          unitCost: 12,
          quantity: 2,
        ),
      );

      expect(parts.lastUpdatedJobPart?.unitCost, 12);
      expect(vm.partsTotal, closeTo(24, 1e-9));
    });
  });
}
