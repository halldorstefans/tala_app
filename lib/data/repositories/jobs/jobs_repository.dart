import 'dart:io';

import '../../../domain/models/job.dart';
import '../../../utils/result.dart';

abstract class JobsRepository {
  Future<Result<Job>> getJob(String vehicleId, String jobId);
  Future<Result<List<Job>>> getJobs(String vehicleId);
  Future<Result<void>> addJob(String vehicleId, Job job);
  Future<Result<Job>> updateJob(String vehicleId, Job job);
  Future<Result<void>> deleteJob(String vehicleId, String jobId);
  Future<Result<String>> uploadJobPhoto(
    String vehicleId,
    String jobId,
    File photo,
  );
  Future<Result<void>> deleteJobPhoto(
    String vehicleId,
    String jobId,
    String photoId,
  );
}
