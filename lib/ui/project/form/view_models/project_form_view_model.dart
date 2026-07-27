import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../data/repositories/projects/projects_repository.dart';
import '../../../../domain/models/project.dart';
import '../../../../utils/command.dart';
import '../../../../utils/result.dart';

class ProjectFormViewModel extends ChangeNotifier {
  ProjectFormViewModel({
    required ProjectsRepository projectsRepository,
    required String vehicleId,
    Project? project,
  }) : _projectsRepository = projectsRepository,
       _vehicleId = vehicleId,
       _project = project {
    addProject = Command1(_addProject);
    updateProject = Command1(_updateProject);
    fetchProject = Command1(_fetchProject);
  }

  final _log = Logger('ProjectFormViewModel');
  final ProjectsRepository _projectsRepository;

  final String _vehicleId;
  String get vehicleId => _vehicleId;

  Project? _project;
  Project? get project => _project;

  late final Command1<String, Project> addProject;
  late final Command1<void, Project> updateProject;
  late final Command1<void, String> fetchProject;

  Future<Result<String>> _addProject(Project project) async {
    final result = await _projectsRepository.addProject(project);

    switch (result) {
      case Error<String>():
        _log.severe('Error adding project: ${result.error}');
        return result;
      case Ok<String>():
        _project = project.copyWith(id: result.value);
    }

    notifyListeners();
    return result;
  }

  Future<Result<void>> _updateProject(Project project) async {
    final result = await _projectsRepository.updateProject(project);

    switch (result) {
      case Error<Project>():
        _log.severe('Error updating project: ${result.error}');
        return result;
      case Ok<Project>():
    }

    _project = project;
    notifyListeners();
    return result;
  }

  Future<Result<void>> _fetchProject(String projectId) async {
    final result = await _projectsRepository.getProject(projectId);

    switch (result) {
      case Error<Project>():
        _log.severe('Error fetching project: ${result.error}');
        return result;
      case Ok<Project>():
    }

    _project = result.value;
    notifyListeners();
    return result;
  }
}
