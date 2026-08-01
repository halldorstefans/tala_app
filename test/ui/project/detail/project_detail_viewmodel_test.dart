import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/domain/models/job.dart';
import 'package:tala_app/domain/models/job_part.dart';
import 'package:tala_app/domain/models/job_status.dart';
import 'package:tala_app/domain/models/part.dart';
import 'package:tala_app/domain/models/project.dart';
import 'package:tala_app/ui/project/detail/view_models/project_detail_viewmodel.dart';

import '../../../helpers/fake_parts_repository.dart';
import '../../../helpers/fake_projects_repository.dart';

Job _job(
  String id,
  String? projectId, {
  String? status,
  double? cost,
}) => Job(
  id: id,
  vehicleId: 'v1',
  projectId: projectId,
  title: id,
  status: status,
  cost: cost,
);

ProjectDetailViewModel _vm(
  FakeProjectsRepository repo, {
  FakePartsRepository? parts,
}) => ProjectDetailViewModel(
  projectsRepository: repo,
  partsRepository: parts ?? FakePartsRepository(),
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
  });
}
