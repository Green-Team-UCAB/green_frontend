class User {
  final String id;
  final String userName;
  final String email;
  final String? description;
  final String role; // "student y teacher"
  final DateTime createdAt;

  User({
    required this.id,
    required this.userName,
    required this.email,
    this.description,
    required this.role,
    required this.createdAt,
  });
}
