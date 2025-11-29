import 'dart:io';

import 'package:logging/logging.dart';

import '../../models/job_api_model.dart';
import '../../../domain/models/job.dart';
import '../../../utils/result.dart';
import '../../services/tala_api/api_client.dart';
import 'jobs_repository.dart';

class JobsRepositoryRemote extends JobsRepository {
  JobsRepositoryRemote({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;
  final _log = Logger('JobsRepositoryRemote');

  @override
  Future<Result<Job>> getJob(String vehicleId, String jobId) async {
    Job record;
    try {
      final response = await _apiClient.getJob(vehicleId, jobId);
      switch (response) {
        case Ok<JobApiModel>():
          if (response.value.vehicleId != vehicleId) {
            _log.warning(
              'Vehicle ID mismatch: expected $vehicleId but got ${response.value.vehicleId}',
            );
            return Result.error(Exception('Job not found'));
          }

          record = Job(
            id: response.value.id,
            vehicleId: response.value.vehicleId,
            title: response.value.title,
            startDate: response.value.startDate,
            completionDate: response.value.completionDate,
            status: response.value.status,
            category: response.value.category,
            odometer: response.value.odometer,
            description: response.value.description,
            cost: response.value.cost,
          );

        case Error<JobApiModel>():
          _log.warning(
            'Failed to get job $jobId for vehicle $vehicleId',
            response.error,
          );
          return Result.error(response.error);
      }
    } catch (e, st) {
      _log.severe('Exception in getJob', e, st);
      return Result.error(Exception('Failed to get job'));
    }

    try {
      final photoResponse = await _apiClient.getJobPhotos(vehicleId, jobId);
      switch (photoResponse) {
        case Ok<List<JobPhotosApiModel>>():
          record.photoUrls = photoResponse.value
              .map((apiModel) => apiModel.photoUrl)
              .toList();
        case Error<List<JobPhotosApiModel>>():
          _log.info(
            'No photo found for job $jobId of vehicle $vehicleId',
            photoResponse.error,
          );
      }
      return Result.ok(record);
    } catch (e, st) {
      _log.severe('Exception in getJob photo fetch', e, st);
      return Result.error(Exception('Failed to get job photo'));
    }
  }

  @override
  Future<Result<List<Job>>> getJobs(String vehicleId) async {
    try {
      final response = await _apiClient.getJobs(vehicleId);
      switch (response) {
        case Ok<List<JobApiModel>>():
          if (response.value.isEmpty) {
            return Result.ok([]);
          }
          final records = response.value
              .where((apiModel) => apiModel.vehicleId == vehicleId)
              .map(
                (apiModel) => Job(
                  id: apiModel.id,
                  vehicleId: apiModel.vehicleId,
                  title: apiModel.title,
                  startDate: apiModel.startDate,
                  completionDate: apiModel.completionDate,
                  status: apiModel.status,
                  category: apiModel.category,
                  odometer: apiModel.odometer,
                  description: apiModel.description,
                  cost: apiModel.cost,
                ),
              )
              .toList();
          return Result.ok(records);
        case Error<List<JobApiModel>>():
          _log.warning(
            'Failed to get jobs for vehicle $vehicleId',
            response.error,
          );
          return Result.error(response.error);
      }
    } catch (e, st) {
      _log.severe('Exception in getJobs', e, st);
      return Result.error(Exception('Failed to get jobs'));
    }
  }

  @override
  Future<Result<void>> addJob(String vehicleId, Job job) async {
    try {
      final jobApiModel = JobApiModel(
        id: job.id,
        vehicleId: job.vehicleId,
        title: job.title,
        startDate: job.startDate,
        completionDate: job.completionDate,
        status: job.status,
        category: job.category,
        odometer: job.odometer,
        description: job.description,
        cost: job.cost,
      );
      final response = await _apiClient.addJob(vehicleId, jobApiModel);
      switch (response) {
        case Ok<void>():
          return Result.ok(null);
        case Error<void>():
          _log.warning(
            'Failed to add job ${job.id} for vehicle $vehicleId',
            response.error,
          );
          return Result.error(response.error);
      }
    } catch (e, st) {
      _log.severe('Exception in addJob', e, st);
      return Result.error(Exception('Failed to add job'));
    }
  }

  @override
  Future<Result<Job>> updateJob(String vehicleId, Job job) async {
    try {
      final jobApiModel = JobApiModel(
        id: job.id,
        vehicleId: job.vehicleId,
        title: job.title,
        startDate: job.startDate,
        completionDate: job.completionDate,
        status: job.status,
        category: job.category,
        odometer: job.odometer,
        description: job.description,
        cost: job.cost,
      );
      final response = await _apiClient.updateJob(vehicleId, jobApiModel);
      switch (response) {
        case Ok<JobApiModel>():
          final updatedRecord = Job(
            id: response.value.id,
            vehicleId: response.value.vehicleId,
            title: response.value.title,
            startDate: response.value.startDate,
            completionDate: response.value.completionDate,
            status: response.value.status,
            category: response.value.category,
            odometer: response.value.odometer,
            description: response.value.description,
            cost: response.value.cost,
          );
          return Result.ok(updatedRecord);
        case Error<JobApiModel>():
          _log.warning(
            'Failed to update job ${job.id} for vehicle $vehicleId',
            response.error,
          );
          return Result.error(response.error);
      }
    } catch (e, st) {
      _log.severe('Exception in updateJob', e, st);
      return Result.error(Exception('Failed to update job'));
    }
  }

  @override
  Future<Result<void>> deleteJob(String vehicleId, String jobId) async {
    try {
      final response = await _apiClient.deleteJob(vehicleId, jobId);
      switch (response) {
        case Ok<void>():
          return Result.ok(null);
        case Error<void>():
          _log.warning(
            'Failed to delete job $jobId for vehicle $vehicleId',
            response.error,
          );
          return Result.error(response.error);
      }
    } catch (e, st) {
      _log.severe('Exception in deleteJob', e, st);
      return Result.error(Exception('Failed to delete job'));
    }
  }

  @override
  Future<Result<String>> uploadJobPhoto(
    String vehicleId,
    String jobId,
    File photo,
  ) async {
    try {
      final response = await _apiClient.uploadJobPhoto(vehicleId, jobId, photo);
      switch (response) {
        case Ok<String>():
          return Result.ok(response.value);
        case Error<String>():
          _log.warning(
            'Failed to upload photo for job $jobId of vehicle $vehicleId',
            response.error,
          );
          return Result.error(response.error);
      }
    } catch (e, st) {
      _log.severe('Exception in uploadJobPhoto', e, st);
      return Result.error(Exception('Failed to upload job photo'));
    }
  }

  @override
  Future<Result<void>> deleteJobPhoto(
    String vehicleId,
    String jobId,
    String photoId,
  ) async {
    return _apiClient.deleteJobPhoto(vehicleId, jobId, photoId);
  }
}
