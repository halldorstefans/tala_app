import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/domain/models/project.dart';
import 'package:tala_app/ui/project/list/view_models/project_list_viewmodel.dart';

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
  });
}
