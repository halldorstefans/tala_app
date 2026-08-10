import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/domain/models/progress_status.dart';
import 'package:tala_app/domain/models/project.dart';
import 'package:tala_app/ui/project/form/view_models/project_form_view_model.dart';

import '../../../helpers/fake_projects_repository.dart';

ProjectFormViewModel _vm(FakeProjectsRepository repo, {Project? project}) =>
    ProjectFormViewModel(
      projectsRepository: repo,
      vehicleId: 'v1',
      project: project,
    );

void main() {
  group('ProjectFormViewModel', () {
    test('addProject assigns the generated id to the stored project', () async {
      final repo = FakeProjectsRepository()..nextId = 'project-9';
      final vm = _vm(repo);

      await vm.addProject.execute(
        const Project(id: '', vehicleId: 'v1', title: 'Disassembly'),
      );

      expect(vm.addProject.completed, isTrue);
      expect(vm.project?.id, 'project-9');
      expect(repo.lastAdded?.title, 'Disassembly');
    });

    test('updateProject stores the edited project', () async {
      final repo = FakeProjectsRepository()
        ..seed(const Project(id: 'p1', vehicleId: 'v1', title: 'Old'));
      final vm = _vm(repo);

      const edited = Project(
        id: 'p1',
        vehicleId: 'v1',
        title: 'New',
        status: ProgressStatus.inProgress,
      );
      await vm.updateProject.execute(edited);

      expect(vm.updateProject.completed, isTrue);
      expect(repo.lastUpdated?.title, 'New');
      expect(vm.project?.title, 'New');
    });

    test('fetchProject loads the project by id', () async {
      final repo = FakeProjectsRepository()
        ..seed(const Project(id: 'p1', vehicleId: 'v1', title: 'Body prep'));
      final vm = _vm(repo);

      await vm.fetchProject.execute('p1');

      expect(vm.project?.title, 'Body prep');
    });

    test('addProject surfaces an error without storing a project', () async {
      final repo = FakeProjectsRepository()..error = Exception('boom');
      final vm = _vm(repo);

      await vm.addProject.execute(
        const Project(id: '', vehicleId: 'v1', title: 'Doomed'),
      );

      expect(vm.addProject.error, isTrue);
      expect(vm.project, isNull);
    });
  });
}
