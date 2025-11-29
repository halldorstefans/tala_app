class VehicleApiModel {
  VehicleApiModel({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    this.ownerId,
    this.registrationNumber,
    this.vin,
    this.colour,
    this.odometer,
    this.nickname,
    this.purchaseDate,
    this.notes,
    this.photoUrl,
  });

  final String id;
  final String make;
  final String model;
  final int year;
  String? ownerId;
  String? registrationNumber;
  String? vin;
  String? colour;
  int? odometer;
  String? nickname;
  DateTime? purchaseDate;
  String? notes;
  String? photoUrl;

  factory VehicleApiModel.fromJson(Map<String, dynamic> json) {
    return VehicleApiModel(
      id: json['id'],
      make: json['make'],
      model: json['model'],
      year: json['year'],
      ownerId: json['owner_id'],
      registrationNumber: json['registration_number'],
      vin: json['vin'],
      colour: json['colour'],
      odometer: json['odometer'],
      nickname: json['nickname'],
      purchaseDate: json['purchase_date'] != null
          ? DateTime.parse(json['purchase_date'])
          : null,
      notes: json['notes'],
      photoUrl: json['photo_url'],
    );
  }
}
