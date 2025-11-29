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
  List<String>? photoUrls;

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
  });

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
}
