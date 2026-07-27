import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/domain/models/project.dart';
import 'package:tala_app/ui/job/form/view_models/job_form_view_model.dart';

import '../../../helpers/fake_jobs_repository.dart';
import '../../../helpers/fake_projects_repository.dart';

void main() {
  group('JobFormViewModel project loading', () {
    test('loadProjects populates the vehicle\'s projects', () async {
      final projectsRepo = FakeProjectsRepository()
        ..seed(const Project(id: 'p1', vehicleId: 'v1', title: 'Disassembly'))
        ..seed(const Project(id: 'p2', vehicleId: 'v1', title: 'Rewire'))
        ..seed(const Project(id: 'x', vehicleId: 'v2', title: 'Other car'));
      final vm = JobFormViewModel(
        jobsRepository: FakeJobsRepository(),
        vehicleId: 'v1',
        projectsRepository: projectsRepo,
      );

      await vm.loadProjects.execute();

      expect(vm.projects.map((p) => p.id), unorderedEquals(['p1', 'p2']));
    });

    test('loadProjects is a no-op without a projects repository', () async {
      final vm = JobFormViewModel(
        jobsRepository: FakeJobsRepository(),
        vehicleId: 'v1',
      );

      await vm.loadProjects.execute();

      expect(vm.projects, isEmpty);
      expect(vm.loadProjects.completed, isTrue);
    });
  });
}
