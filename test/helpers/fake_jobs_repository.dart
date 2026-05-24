import 'dart:io';

import 'package:tala_app/data/repositories/jobs/jobs_repository.dart';
import 'package:tala_app/domain/models/job.dart';
import 'package:tala_app/utils/result.dart';

class FakeJobsRepository implements JobsRepository {
  final Map<String, Job> _jobs = {};
  Exception? error;
  String nextId = 'job-1';

  Job? lastAdded;
  Job? lastUpdated;

  void seed(Job job) {
    _jobs[job.id] = job;
  }

  @override
  Future<Result<Job>> getJob(String vehicleId, String jobId) async {
    if (error != null) return Result.error(error!);
    final job = _jobs[jobId];
    if (job == null) {
      return Result.error(Exception('not found'));
    }
    return Result.ok(job);
  }

  @override
  Future<Result<List<Job>>> getJobs(String vehicleId) async {
    if (error != null) return Result.error(error!);
    return Result.ok(
      _jobs.values.where((j) => j.vehicleId == vehicleId).toList(),
    );
  }

  @override
  Future<Result<String>> addJob(String vehicleId, Job job) async {
    if (error != null) return Result.error(error!);
    lastAdded = job;
    _jobs[nextId] = Job(
      id: nextId,
      vehicleId: vehicleId,
      title: job.title,
      startDate: job.startDate,
      completionDate: job.completionDate,
      odometer: job.odometer,
      category: job.category,
      status: job.status,
      description: job.description,
      cost: job.cost,
    );
    return Result.ok(nextId);
  }

  @override
  Future<Result<Job>> updateJob(String vehicleId, Job job) async {
    if (error != null) return Result.error(error!);
    lastUpdated = job;
    _jobs[job.id] = job;
    return Result.ok(job);
  }

  @override
  Future<Result<void>> deleteJob(String vehicleId, String jobId) async {
    if (error != null) return Result.error(error!);
    _jobs.remove(jobId);
    return Result.ok(null);
  }

  @override
  Future<Result<String>> uploadJobPhoto(
    String vehicleId,
    String jobId,
    File photo,
  ) async {
    if (error != null) return Result.error(error!);
    return Result.ok('photos/test.jpg');
  }

  @override
  Future<Result<void>> deleteJobPhoto(
    String vehicleId,
    String jobId,
    String photoPath,
  ) async {
    if (error != null) return Result.error(error!);
    return Result.ok(null);
  }
}
