import 'package:drift/drift.dart' hide Column;
import 'package:tala_app/data/database/app_database.dart' as db;

class Part {
  final String id;
  final String name;
  final String? partNumber;
  final String? brand;
  final String? supplier;
  final String? notes;
  final List<String>? photoPaths;

  const Part({
    required this.id,
    required this.name,
    this.partNumber,
    this.brand,
    this.supplier,
    this.notes,
    this.photoPaths,
  });

  Part copyWith({
    String? id,
    String? name,
    String? partNumber,
    String? brand,
    String? supplier,
    String? notes,
    List<String>? photoPaths,
  }) {
    return Part(
      id: id ?? this.id,
      name: name ?? this.name,
      partNumber: partNumber ?? this.partNumber,
      brand: brand ?? this.brand,
      supplier: supplier ?? this.supplier,
      notes: notes ?? this.notes,
      photoPaths: photoPaths ?? this.photoPaths,
    );
  }

  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(
      id: json['id'] as String,
      name: json['name'] as String,
      partNumber: json['partNumber'] as String?,
      brand: json['brand'] as String?,
      supplier: json['supplier'] as String?,
      notes: json['notes'] as String?,
    );
  }

  /// Builds a Companion for insert or update. See [Vehicle.toDrift] for the
  /// rationale on omitting `createdAt`.
  db.PartsCompanion toDrift() {
    return db.PartsCompanion(
      id: Value(id),
      name: Value(name),
      partNumber: Value(partNumber),
      brand: Value(brand),
      supplier: Value(supplier),
      notes: Value(notes),
      updatedAt: Value(DateTime.now()),
    );
  }

  static Part fromDrift(db.Part data, {List<String>? photoPaths}) {
    return Part(
      id: data.id,
      name: data.name,
      partNumber: data.partNumber,
      brand: data.brand,
      supplier: data.supplier,
      notes: data.notes,
      photoPaths: photoPaths,
    );
  }
}
