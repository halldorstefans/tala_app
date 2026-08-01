import 'package:drift/drift.dart' hide Column;
import 'package:tala_app/data/database/app_database.dart' as db;

import 'part.dart';

class JobPart {
  final String id;
  final String jobId;
  final String partId;
  final double? unitCost;
  final int quantity;
  final DateTime? purchaseDate;

  const JobPart({
    required this.id,
    required this.jobId,
    required this.partId,
    this.unitCost,
    this.quantity = 1,
    this.purchaseDate,
  });

  /// Line total for this use of the part. Computed, not stored (see PARTS.md).
  double get totalCost => (unitCost ?? 0) * quantity;

  JobPart copyWith({
    String? id,
    String? jobId,
    String? partId,
    double? unitCost,
    int? quantity,
    DateTime? purchaseDate,
  }) {
    return JobPart(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      partId: partId ?? this.partId,
      unitCost: unitCost ?? this.unitCost,
      quantity: quantity ?? this.quantity,
      purchaseDate: purchaseDate ?? this.purchaseDate,
    );
  }

  factory JobPart.fromJson(Map<String, dynamic> json) {
    return JobPart(
      id: json['id'] as String,
      jobId: json['jobId'] as String,
      partId: json['partId'] as String,
      unitCost: json['unitCost'] != null
          ? (json['unitCost'] as num).toDouble()
          : null,
      quantity: json['quantity'] as int? ?? 1,
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'] as String)
          : null,
    );
  }

  db.JobPartsCompanion toDrift() {
    return db.JobPartsCompanion(
      id: Value(id),
      jobId: Value(jobId),
      partId: Value(partId),
      unitCost: Value(unitCost),
      quantity: Value(quantity),
      purchaseDate: Value(purchaseDate),
      updatedAt: Value(DateTime.now()),
    );
  }

  static JobPart fromDrift(db.JobPart data) {
    return JobPart(
      id: data.id,
      jobId: data.jobId,
      partId: data.partId,
      unitCost: data.unitCost,
      quantity: data.quantity,
      purchaseDate: data.purchaseDate,
    );
  }
}

/// A job's use of a part, paired with the part it points at. The read shape
/// for a job's parts list.
typedef JobPartLine = ({JobPart link, Part part});
