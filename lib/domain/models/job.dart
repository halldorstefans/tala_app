import 'package:drift/drift.dart' hide Column;
import 'package:tala_app/data/database/app_database.dart' as db;

class Job {
  final String id;
  final String vehicleId;
  final String title;
  DateTime? startDate;
  DateTime? completionDate;
  int? odometer;
  String? category;
  String? status;
  String? description;
  double? cost;
  List<String>? photoPaths;

  List<String>? get photoUrls => photoPaths;

  Job({
    required this.id,
    required this.vehicleId,
    required this.title,
    this.startDate,
    this.completionDate,
    this.odometer,
    this.category,
    this.status,
    this.description,
    this.cost,
    List<String>? photoPaths,
    List<String>? photoUrls,
  }) : photoPaths = photoPaths ?? photoUrls;

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
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

  db.JobsCompanion toDrift() {
    return db.JobsCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      title: Value(title),
      startDate: Value(startDate),
      completionDate: Value(completionDate),
      odometer: Value(odometer),
      category: Value(category),
      status: Value(status),
      description: Value(description),
      cost: Value(cost),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );
  }

  static Job fromDrift(db.Job data, {List<String>? photoPaths}) {
    return Job(
      id: data.id,
      vehicleId: data.vehicleId,
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