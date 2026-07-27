import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:tala_app/data/repositories/jobs/jobs_repository.dart';
import 'package:tala_app/data/repositories/projects/projects_repository.dart';
import 'package:tala_app/data/services/shared_preferences_service.dart';

import '../../../../domain/models/job.dart';
import '../../../../domain/models/project.dart';
import '../../../../utils/command.dart';
import '../../../../utils/photo_compressor.dart';
import '../../../../utils/result.dart';

class JobFormViewModel extends ChangeNotifier {
  JobFormViewModel({
    required JobsRepository jobsRepository,
    required String vehicleId,
    Job? job,
    PhotoCompressor? compressor,
    SharedPreferencesService? preferences,
    ProjectsRepository? projectsRepository,
  }) : _jobsRepository = jobsRepository,
       _vehicleId = vehicleId,
       _job = job,
       _compressor = compressor ?? defaultPhotoCompressor,
       _preferences = preferences,
       _projectsRepository = projectsRepository {
    addJob = Command1(_addJob);
    updateJob = Command1(_updateJob);
    fetchJob = Command1(_fetchJob);
    loadDefaultCategory = Command0(_loadDefaultCategory);
    loadProjects = Command0(_loadProjects);
  }
  final _log = Logger('JobFormViewModel');
  final JobsRepository _jobsRepository;
  final PhotoCompressor _compressor;
  final SharedPreferencesService? _preferences;
  final ProjectsRepository? _projectsRepository;

  String? _defaultCategory;
  String? get defaultCategory => _defaultCategory;

  /// Projects this job can be assigned to. Empty when no projects repository
  /// is wired (e.g. some tests) — the form then hides the project field.
  final List<Project> _projects = <Project>[];
  List<Project> get projects => _projects;

  int _uploadedCount = 0;
  int _uploadTotal = 0;
  int get uploadedCount => _uploadedCount;
  int get uploadTotal => _uploadTotal;

  final String _vehicleId;
  String get vehicleId => _vehicleId;
  Job? _job;
  Job? get job => _job;

  late final Command1<String, Job> addJob;
  late final Command1<void, Job> updateJob;
  late final Command1<void, (String vehicleId, String jobId)> fetchJob;
  late final Command0<void> loadDefaultCategory;
  late final Command0<void> loadProjects;

  Future<Result<void>> _loadDefaultCategory() async {
    final prefs = _preferences;
    if (prefs == null) return const Result.ok(null);
    try {
      _defaultCategory = await prefs.getDefaultJobCategory();
      notifyListeners();
      return const Result.ok(null);
    } on Exception catch (e) {
      _log.warning('Failed to load default job category', e);
      return Result.error(e);
    }
  }

  Future<Result<void>> _loadProjects() async {
    final repo = _projectsRepository;
    if (repo == null) return const Result.ok(null);
    final result = await repo.getProjects(_vehicleId);
    switch (result) {
      case Error<List<Project>>():
        _log.warning('Failed to load projects for form', result.error);
        return result;
      case Ok<List<Project>>():
        _projects
          ..clear()
          ..addAll(result.value);
        notifyListeners();
        return const Result.ok(null);
    }
  }

  Future<Result<String>> _addJob(Job job) async {
    final result = await _jobsRepository.addJob(vehicleId, job);

    switch (result) {
      case Error<String>():
        _log.severe('Error adding job: ${result.error}');
        return result;
      case Ok<String>():
        _job = job.copyWith(id: result.value, vehicleId: vehicleId);
        // Persist this category as the new default so the next new job
        // prefills it. Only on successful add (not update) — the default
        // should reflect what the user usually starts with.
        final prefs = _preferences;
        if (prefs != null) {
          unawaited(
            prefs.setDefaultJobCategory(job.category).catchError((Object e) {
              _log.warning('Failed to save default job category', e);
            }),
          );
        }
    }

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

  Future<Result<void>> uploadJobPhotos(
    String vehicleId,
    String jobId,
    List<File> photos,
  ) async {
    if (photos.isEmpty) return Result.ok(null);

    _uploadedCount = 0;
    _uploadTotal = photos.length;
    notifyListeners();

    Exception? firstError;
    for (final photo in photos) {
      final compressed = await _compressor(photo);
      final toUpload = compressed ?? photo;

      final result = await _jobsRepository.uploadJobPhoto(
        vehicleId,
        jobId,
        toUpload,
      );
      if (result is Error<String>) {
        _log.severe('Error uploading job photo: ${result.error}');
        firstError ??= result.error;
      }

      _uploadedCount++;
      notifyListeners();
    }

    _uploadedCount = 0;
    _uploadTotal = 0;
    notifyListeners();

    return firstError != null ? Result.error(firstError) : Result.ok(null);
  }
}
