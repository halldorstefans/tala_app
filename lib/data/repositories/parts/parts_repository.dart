import 'dart:io';

import '../../../domain/models/job_part.dart';
import '../../../domain/models/part.dart';
import '../../../utils/result.dart';

/// Parts are a global, reusable catalogue; a [JobPart] links a part to a job
/// with the per-use details (unit cost, quantity, purchase date). Photos live
/// on the part itself. "Parts for a vehicle" is derived from usage.
abstract class PartsRepository {
  // Catalogue
  Future<Result<List<Part>>> getParts();
  Future<Result<Part>> getPart(String partId);
  Future<Result<String>> addPart(Part part);
  Future<Result<Part>> updatePart(Part part);

  /// Deletes the part, its job links, and its photos (files + rows).
  Future<Result<void>> deletePart(String partId);

  // Part photos. Adding is used by the create-time flows (part form, add-part
  // sheet); managing photos afterward goes through AttachmentsRepository.
  Future<Result<String>> uploadPartPhoto(String partId, File photo);

  // Job links
  Future<Result<List<JobPartLine>>> getJobParts(String jobId);
  Future<Result<String>> addJobPart(JobPart jobPart);
  Future<Result<JobPart>> updateJobPart(JobPart jobPart);
  Future<Result<void>> deleteJobPart(String jobPartId);

  // Usage / totals
  Future<Result<List<Part>>> getPartsForVehicle(String vehicleId);

  /// Distinct parts used across the vehicle's jobs, each with its total
  /// quantity and total spent. Sorted by total spent, highest first.
  Future<Result<List<PartUsage>>> getPartsUsageForVehicle(String vehicleId);

  Future<Result<double>> partsTotalForJob(String jobId);
  Future<Result<double>> partsTotalForVehicle(String vehicleId);
}
