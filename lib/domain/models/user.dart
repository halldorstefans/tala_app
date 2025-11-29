class User {
  final String firstName;
  final String lastName;

  User({required this.firstName, required this.lastName});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
    );
  }
}
