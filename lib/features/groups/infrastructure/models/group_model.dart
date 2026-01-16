import '../../domain/entities/group.dart';

class GroupModel extends Group {
  const GroupModel({
    required super.id,
    required super.name,
    super.description,
    required super.role,
    required super.memberCount,
    required super.createdAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] ?? json['groupId'] ?? '',
      name: json['name'] ?? json['groupName'] ?? 'Sin nombre',
      description: json['description'],
      role: json['role'] ?? 'member',
      memberCount: json['memberCount'] is int
          ? json['memberCount']
          : int.tryParse(json['memberCount']?.toString() ?? '1') ?? 1,
      createdAt: DateTime.tryParse(
            json['createdAt'] ?? json['joinedAt'] ?? '',
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'role': role,
      'memberCount': memberCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
