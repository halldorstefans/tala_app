import 'package:tala_app/data/repositories/projects/projects_repository.dart';
import 'package:tala_app/domain/models/job.dart';
import 'package:tala_app/domain/models/project.dart';
import 'package:tala_app/utils/result.dart';

class FakeProjectsRepository implements ProjectsRepository {
  final Map<String, Project> _projects = {};
  final List<Job> _jobs = [];
  Exception? error;
  String nextId = 'project-1';

  Project? lastAdded;
  Project? lastUpdated;
  String? lastDeleted;

  void seed(Project project) => _projects[project.id] = project;

  /// Seed a job so [getJobsForProject] can return it (matched on `projectId`).
  void seedJob(Job job) => _jobs.add(job);

  @override
  Future<Result<List<Project>>> getProjects(String vehicleId) async {
    if (error != null) return Result.error(error!);
    return Result.ok(
      _projects.values.where((p) => p.vehicleId == vehicleId).toList(),
    );
  }

  @override
  Future<Result<Project>> getProject(String projectId) async {
    if (error != null) return Result.error(error!);
    final project = _projects[projectId];
    if (project == null) return Result.error(Exception('not found'));
    return Result.ok(project);
  }

  @override
  Future<Result<String>> addProject(Project project) async {
    if (error != null) return Result.error(error!);
    lastAdded = project;
    _projects[nextId] = project.copyWith(id: nextId);
    return Result.ok(nextId);
  }

  @override
  Future<Result<Project>> updateProject(Project project) async {
    if (error != null) return Result.error(error!);
    lastUpdated = project;
    _projects[project.id] = project;
    return Result.ok(project);
  }

  @override
  Future<Result<void>> deleteProject(String projectId) async {
    if (error != null) return Result.error(error!);
    lastDeleted = projectId;
    _projects.remove(projectId);
    // Mirror the local contract: jobs are unassigned, not deleted.
    for (var i = 0; i < _jobs.length; i++) {
      if (_jobs[i].projectId == projectId) {
        _jobs[i] = _jobs[i].withProject(null);
      }
    }
    return Result.ok(null);
  }

  @override
  Future<Result<List<Job>>> getJobsForProject(String projectId) async {
    if (error != null) return Result.error(error!);
    return Result.ok(_jobs.where((j) => j.projectId == projectId).toList());
  }
}
