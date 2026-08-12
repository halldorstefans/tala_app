import 'dart:io';

import '../../../domain/models/job.dart';
import '../../../utils/result.dart';

abstract class JobsRepository {
  Future<Result<Job>> getJob(String vehicleId, String jobId);
  Future<Result<List<Job>>> getJobs(String vehicleId);
  Future<Result<String>> addJob(String vehicleId, Job job);
  Future<Result<Job>> updateJob(String vehicleId, Job job);
  Future<Result<void>> deleteJob(String vehicleId, String jobId);
  /// Adds a photo attachment to the job (used by the job form's create-time
  /// multi-pick). Managing photos afterward goes through AttachmentsRepository.
  Future<Result<String>> uploadJobPhoto(
    String vehicleId,
    String jobId,
    File photo,
  );
}
