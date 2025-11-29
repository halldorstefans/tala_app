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
  String? photoUrl;

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
    this.photoUrl,
  });

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
      photoUrl: json['photo_url'] as String?,
    );
  }
}
