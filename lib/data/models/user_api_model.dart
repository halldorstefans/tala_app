class UserApiModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;

  UserApiModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  factory UserApiModel.fromJson(Map<String, dynamic> json) {
    return UserApiModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
    );
  }
}
