import 'dart:io';

import 'package:tala_app/data/repositories/parts/parts_repository.dart';
import 'package:tala_app/domain/models/job_part.dart';
import 'package:tala_app/domain/models/part.dart';
import 'package:tala_app/utils/app_exception.dart';
import 'package:tala_app/utils/result.dart';

/// In-memory fake. Note: [getPartsForVehicle] / [partsTotalForVehicle] can't
/// filter by vehicle (no job→vehicle map here) — they operate over all seeded
/// job-parts, which suits single-vehicle unit tests.
class FakePartsRepository implements PartsRepository {
  final Map<String, Part> _parts = {};
  final List<JobPart> _jobParts = [];

  Exception? error;
  String nextPartId = 'part-1';
  String nextJobPartId = 'jobpart-1';

  Part? lastAddedPart;
  Part? lastUpdatedPart;
  String? lastDeletedPart;
  JobPart? lastAddedJobPart;
  JobPart? lastUpdatedJobPart;
  String? lastDeletedJobPart;
  final List<File> uploadedPhotos = [];

  void seedPart(Part part) => _parts[part.id] = part;
  void seedJobPart(JobPart jobPart) => _jobParts.add(jobPart);

  @override
  Future<Result<List<Part>>> getParts() async {
    if (error != null) return Result.error(error!);
    return Result.ok(_parts.values.toList());
  }

  @override
  Future<Result<Part>> getPart(String partId) async {
    if (error != null) return Result.error(error!);
    final part = _parts[partId];
    if (part == null) return Result.error(const NotFoundException('Part'));
    return Result.ok(part);
  }

  @override
  Future<Result<String>> addPart(Part part) async {
    if (error != null) return Result.error(error!);
    lastAddedPart = part;
    _parts[nextPartId] = part.copyWith(id: nextPartId);
    return Result.ok(nextPartId);
  }

  @override
  Future<Result<Part>> updatePart(Part part) async {
    if (error != null) return Result.error(error!);
    lastUpdatedPart = part;
    _parts[part.id] = part;
    return Result.ok(part);
  }

  @override
  Future<Result<void>> deletePart(String partId) async {
    if (error != null) return Result.error(error!);
    lastDeletedPart = partId;
    _parts.remove(partId);
    _jobParts.removeWhere((jp) => jp.partId == partId);
    return Result.ok(null);
  }

  @override
  Future<Result<String>> uploadPartPhoto(String partId, File photo) async {
    if (error != null) return Result.error(error!);
    uploadedPhotos.add(photo);
    return Result.ok('photos/test.jpg');
  }

  @override
  Future<Result<List<JobPartLine>>> getJobParts(String jobId) async {
    if (error != null) return Result.error(error!);
    final lines = <JobPartLine>[];
    for (final link in _jobParts.where((jp) => jp.jobId == jobId)) {
      final part = _parts[link.partId];
      if (part == null) continue;
      lines.add((link: link, part: part));
    }
    return Result.ok(lines);
  }

  @override
  Future<Result<String>> addJobPart(JobPart jobPart) async {
    if (error != null) return Result.error(error!);
    lastAddedJobPart = jobPart;
    _jobParts.add(jobPart.copyWith(id: nextJobPartId));
    return Result.ok(nextJobPartId);
  }

  @override
  Future<Result<JobPart>> updateJobPart(JobPart jobPart) async {
    if (error != null) return Result.error(error!);
    lastUpdatedJobPart = jobPart;
    final i = _jobParts.indexWhere((jp) => jp.id == jobPart.id);
    if (i >= 0) _jobParts[i] = jobPart;
    return Result.ok(jobPart);
  }

  @override
  Future<Result<void>> deleteJobPart(String jobPartId) async {
    if (error != null) return Result.error(error!);
    lastDeletedJobPart = jobPartId;
    _jobParts.removeWhere((jp) => jp.id == jobPartId);
    return Result.ok(null);
  }

  @override
  Future<Result<List<Part>>> getPartsForVehicle(String vehicleId) async {
    if (error != null) return Result.error(error!);
    final seen = <String>{};
    final result = <Part>[];
    for (final link in _jobParts) {
      if (!seen.add(link.partId)) continue;
      final part = _parts[link.partId];
      if (part != null) result.add(part);
    }
    return Result.ok(result);
  }

  @override
  Future<Result<List<PartUsage>>> getPartsUsageForVehicle(
    String vehicleId,
  ) async {
    if (error != null) return Result.error(error!);
    final quantities = <String, int>{};
    final spent = <String, double>{};
    for (final link in _jobParts) {
      quantities[link.partId] = (quantities[link.partId] ?? 0) + link.quantity;
      spent[link.partId] = (spent[link.partId] ?? 0) + link.totalCost;
    }
    final usages = <PartUsage>[];
    for (final partId in quantities.keys) {
      final part = _parts[partId];
      if (part == null) continue;
      usages.add((
        part: part,
        totalQuantity: quantities[partId]!,
        totalSpent: spent[partId] ?? 0,
      ));
    }
    usages.sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
    return Result.ok(usages);
  }

  @override
  Future<Result<double>> partsTotalForJob(String jobId) async {
    if (error != null) return Result.error(error!);
    final total = _jobParts
        .where((jp) => jp.jobId == jobId)
        .fold<double>(0, (sum, jp) => sum + jp.totalCost);
    return Result.ok(total);
  }

  @override
  Future<Result<double>> partsTotalForVehicle(String vehicleId) async {
    if (error != null) return Result.error(error!);
    final total = _jobParts.fold<double>(0, (sum, jp) => sum + jp.totalCost);
    return Result.ok(total);
  }
}
