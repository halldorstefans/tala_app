import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:tala_app/data/repositories/jobs/jobs_repository.dart';
import 'package:tala_app/data/repositories/parts/parts_repository.dart';

import '../../../../domain/models/job.dart';
import '../../../../domain/models/job_part.dart';
import '../../../../domain/models/part.dart';
import '../../../../utils/command.dart';
import '../../../../utils/photo_compressor.dart';
import '../../../../utils/result.dart';

class JobDetailViewModel extends ChangeNotifier {
  JobDetailViewModel({
    required JobsRepository jobsRepository,
    required PartsRepository partsRepository,
    PhotoCompressor? compressor,
  }) : _jobsRepository = jobsRepository,
       _partsRepository = partsRepository,
       _compressor = compressor ?? defaultPhotoCompressor {
    fetchJob = Command1<void, (String vehicleId, String jobId)>(_fetchJob);
    removeJob = Command1<void, (String vehicleId, String jobId)>(_removeJob);
    deleteJobPhoto =
        Command1<void, (String vehicleId, String jobId, String photoPath)>(
          _deleteJobPhoto,
        );
  }

  final _log = Logger('JobDetailViewModel');
  final JobsRepository _jobsRepository;
  final PartsRepository _partsRepository;
  final PhotoCompressor _compressor;

  Job? _job;
  Job? get job => _job;

  final List<JobPartLine> _jobParts = <JobPartLine>[];
  List<JobPartLine> get jobParts => _jobParts;

  /// The full parts catalogue, for reusing an existing part in the add-part
  /// sheet. Loaded on demand via [loadCatalogue].
  final List<Part> _catalogue = <Part>[];
  List<Part> get catalogue => _catalogue;

  double _partsTotal = 0;

  /// Cost breakdown: `other` is the job's own (non-part) cost, `parts` is the
  /// sum of the linked parts, `total` is both.
  double get otherCost => _job?.cost ?? 0;
  double get partsTotal => _partsTotal;
  double get totalCost => otherCost + _partsTotal;

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
    await _loadParts(jobId);
    notifyListeners();

    return result;
  }

  Future<void> _loadParts(String jobId) async {
    final partsResult = await _partsRepository.getJobParts(jobId);
    if (partsResult is Ok<List<JobPartLine>>) {
      _jobParts
        ..clear()
        ..addAll(partsResult.value);
    }
    final totalResult = await _partsRepository.partsTotalForJob(jobId);
    if (totalResult is Ok<double>) {
      _partsTotal = totalResult.value;
    }
  }

  /// Adds a part to the current job. When [part] has an empty id it is created
  /// in the catalogue first (with any [photos]); otherwise an existing part is
  /// reused. Reloads the parts list on success.
  Future<Result<void>> addPart({
    required Part part,
    List<File> photos = const [],
    double? unitCost,
    int quantity = 1,
    DateTime? purchaseDate,
  }) async {
    final job = _job;
    if (job == null) return Result.error(Exception('No job loaded'));

    var partId = part.id;
    if (partId.isEmpty) {
      final addResult = await _partsRepository.addPart(part);
      switch (addResult) {
        case Error<String>():
          _log.severe('Error creating part: ${addResult.error}');
          return addResult;
        case Ok<String>():
          partId = addResult.value;
      }
      for (final photo in photos) {
        final compressed = await _compressor(photo) ?? photo;
        await _partsRepository.uploadPartPhoto(partId, compressed);
      }
    }

    final linkResult = await _partsRepository.addJobPart(
      JobPart(
        id: '',
        jobId: job.id,
        partId: partId,
        unitCost: unitCost,
        quantity: quantity,
        purchaseDate: purchaseDate,
      ),
    );
    if (linkResult is Error<String>) {
      _log.severe('Error linking part to job: ${linkResult.error}');
      return linkResult;
    }

    await _loadParts(job.id);
    notifyListeners();
    return const Result.ok(null);
  }

  /// Loads the parts catalogue so the add-part sheet can offer existing parts.
  Future<void> loadCatalogue() async {
    final result = await _partsRepository.getParts();
    if (result is Ok<List<Part>>) {
      _catalogue
        ..clear()
        ..addAll(result.value);
      notifyListeners();
    }
  }

  /// Reloads the parts list + total (e.g. after returning from part detail,
  /// where a part may have been deleted).
  Future<void> reloadParts() async {
    final job = _job;
    if (job == null) return;
    await _loadParts(job.id);
    notifyListeners();
  }

  /// Updates the per-use fields (unit cost, quantity, purchase date) of a
  /// part already on the job, and reloads.
  Future<Result<void>> updateJobPart(JobPart jobPart) async {
    final job = _job;
    if (job == null) return Result.error(Exception('No job loaded'));

    final result = await _partsRepository.updateJobPart(jobPart);
    if (result is Error<JobPart>) {
      _log.severe('Error updating job part: ${result.error}');
      return Result.error(result.error);
    }
    await _loadParts(job.id);
    notifyListeners();
    return const Result.ok(null);
  }

  Future<Result<void>> removePart(String jobPartId) async {
    final job = _job;
    if (job == null) return Result.error(Exception('No job loaded'));

    final result = await _partsRepository.deleteJobPart(jobPartId);
    if (result is Error<void>) {
      _log.severe('Error removing part from job: ${result.error}');
      return result;
    }
    await _loadParts(job.id);
    notifyListeners();
    return const Result.ok(null);
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
    final (vehicleId, jobId, photoPath) = ids;
    final result = await _jobsRepository.deleteJobPhoto(
      vehicleId,
      jobId,
      photoPath,
    );

    return result;
  }
}
