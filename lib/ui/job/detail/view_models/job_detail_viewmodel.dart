import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:tala_app/data/repositories/jobs/jobs_repository.dart';

import '../../../../domain/models/job.dart';
import '../../../../utils/command.dart';
import '../../../../utils/result.dart';

class JobDetailViewModel extends ChangeNotifier {
  JobDetailViewModel({required JobsRepository jobsRepository})
    : _jobsRepository = jobsRepository {
    fetchJob = Command1<void, (String vehicleId, String jobId)>(_fetchJob);
    removeJob = Command1<void, (String vehicleId, String jobId)>(_removeJob);
    deleteJobPhoto =
        Command1<void, (String vehicleId, String jobId, String photoId)>(
          _deleteJobPhoto,
        );
  }

  final _log = Logger('JobDetailViewModel');
  final JobsRepository _jobsRepository;

  Job? _job;
  Job? get job => _job;

  late final Command1 fetchJob;
  late final Command1 removeJob;
  late final Command1 deleteJobPhoto;

  Future<Result<void>> _fetchJob((String, String) ids) async {
    final (vehicleId, jobId) = ids;
    final result = await _jobsRepository.getJob(vehicleId, jobId);

    switch (result) {
      case Error<Job>():
        _log.severe('Error fetching job: ${result.error}');
        return result;
      case Ok<Job>():
    }

    _job = result.value;

    notifyListeners();

    return result;
  }

  Future<Result> _removeJob((String, String) ids) async {
    final (vehicleId, jobId) = ids;
    final result = await _jobsRepository.deleteJob(vehicleId, jobId);
    switch (result) {
      case Ok<void>():
        return result;
      case Error<void>():
        return result;
    }
  }

  Future<Result<void>> _deleteJobPhoto((String, String, String) ids) async {
    final (vehicleId, jobId, photoId) = ids;
    final result = await _jobsRepository.deleteJobPhoto(
      vehicleId,
      jobId,
      photoId,
    );

    return result;
  }
}
