import 'package:drift/drift.dart' hide Column;
import 'package:tala_app/data/database/app_database.dart' as db;

class Vehicle {
  final String id;
  final String make;
  final String model;
  final int year;
  String? nickname;
  String? registration;
  String? vin;
  String? colour;
  int? odometer;
  DateTime? purchaseDate;
  String? notes;
  String? photoPath;

  String? get photoUrl => photoPath;

  Vehicle({
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
    String? photoPath,
    String? photoUrl,
  }) : photoPath = photoPath ?? photoUrl;

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
      createdAt: Value(DateTime.now()),
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