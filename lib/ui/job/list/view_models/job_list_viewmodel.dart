import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../../../../data/repositories/jobs/jobs_repository.dart';
import '../../../../domain/models/job.dart';
import '../../../../domain/models/job_status.dart';
import '../../../../utils/command.dart';
import '../../../../utils/result.dart';

typedef JobStats = ({
  int planned,
  int inProgress,
  int completed,
  double totalCost,
});

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

  Set<String> _statusFilter = {};
  Set<String> _categoryFilter = {};
  DateTimeRange? _dateRange;

  Set<String> get statusFilter => _statusFilter;
  Set<String> get categoryFilter => _categoryFilter;
  DateTimeRange? get dateRange => _dateRange;

  bool get hasActiveFilters =>
      _statusFilter.isNotEmpty ||
      _categoryFilter.isNotEmpty ||
      _dateRange != null;

  void setStatusFilter(Set<String> value) {
    _statusFilter = value;
    notifyListeners();
  }

  void setCategoryFilter(Set<String> value) {
    _categoryFilter = value;
    notifyListeners();
  }

  void setDateRange(DateTimeRange? value) {
    _dateRange = value;
    notifyListeners();
  }

  void clearFilters() {
    _statusFilter = {};
    _categoryFilter = {};
    _dateRange = null;
    notifyListeners();
  }

  JobStats get stats {
    var planned = 0;
    var inProgress = 0;
    var completed = 0;
    var totalCost = 0.0;
    for (final j in _jobs) {
      switch (j.status) {
        case JobStatus.planned:
          planned++;
        case JobStatus.inProgress:
          inProgress++;
        case JobStatus.completed:
          completed++;
      }
      if (j.cost != null) totalCost += j.cost!;
    }
    return (
      planned: planned,
      inProgress: inProgress,
      completed: completed,
      totalCost: totalCost,
    );
  }

  List<Job> get filteredJobs {
    if (!hasActiveFilters) return _jobs;
    return _jobs.where((j) {
      if (_statusFilter.isNotEmpty && !_statusFilter.contains(j.status)) {
        return false;
      }
      if (_categoryFilter.isNotEmpty &&
          !_categoryFilter.contains(j.category)) {
        return false;
      }
      if (_dateRange != null) {
        final start = j.startDate;
        if (start == null) return false;
        final day = DateTime(start.year, start.month, start.day);
        final rangeStart = DateTime(
          _dateRange!.start.year,
          _dateRange!.start.month,
          _dateRange!.start.day,
        );
        final rangeEnd = DateTime(
          _dateRange!.end.year,
          _dateRange!.end.month,
          _dateRange!.end.day,
        );
        if (day.isBefore(rangeStart) || day.isAfter(rangeEnd)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  late Command1<void, String> fetchJobs;

  Future<Result<void>> _fetchJobs(String vehicleId) async {
    final result = await _jobsRepository.getJobs(vehicleId);

    switch (result) {
      case Error<List<Job>>():
        _log.severe('Error fetching jobs: ${result.error}');
        return result;
      case Ok<List<Job>>():
    }

    _jobs
      ..clear()
      ..addAll(result.value);
    notifyListeners();

    return result;
  }
}
