import '../../domain/entities/group_member.dart';

class GroupMemberModel extends GroupMember {
  const GroupMemberModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    // Check if user details are nested in a 'user' object
    final userJson = json['user'] is Map<String, dynamic> ? json['user'] : json;

    // Check for profile details
    final profile = userJson['userProfileDetails'] is Map
        ? userJson['userProfileDetails']
        : {};

    return GroupMemberModel(
      id: userJson['id'] ?? userJson['userId'] ?? json['id'] ?? '',
      name: profile['name'] ??
          userJson['name'] ??
          userJson['username'] ??
          userJson['email'] ??
          'Usuario',
      email: userJson['email'] ?? '',
      role: json['role'] ?? userJson['role'] ?? 'member',
    );
  }
}
