import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../../../../data/repositories/jobs/jobs_repository.dart';
import '../../../../domain/models/job.dart';
import '../../../../utils/command.dart';
import '../../../../utils/result.dart';

class JobListViewModel extends ChangeNotifier {
  JobListViewModel({
    required JobsRepository jobsRepository,
    required String vehicleId,
  }) : _jobsRepository = jobsRepository,
       _vehicleId = vehicleId {
    fetchJobs = Command1(_fetchJobs)..execute(vehicleId);
  }

  final _log = Logger('JobListViewmodel');
  final JobsRepository _jobsRepository;

  final String _vehicleId;
  String get vehicleId => _vehicleId;

  final List<Job> _jobs = <Job>[];
  List<Job> get jobs => _jobs;

  late Command1<void, String> fetchJobs;

  Future<Result<void>> _fetchJobs(String vehicleId) async {
    final result = await _jobsRepository.getJobs(vehicleId);

    switch (result) {
      case Error<List<Job>>():
        _log.severe('Error fetching jobs: ${result.error}');
        return result;
      case Ok<List<Job>>():
    }

    _jobs.addAll(result.value);

    return result;
  }
}
