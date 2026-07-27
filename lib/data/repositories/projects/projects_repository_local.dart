import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/job.dart' as domain;
import '../../../domain/models/project.dart' as domain;
import '../../../utils/result.dart';
import '../../database/app_database.dart' as db;
import 'projects_repository.dart';

class ProjectsRepositoryLocal implements ProjectsRepository {
  ProjectsRepositoryLocal({required db.AppDatabase database})
    : _database = database;

  final db.AppDatabase _database;
  final _log = Logger('ProjectsRepositoryLocal');
  final _uuid = const Uuid();

  @override
  Future<Result<List<domain.Project>>> getProjects(String vehicleId) async {
    try {
      final results = await _database.getProjectsForVehicle(vehicleId);
      return Result.ok(results.map(domain.Project.fromDrift).toList());
    } catch (e, st) {
      _log.severe('Exception in getProjects', e, st);
      return Result.error(Exception('Failed to get projects'));
    }
  }

  @override
  Future<Result<domain.Project>> getProject(String projectId) async {
    try {
      final result = await _database.getProjectById(projectId);
      if (result == null) {
        return Result.error(Exception('Project not found'));
      }
      return Result.ok(domain.Project.fromDrift(result));
    } catch (e, st) {
      _log.severe('Exception in getProject', e, st);
      return Result.error(Exception('Failed to get project'));
    }
  }

  @override
  Future<Result<String>> addProject(domain.Project project) async {
    try {
      final id = project.id.isEmpty ? _uuid.v4() : project.id;
      await _database.insertProject(project.copyWith(id: id).toDrift());
      return Result.ok(id);
    } catch (e, st) {
      _log.severe('Exception in addProject', e, st);
      return Result.error(Exception('Failed to add project'));
    }
  }

  @override
  Future<Result<domain.Project>> updateProject(domain.Project project) async {
    try {
      final existing = await _database.getProjectById(project.id);
      if (existing == null) {
        return Result.error(Exception('Project not found'));
      }
      await _database.updateProject(project.toDrift());
      return Result.ok(project);
    } catch (e, st) {
      _log.severe('Exception in updateProject', e, st);
      return Result.error(Exception('Failed to update project'));
    }
  }

  @override
  Future<Result<void>> deleteProject(String projectId) async {
    try {
      // Unassign first so the jobs survive without a dangling project_id
      // (no FK enforcement — see the app's manual-cascade convention).
      await _database.clearProjectFromJobs(projectId);
      await _database.deleteProject(projectId);
      return Result.ok(null);
    } catch (e, st) {
      _log.severe('Exception in deleteProject', e, st);
      return Result.error(Exception('Failed to delete project'));
    }
  }

  @override
  Future<Result<List<domain.Job>>> getJobsForProject(String projectId) async {
    try {
      final results = await _database.getJobsForProject(projectId);
      return Result.ok(
        results.map((row) => domain.Job.fromDrift(row)).toList(),
      );
    } catch (e, st) {
      _log.severe('Exception in getJobsForProject', e, st);
      return Result.error(Exception('Failed to get jobs for project'));
    }
  }
}
