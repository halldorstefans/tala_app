import '../../../domain/models/job.dart';
import '../../../domain/models/project.dart';
import '../../../utils/result.dart';

/// Projects group a vehicle's jobs into phases (e.g. "Disassembly"). A job
/// belongs to at most one project via `Job.projectId`, so assignment is a job
/// mutation on [JobsRepository] — this repository owns the projects themselves
/// and the read side of "which jobs are in this project".
abstract class ProjectsRepository {
  Future<Result<List<Project>>> getProjects(String vehicleId);
  Future<Result<Project>> getProject(String projectId);
  Future<Result<String>> addProject(Project project);
  Future<Result<Project>> updateProject(Project project);

  /// Deletes the project and unassigns its jobs (they survive, unlinked).
  Future<Result<void>> deleteProject(String projectId);

  Future<Result<List<Job>>> getJobsForProject(String projectId);
}
