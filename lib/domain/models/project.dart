import 'package:drift/drift.dart' hide Column;
import 'package:tala_app/data/database/app_database.dart' as db;

class Project {
  final String id;
  final String vehicleId;
  final String title;
  final String? status;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;

  const Project({
    required this.id,
    required this.vehicleId,
    required this.title,
    this.status,
    this.description,
    this.startDate,
    this.endDate,
  });

  Project copyWith({
    String? id,
    String? vehicleId,
    String? title,
    String? status,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Project(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      title: title ?? this.title,
      status: status ?? this.status,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      title: json['title'] as String,
      status: json['status'] as String?,
      description: json['description'] as String?,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
    );
  }

  /// Builds a Companion for insert or update. See [Vehicle.toDrift] for the
  /// rationale on omitting `createdAt`.
  db.ProjectsCompanion toDrift() {
    return db.ProjectsCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      title: Value(title),
      status: Value(status),
      description: Value(description),
      startDate: Value(startDate),
      endDate: Value(endDate),
      updatedAt: Value(DateTime.now()),
    );
  }

  static Project fromDrift(db.Project data) {
    return Project(
      id: data.id,
      vehicleId: data.vehicleId,
      title: data.title,
      status: data.status,
      description: data.description,
      startDate: data.startDate,
      endDate: data.endDate,
    );
  }
}
