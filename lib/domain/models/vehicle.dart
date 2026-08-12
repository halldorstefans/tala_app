import 'package:drift/drift.dart' hide Column;
import 'package:tala_app/data/database/app_database.dart' as db;

class Vehicle {
  final String id;
  final String make;
  final String model;
  final int year;
  final String? nickname;
  final String? registration;
  final String? vin;
  final String? colour;
  final int? odometer;
  final DateTime? purchaseDate;
  final String? notes;
  final String? photoPath;

  const Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    this.nickname,
    this.registration,
    this.vin,
    this.colour,
    this.odometer,
    this.purchaseDate,
    this.notes,
    this.photoPath,
  });

  Vehicle copyWith({
    String? id,
    String? make,
    String? model,
    int? year,
    String? nickname,
    String? registration,
    String? vin,
    String? colour,
    int? odometer,
    DateTime? purchaseDate,
    String? notes,
    String? photoPath,
  }) {
    return Vehicle(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      nickname: nickname ?? this.nickname,
      registration: registration ?? this.registration,
      vin: vin ?? this.vin,
      colour: colour ?? this.colour,
      odometer: odometer ?? this.odometer,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  /// Returns a copy with [photoPath] set explicitly, including to null.
  ///
  /// Separate from [copyWith] because its `x ?? this.x` idiom can't express
  /// "clear the cover photo" — exactly what removing it requires.
  Vehicle withPhotoPath(String? photoPath) => Vehicle(
    id: id,
    make: make,
    model: model,
    year: year,
    nickname: nickname,
    registration: registration,
    vin: vin,
    colour: colour,
    odometer: odometer,
    purchaseDate: purchaseDate,
    notes: notes,
    photoPath: photoPath,
  );

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      make: json['make'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      nickname: json['nickname'] as String?,
      registration: json['registration_number'] as String?,
      vin: json['vin'] as String?,
      colour: json['colour'] as String?,
      odometer: json['odometer'] as int?,
      purchaseDate: json['purchase_date'] != null
          ? DateTime.parse(json['purchase_date'] as String)
          : null,
      notes: json['notes'] as String?,
      photoPath: json['photo_path'] as String?,
    );
  }

  /// Builds a Companion for insert or update.
  ///
  /// `createdAt` is intentionally left absent: on insert the table's
  /// `withDefault(currentDateAndTime)` fills it, and on update Drift's
  /// `replace` treats absent values as "don't touch this column",
  /// preserving the original timestamp.
  db.VehiclesCompanion toDrift() {
    return db.VehiclesCompanion(
      id: Value(id),
      make: Value(make),
      model: Value(model),
      year: Value(year),
      nickname: Value(nickname),
      registrationNumber: Value(registration),
      vin: Value(vin),
      colour: Value(colour),
      odometer: Value(odometer),
      purchaseDate: Value(purchaseDate),
      notes: Value(notes),
      photoPath: Value(photoPath),
      updatedAt: Value(DateTime.now()),
    );
  }

  static Vehicle fromDrift(db.Vehicle data) {
    return Vehicle(
      id: data.id,
      make: data.make,
      model: data.model,
      year: data.year,
      nickname: data.nickname,
      registration: data.registrationNumber,
      vin: data.vin,
      colour: data.colour,
      odometer: data.odometer,
      purchaseDate: data.purchaseDate,
      notes: data.notes,
      photoPath: data.photoPath,
    );
  }
}
