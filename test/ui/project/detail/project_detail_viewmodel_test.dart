import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/domain/models/job.dart';
import 'package:tala_app/domain/models/job_part.dart';
import 'package:tala_app/domain/models/job_status.dart';
import 'package:tala_app/domain/models/part.dart';
import 'package:tala_app/domain/models/project.dart';
import 'package:tala_app/ui/project/detail/view_models/project_detail_viewmodel.dart';
import 'package:tala_app/utils/result.dart';

import '../../../helpers/fake_jobs_repository.dart';
import '../../../helpers/fake_parts_repository.dart';
import '../../../helpers/fake_projects_repository.dart';

Job _job(
  String id,
  String? projectId, {
  String? status,
  double? cost,
  String vehicleId = 'v1',
}) => Job(
  id: id,
  vehicleId: vehicleId,
  projectId: projectId,
  title: id,
  status: status,
  cost: cost,
);

ProjectDetailViewModel _vm(
  FakeProjectsRepository repo, {
  FakePartsRepository? parts,
  FakeJobsRepository? jobs,
}) => ProjectDetailViewModel(
  projectsRepository: repo,
  partsRepository: parts ?? FakePartsRepository(),
  jobsRepository: jobs ?? FakeJobsRepository(),
  vehicleId: 'v1',
  projectId: 'p1',
);

Future<void> _settle(ProjectDetailViewModel vm) async {
  while (vm.load.running) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  group('ProjectDetailViewModel', () {
    test('load fills the project, its jobs, and derived stats', () async {
      final repo = FakeProjectsRepository()
        ..seed(const Project(id: 'p1', vehicleId: 'v1', title: 'Disassembly'))
        ..seedJob(_job('j1', 'p1', status: JobStatus.planned, cost: 100))
        ..seedJob(_job('j2', 'p1', status: JobStatus.completed, cost: 50))
        ..seedJob(_job('j3', 'other', status: JobStatus.inProgress));
      final vm = _vm(repo);
      await _settle(vm);

      expect(vm.project?.title, 'Disassembly');
      expect(vm.jobs.map((j) => j.id), unorderedEquals(['j1', 'j2']));
      expect(vm.stats.planned, 1);
      expect(vm.stats.completed, 1);
      expect(vm.stats.inProgress, 0);
      expect(vm.stats.totalCost, closeTo(150, 1e-9));
    });

    test('totalCostWithParts folds parts into the project total', () async {
      final repo = FakeProjectsRepository()
        ..seed(const Project(id: 'p1', vehicleId: 'v1', title: 'Disassembly'))
        ..seedJob(_job('j1', 'p1', cost: 100));
      final parts = FakePartsRepository()
        ..seedPart(const Part(id: 'pa1', name: 'Filter'))
        ..seedJobPart(
          const JobPart(
            id: 'jp1',
            jobId: 'j1',
            partId: 'pa1',
            unitCost: 10,
            quantity: 2,
          ),
        );
      final vm = _vm(repo, parts: parts);
      await _settle(vm);

      // 100 (job other cost) + 20 (parts).
      expect(vm.totalCostWithParts, closeTo(120, 1e-9));
    });

    test('delete removes the project via the repository', () async {
      final repo = FakeProjectsRepository()
        ..seed(const Project(id: 'p1', vehicleId: 'v1', title: 'Disassembly'));
      final vm = _vm(repo);
      await _settle(vm);

      await vm.delete.execute();

      expect(vm.delete.completed, isTrue);
      expect(repo.lastDeleted, 'p1');
    });

    test('load surfaces an error', () async {
      final repo = FakeProjectsRepository()..error = Exception('boom');
      final vm = _vm(repo);
      await _settle(vm);

      expect(vm.load.error, isTrue);
    });

    test('setJobMembership assigns, unassigns, and moves jobs', () async {
      final projects = FakeProjectsRepository()
        ..seed(const Project(id: 'p1', vehicleId: 'v1', title: 'Disassembly'))
        ..seedJob(_job('j1', 'p1')); // already in this project
      // The jobs repo is the source of truth the VM reads + writes.
      final jobs = FakeJobsRepository()
        ..seed(_job('j1', 'p1'))
        ..seed(_job('j2', null)) // unassigned
        ..seed(_job('j3', 'other')); // in another project
      final vm = _vm(projects, jobs: jobs);
      await _settle(vm);
      await vm.loadVehicleJobs();

      Future<Map<String, String?>> projectIds() async {
        final result = await jobs.getJobs('v1') as Ok<List<Job>>;
        return {for (final j in result.value) j.id: j.projectId};
      }

      // Keep j1, add j2, move j3 here.
      await vm.setJobMembership({'j1', 'j2', 'j3'});
      final ids = await projectIds();
      expect(ids['j1'], 'p1'); // unchanged
      expect(ids['j2'], 'p1'); // assigned
      expect(ids['j3'], 'p1'); // moved from 'other'

      // Now drop j2 back out.
      await vm.setJobMembership({'j1', 'j3'});
      expect((await projectIds())['j2'], isNull);
    });
  });
}
