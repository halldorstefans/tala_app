import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/domain/models/job.dart';
import 'package:tala_app/domain/models/job_part.dart';
import 'package:tala_app/domain/models/job_status.dart';
import 'package:tala_app/domain/models/part.dart';
import 'package:tala_app/domain/models/project.dart';
import 'package:tala_app/ui/project/list/view_models/project_list_viewmodel.dart';

import '../../../helpers/fake_parts_repository.dart';
import '../../../helpers/fake_projects_repository.dart';

Project _project(String id, {String vehicleId = 'v1'}) =>
    Project(id: id, vehicleId: vehicleId, title: id);

Future<void> _settle(ProjectListViewModel vm) async {
  while (vm.fetchProjects.running) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  group('ProjectListViewModel', () {
    test('fetchProjects loads only the vehicle\'s projects', () async {
      final repo = FakeProjectsRepository()
        ..seed(_project('a'))
        ..seed(_project('b'))
        ..seed(_project('other', vehicleId: 'v2'));
      final vm = ProjectListViewModel(
        projectsRepository: repo,
        vehicleId: 'v1',
      );
      await _settle(vm);

      expect(vm.projects.map((p) => p.id), unorderedEquals(['a', 'b']));
    });

    test('surfaces an error and leaves the list empty on failure', () async {
      final repo = FakeProjectsRepository()..error = Exception('boom');
      final vm = ProjectListViewModel(
        projectsRepository: repo,
        vehicleId: 'v1',
      );
      await _settle(vm);

      expect(vm.fetchProjects.error, isTrue);
      expect(vm.projects, isEmpty);
    });

    test('builds a per-project summary with parts-inclusive cost', () async {
      final projects = FakeProjectsRepository()
        ..seed(_project('a'))
        ..seedJob(
          const Job(
            id: 'j1',
            vehicleId: 'v1',
            projectId: 'a',
            title: 'j1',
            status: JobStatus.completed,
            cost: 100,
          ),
        )
        ..seedJob(
          const Job(
            id: 'j2',
            vehicleId: 'v1',
            projectId: 'a',
            title: 'j2',
            status: JobStatus.inProgress,
          ),
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
      final vm = ProjectListViewModel(
        projectsRepository: projects,
        vehicleId: 'v1',
        partsRepository: parts,
      );
      await _settle(vm);

      final summary = vm.summaryFor('a');
      expect(summary, isNotNull);
      expect(summary!.completed, 1);
      expect(summary.inProgress, 1);
      // 100 (job other cost) + 20 (parts).
      expect(summary.totalCost, closeTo(120, 1e-9));
    });

    test('no summaries without a parts repository', () async {
      final vm = ProjectListViewModel(
        projectsRepository: FakeProjectsRepository()..seed(_project('a')),
        vehicleId: 'v1',
      );
      await _settle(vm);

      expect(vm.summaryFor('a'), isNull);
    });
  });
}
