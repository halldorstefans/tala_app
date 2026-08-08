import 'dart:io';

import '../../../domain/models/job_part.dart';
import '../../../domain/models/part.dart';
import '../../../utils/result.dart';
import 'parts_repository.dart';

/// Stub for a future sync backend. The Go/Postgres API has no parts endpoints
/// yet, so every call throws until the remote layer is built. `providersLocal`
/// is the active wiring.
class PartsRepositoryRemote implements PartsRepository {
  static Never _unimplemented() =>
      throw UnimplementedError('PartsRepositoryRemote is not implemented');

  @override
  Future<Result<List<Part>>> getParts() async => _unimplemented();

  @override
  Future<Result<Part>> getPart(String partId) async => _unimplemented();

  @override
  Future<Result<String>> addPart(Part part) async => _unimplemented();

  @override
  Future<Result<Part>> updatePart(Part part) async => _unimplemented();

  @override
  Future<Result<void>> deletePart(String partId) async => _unimplemented();

  @override
  Future<Result<String>> uploadPartPhoto(String partId, File photo) async =>
      _unimplemented();

  @override
  Future<Result<void>> deletePartPhoto(String partId, String photoPath) async =>
      _unimplemented();

  @override
  Future<Result<List<JobPartLine>>> getJobParts(String jobId) async =>
      _unimplemented();

  @override
  Future<Result<String>> addJobPart(JobPart jobPart) async => _unimplemented();

  @override
  Future<Result<JobPart>> updateJobPart(JobPart jobPart) async =>
      _unimplemented();

  @override
  Future<Result<void>> deleteJobPart(String jobPartId) async =>
      _unimplemented();

  @override
  Future<Result<List<Part>>> getPartsForVehicle(String vehicleId) async =>
      _unimplemented();

  @override
  Future<Result<List<PartUsage>>> getPartsUsageForVehicle(
    String vehicleId,
  ) async => _unimplemented();

  @override
  Future<Result<double>> partsTotalForJob(String jobId) async =>
      _unimplemented();

  @override
  Future<Result<double>> partsTotalForVehicle(String vehicleId) async =>
      _unimplemented();
}
