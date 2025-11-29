import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:tala_app/data/repositories/jobs/jobs_repository.dart';

import '../../../../domain/models/job.dart';
import '../../../../utils/command.dart';
import '../../../../utils/result.dart';

class JobFormViewModel extends ChangeNotifier {
  JobFormViewModel({
    required JobsRepository jobsRepository,
    required String vehicleId,
    Job? job,
  }) : _jobsRepository = jobsRepository,
       _vehicleId = vehicleId,
       _job = job {
    addJob = Command1(_addJob);
    updateJob = Command1(_updateJob);
    fetchJob = Command1(_fetchJob);
  }
  final _log = Logger('JobFormViewModel');
  final JobsRepository _jobsRepository;

  final String _vehicleId;
  String get vehicleId => _vehicleId;
  Job? _job;
  Job? get job => _job;

  late final Command1<void, Job> addJob;
  late final Command1<void, Job> updateJob;
  late final Command1<void, (String vehicleId, String jobId)> fetchJob;

  Future<Result<void>> _addJob(Job job) async {
    final result = await _jobsRepository.addJob(vehicleId, job);

    switch (result) {
      case Error<void>():
        _log.severe('Error adding job: ${result.error}');
        return result;
      case Ok<void>():
    }

    _job = job;

    notifyListeners();
    return result;
  }

  Future<Result<void>> _updateJob(Job job) async {
    final result = await _jobsRepository.updateJob(vehicleId, job);

    switch (result) {
      case Error<Job>():
        _log.severe('Error updating job: ${result.error}');
        return result;
      case Ok<Job>():
    }

    _job = job;
    notifyListeners();
    return result;
  }

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

  Future<Result<String>> uploadJobPhoto(
    String vehicleId,
    String jobId,
    File photo,
  ) async {
    final result = await _jobsRepository.uploadJobPhoto(
      vehicleId,
      jobId,
      photo,
    );

    switch (result) {
      case Error<String>():
        _log.severe('Error uploading job photo: ${result.error}');
        return result;
      case Ok<String>():
    }

    notifyListeners();
    return result;
  }
}
