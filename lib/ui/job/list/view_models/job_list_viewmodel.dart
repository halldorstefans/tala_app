import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../../../../data/repositories/jobs/jobs_repository.dart';
import '../../../../data/repositories/parts/parts_repository.dart';
import '../../../../domain/models/job.dart';
import '../../../../domain/models/progress_status.dart';
import '../../../../utils/command.dart';
import '../../../../utils/result.dart';

typedef JobStats = ({
  int planned,
  int inProgress,
  int completed,
  double totalCost,
});

/// Aggregate status counts + total cost over [jobs]. Shared by the job list
/// and the project detail view so both compute the summary the same way.
/// Unknown statuses are counted in none of the buckets but their cost still
/// contributes to the total.
JobStats computeJobStats(Iterable<Job> jobs) {
  var planned = 0;
  var inProgress = 0;
  var completed = 0;
  var totalCost = 0.0;
  for (final j in jobs) {
    switch (j.status) {
      case ProgressStatus.planned:
        planned++;
      case ProgressStatus.inProgress:
        inProgress++;
      case ProgressStatus.completed:
        completed++;
      case null:
        break; // unknown/unset status: counted in no bucket, cost still adds
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

class JobListViewModel extends ChangeNotifier {
  JobListViewModel({
    required JobsRepository jobsRepository,
    required String vehicleId,
    PartsRepository? partsRepository,
  }) : _jobsRepository = jobsRepository,
       _vehicleId = vehicleId,
       _partsRepository = partsRepository {
    fetchJobs = Command1(_fetchJobs)..execute(vehicleId);
    toggleDone = Command1(_toggleDone);
  }

  final _log = Logger('JobListViewmodel');
  final JobsRepository _jobsRepository;

  /// Optional: when wired, the vehicle's parts total is folded into
  /// [totalCostWithParts]. Left null where a parts total isn't shown.
  final PartsRepository? _partsRepository;

  final String _vehicleId;
  String get vehicleId => _vehicleId;

  final List<Job> _jobs = <Job>[];
  List<Job> get jobs => _jobs;

  double _partsTotal = 0;

  /// The vehicle's total spend: jobs' own ("other") cost plus all parts.
  /// Equals `stats.totalCost` when no parts repository is wired.
  double get totalCostWithParts => stats.totalCost + _partsTotal;

  /// Jobs currently on the bench. `_jobs` is already ordered most-recent
  /// first, so no extra sort is needed. Backs the "Active Jobs" section on
  /// the vehicle detail screen.
  List<Job> get inProgressJobs =>
      _jobs.where((j) => j.status == ProgressStatus.inProgress).toList();

  Set<ProgressStatus> _statusFilter = {};
  Set<String> _categoryFilter = {};
  DateTimeRange? _dateRange;

  Set<ProgressStatus> get statusFilter => _statusFilter;
  Set<String> get categoryFilter => _categoryFilter;
  DateTimeRange? get dateRange => _dateRange;

  bool get hasActiveFilters =>
      _statusFilter.isNotEmpty ||
      _categoryFilter.isNotEmpty ||
      _dateRange != null;

  void setStatusFilter(Set<ProgressStatus> value) {
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

  JobStats get stats => computeJobStats(_jobs);

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
  late final Command1<void, Job> toggleDone;

  /// Flips a job between "completed" and "in progress" from the list view.
  ///
  /// Marking complete stamps `completionDate = now` if the job didn't
  /// already have one, so the card can show a real date immediately.
  /// Unmarking flips the status back to in-progress; the previously
  /// stored `completionDate` is left in place (harmless — `JobCard` only
  /// surfaces it when status == completed).
  ///
  /// [Job.normalized] handles the "startDate can't be after completionDate
  /// when completed" invariant.
  Future<Result<void>> _toggleDone(Job job) async {
    final markingDone = job.status != ProgressStatus.completed;
    final proposed = job.copyWith(
      status: markingDone ? ProgressStatus.completed : ProgressStatus.inProgress,
      completionDate: markingDone
          ? (job.completionDate ?? DateTime.now())
          : job.completionDate,
    );
    final result = await _jobsRepository.updateJob(
      _vehicleId,
      proposed.normalized(),
    );
    switch (result) {
      case Error<Job>():
        _log.severe('Error toggling job done state: ${result.error}');
        return result;
      case Ok<Job>():
        await _fetchJobs(_vehicleId);
        return const Result.ok(null);
    }
  }

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

    final partsRepo = _partsRepository;
    if (partsRepo != null) {
      final totalResult = await partsRepo.partsTotalForVehicle(_vehicleId);
      if (totalResult is Ok<double>) _partsTotal = totalResult.value;
    }

    notifyListeners();

    return result;
  }
}
