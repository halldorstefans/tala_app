import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../data/repositories/jobs/jobs_repository.dart';
import '../../../../data/repositories/parts/parts_repository.dart';
import '../../../../data/repositories/projects/projects_repository.dart';
import '../../../../domain/models/job.dart';
import '../../../../domain/models/project.dart';
import '../../../../utils/command.dart';
import '../../../../utils/result.dart';
import '../../../job/list/view_models/job_list_viewmodel.dart' show JobStats, computeJobStats;

class ProjectDetailViewModel extends ChangeNotifier {
  ProjectDetailViewModel({
    required ProjectsRepository projectsRepository,
    required PartsRepository partsRepository,
    required JobsRepository jobsRepository,
    required String vehicleId,
    required String projectId,
  }) : _projectsRepository = projectsRepository,
       _partsRepository = partsRepository,
       _jobsRepository = jobsRepository,
       _vehicleId = vehicleId,
       _projectId = projectId {
    load = Command0(_load)..execute();
    delete = Command0(_delete);
  }

  final _log = Logger('ProjectDetailViewModel');
  final ProjectsRepository _projectsRepository;
  final PartsRepository _partsRepository;
  final JobsRepository _jobsRepository;

  final String _vehicleId;
  String get vehicleId => _vehicleId;
  final String _projectId;
  String get projectId => _projectId;

  Project? _project;
  Project? get project => _project;

  final List<Job> _jobs = <Job>[];
  List<Job> get jobs => _jobs;

  /// All of the vehicle's jobs, for the "manage jobs" picker. Loaded on demand.
  final List<Job> _vehicleJobs = <Job>[];
  List<Job> get vehicleJobs => _vehicleJobs;

  double _partsTotal = 0;

  /// Status counts + jobs' own ("other") cost for this project.
  JobStats get stats => computeJobStats(_jobs);

  /// The project's total spend: jobs' own cost plus the parts on those jobs.
  double get totalCostWithParts => stats.totalCost + _partsTotal;

  late final Command0<void> load;
  late final Command0<void> delete;

  Future<Result<void>> _load() async {
    final projectResult = await _projectsRepository.getProject(_projectId);
    switch (projectResult) {
      case Error<Project>():
        _log.severe('Error fetching project: ${projectResult.error}');
        return projectResult;
      case Ok<Project>():
        _project = projectResult.value;
    }

    final jobsResult = await _projectsRepository.getJobsForProject(_projectId);
    switch (jobsResult) {
      case Error<List<Job>>():
        _log.severe('Error fetching project jobs: ${jobsResult.error}');
        return jobsResult;
      case Ok<List<Job>>():
        _jobs
          ..clear()
          ..addAll(jobsResult.value);
    }

    // Fold in the parts on this project's jobs.
    var partsTotal = 0.0;
    for (final job in _jobs) {
      final totalResult = await _partsRepository.partsTotalForJob(job.id);
      if (totalResult is Ok<double>) partsTotal += totalResult.value;
    }
    _partsTotal = partsTotal;

    notifyListeners();
    return const Result.ok(null);
  }

  /// Loads all the vehicle's jobs so the manage-jobs picker can show which
  /// belong to this project.
  Future<void> loadVehicleJobs() async {
    final result = await _jobsRepository.getJobs(_vehicleId);
    if (result is Ok<List<Job>>) {
      _vehicleJobs
        ..clear()
        ..addAll(result.value);
      notifyListeners();
    }
  }

  /// Sets this project's job membership to exactly [selectedJobIds]. Since a
  /// job belongs to at most one project, checking a job assigns it here
  /// (moving it out of any other project); unchecking clears its project.
  /// Only jobs whose membership actually changes are written.
  Future<Result<void>> setJobMembership(Set<String> selectedJobIds) async {
    for (final job in _vehicleJobs) {
      final shouldBelong = selectedJobIds.contains(job.id);
      final belongsNow = job.projectId == _projectId;
      if (shouldBelong == belongsNow) continue;
      final updated = job.withProject(shouldBelong ? _projectId : null);
      final result = await _jobsRepository.updateJob(_vehicleId, updated);
      if (result is Error<Job>) {
        _log.severe('Error updating job membership: ${result.error}');
        return Result.error(result.error);
      }
    }
    await _load();
    await loadVehicleJobs();
    return const Result.ok(null);
  }

  Future<Result<void>> _delete() async {
    final result = await _projectsRepository.deleteProject(_projectId);
    if (result is Error<void>) {
      _log.severe('Error deleting project: ${result.error}');
    }
    return result;
  }
}
