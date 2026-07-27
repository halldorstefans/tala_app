import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../data/repositories/projects/projects_repository.dart';
import '../../../../domain/models/job_status.dart';
import '../../../../domain/models/project.dart';
import '../../../../utils/command.dart';
import '../../../../utils/result.dart';

class ProjectListViewModel extends ChangeNotifier {
  ProjectListViewModel({
    required ProjectsRepository projectsRepository,
    required String vehicleId,
  }) : _projectsRepository = projectsRepository,
       _vehicleId = vehicleId {
    fetchProjects = Command1(_fetchProjects)..execute(vehicleId);
  }

  final _log = Logger('ProjectListViewModel');
  final ProjectsRepository _projectsRepository;

  final String _vehicleId;
  String get vehicleId => _vehicleId;

  final List<Project> _projects = <Project>[];
  List<Project> get projects => _projects;

  /// Projects currently underway. Backs the "Active Projects" summary on the
  /// vehicle detail screen, mirroring the job list's `inProgressJobs`.
  List<Project> get activeProjects =>
      _projects.where((p) => p.status == JobStatus.inProgress).toList();

  late Command1<void, String> fetchProjects;

  Future<Result<void>> _fetchProjects(String vehicleId) async {
    final result = await _projectsRepository.getProjects(vehicleId);

    switch (result) {
      case Error<List<Project>>():
        _log.severe('Error fetching projects: ${result.error}');
        return result;
      case Ok<List<Project>>():
    }

    _projects
      ..clear()
      ..addAll(result.value);
    notifyListeners();

    return result;
  }
}
