import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../data/repositories/parts/parts_repository.dart';
import '../../../../data/repositories/projects/projects_repository.dart';
import '../../../../domain/models/job.dart';
import '../../../../domain/models/job_status.dart';
import '../../../../domain/models/project.dart';
import '../../../../utils/command.dart';
import '../../../../utils/result.dart';
import '../../../job/list/view_models/job_list_viewmodel.dart' show computeJobStats;

/// Per-project rollup for the list cards: status counts and a parts-inclusive
/// total cost.
typedef ProjectSummary = ({
  int planned,
  int inProgress,
  int completed,
  double totalCost,
});

class ProjectListViewModel extends ChangeNotifier {
  ProjectListViewModel({
    required ProjectsRepository projectsRepository,
    required String vehicleId,
    PartsRepository? partsRepository,
  }) : _projectsRepository = projectsRepository,
       _vehicleId = vehicleId,
       _partsRepository = partsRepository {
    fetchProjects = Command1(_fetchProjects)..execute(vehicleId);
  }

  final _log = Logger('ProjectListViewModel');
  final ProjectsRepository _projectsRepository;

  /// Optional: when wired, each project's card shows a status/cost summary.
  final PartsRepository? _partsRepository;

  final String _vehicleId;
  String get vehicleId => _vehicleId;

  final List<Project> _projects = <Project>[];
  List<Project> get projects => _projects;

  final Map<String, ProjectSummary> _summaries = {};

  /// The card summary for [projectId], or null when summaries aren't loaded.
  ProjectSummary? summaryFor(String projectId) => _summaries[projectId];

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

    await _loadSummaries();
    notifyListeners();

    return result;
  }

  /// Loads a status/cost summary per project. No-op without a parts repository.
  /// N+1, but project counts are small.
  Future<void> _loadSummaries() async {
    _summaries.clear();
    final partsRepo = _partsRepository;
    if (partsRepo == null) return;

    for (final project in _projects) {
      final jobsResult = await _projectsRepository.getJobsForProject(project.id);
      if (jobsResult is! Ok<List<Job>>) continue;
      final jobs = jobsResult.value;
      final stats = computeJobStats(jobs);

      var partsTotal = 0.0;
      for (final job in jobs) {
        final t = await partsRepo.partsTotalForJob(job.id);
        if (t is Ok<double>) partsTotal += t.value;
      }

      _summaries[project.id] = (
        planned: stats.planned,
        inProgress: stats.inProgress,
        completed: stats.completed,
        totalCost: stats.totalCost + partsTotal,
      );
    }
  }
}
