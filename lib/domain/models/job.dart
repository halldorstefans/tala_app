import 'package:drift/drift.dart' hide Column;
import 'package:tala_app/data/database/app_database.dart' as db;
import 'package:tala_app/domain/models/job_status.dart';

class Job {
  final String id;
  final String vehicleId;
  final String? projectId;
  final String title;
  final DateTime? startDate;
  final DateTime? completionDate;
  final int? odometer;
  final String? category;
  final String? status;
  final String? description;
  final double? cost;
  final List<String>? photoPaths;

  const Job({
    required this.id,
    required this.vehicleId,
    required this.title,
    this.projectId,
    this.startDate,
    this.completionDate,
    this.odometer,
    this.category,
    this.status,
    this.description,
    this.cost,
    this.photoPaths,
  });

  Job copyWith({
    String? id,
    String? vehicleId,
    String? title,
    DateTime? startDate,
    DateTime? completionDate,
    int? odometer,
    String? category,
    String? status,
    String? description,
    double? cost,
    List<String>? photoPaths,
  }) {
    return Job(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      title: title ?? this.title,
      projectId: projectId,
      startDate: startDate ?? this.startDate,
      completionDate: completionDate ?? this.completionDate,
      odometer: odometer ?? this.odometer,
      category: category ?? this.category,
      status: status ?? this.status,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      photoPaths: photoPaths ?? this.photoPaths,
    );
  }

  /// Returns a copy assigned to [projectId], or unassigned when it is null.
  ///
  /// Separate from [copyWith] because `copyWith`'s `x ?? this.x` idiom cannot
  /// express "set back to null" — which is exactly what unassigning a job from
  /// a project requires.
  Job withProject(String? projectId) => Job(
    id: id,
    vehicleId: vehicleId,
    title: title,
    projectId: projectId,
    startDate: startDate,
    completionDate: completionDate,
    odometer: odometer,
    category: category,
    status: status,
    description: description,
    cost: cost,
    photoPaths: photoPaths,
  );

  /// Returns a copy of this job with invariants enforced.
  ///
  /// Currently just one: when the job is completed, `startDate` cannot be
  /// later than `completionDate` — a job that "started next week and
  /// finished today" reads as broken data. In that case `startDate` is
  /// snapped back to `completionDate`.
  ///
  /// Call this before persisting a job that was assembled from user input
  /// or from mutations elsewhere in the app.
  Job normalized() {
    if (status != JobStatus.completed) return this;
    final s = startDate;
    final c = completionDate;
    if (s == null || c == null) return this;
    if (!s.isAfter(c)) return this;
    return copyWith(startDate: c);
  }

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      projectId: json['projectId'] as String?,
      title: json['title'] as String,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'] as String)
          : null,
      odometer: json['odometer'] as int?,
      category: json['category'] as String?,
      status: json['status'] as String?,
      description: json['description'] as String?,
      cost: json['cost'] != null ? (json['cost'] as num).toDouble() : null,
    );
  }

  /// Builds a Companion for insert or update. See [Vehicle.toDrift] for the
  /// rationale on omitting `createdAt`.
  db.JobsCompanion toDrift() {
    return db.JobsCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      projectId: Value(projectId),
      title: Value(title),
      startDate: Value(startDate),
      completionDate: Value(completionDate),
      odometer: Value(odometer),
      category: Value(category),
      status: Value(status),
      description: Value(description),
      cost: Value(cost),
      updatedAt: Value(DateTime.now()),
    );
  }

  static Job fromDrift(db.Job data, {List<String>? photoPaths}) {
    return Job(
      id: data.id,
      vehicleId: data.vehicleId,
      projectId: data.projectId,
      title: data.title,
      startDate: data.startDate,
      completionDate: data.completionDate,
      odometer: data.odometer,
      category: data.category,
      status: data.status,
      description: data.description,
      cost: data.cost,
      photoPaths: photoPaths,
    );
  }
}
