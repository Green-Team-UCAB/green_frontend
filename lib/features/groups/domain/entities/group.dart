import 'package:equatable/equatable.dart';

class Group extends Equatable {
  final String id;
  final String name;
  final String role; // "admin" o "member"
  final int memberCount;
  final DateTime createdAt;
  final String? description;
  final String? adminId;

  const Group({
    required this.id,
    required this.name,
    required this.role,
    required this.memberCount,
    required this.createdAt,
    this.description,
    this.adminId,
  });

  // Getter útil para la UI
  bool get isAdmin => role.toLowerCase() == 'admin';

  @override
  List<Object?> get props => [id, name, role, memberCount, createdAt];
}
