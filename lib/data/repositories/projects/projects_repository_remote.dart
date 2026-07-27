import '../../../domain/models/job.dart';
import '../../../domain/models/project.dart';
import '../../../utils/result.dart';
import 'projects_repository.dart';

/// Stub for a future sync backend. The Go/Postgres API has no project
/// endpoints yet (the schema is unimplemented), so every call throws until
/// the remote layer is built. `providersLocal` is the active wiring.
class ProjectsRepositoryRemote implements ProjectsRepository {
  static Never _unimplemented() =>
      throw UnimplementedError('ProjectsRepositoryRemote is not implemented');

  @override
  Future<Result<List<Project>>> getProjects(String vehicleId) async =>
      _unimplemented();

  @override
  Future<Result<Project>> getProject(String projectId) async =>
      _unimplemented();

  @override
  Future<Result<String>> addProject(Project project) async => _unimplemented();

  @override
  Future<Result<Project>> updateProject(Project project) async =>
      _unimplemented();

  @override
  Future<Result<void>> deleteProject(String projectId) async =>
      _unimplemented();

  @override
  Future<Result<List<Job>>> getJobsForProject(String projectId) async =>
      _unimplemented();
}
