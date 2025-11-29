class JobApiModel {
  JobApiModel({
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
  });

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

  factory JobApiModel.fromJson(Map<String, dynamic> json) {
    return JobApiModel(
      id: json['id'],
      vehicleId: json['vehicle_id'],
      title: json['title'],
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      completionDate: json['completion_date'] != null
          ? DateTime.parse(json['completion_date'])
          : null,
      odometer: json['odometer'],
      category: json['category'],
      status: json['status'],
      description: json['description'],
      cost: json['cost'] != null ? (json['cost'] as num).toDouble() : null,
    );
  }
}

class JobPhotosApiModel {
  final String id;
  final String jobId;
  final String photoUrl;

  JobPhotosApiModel({
    required this.id,
    required this.jobId,
    required this.photoUrl,
  });

  factory JobPhotosApiModel.fromJson(Map<String, dynamic> json) {
    return JobPhotosApiModel(
      id: json['id'],
      jobId: json['job_id'],
      photoUrl: json['url'],
    );
  }
}
