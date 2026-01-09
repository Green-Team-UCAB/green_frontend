import '../../domain/entities/group.dart';

class GroupModel extends Group {
  const GroupModel({
    required super.id,
    required super.name,
    required super.role,
    required super.memberCount,
    required super.createdAt,
    super.description,
    super.adminId,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Sin nombre',
      role: json['role'] as String? ?? 'member',
      memberCount: json['memberCount'] is String
          ? int.tryParse(json['memberCount']) ?? 0
          : (json['memberCount'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now(),
      description: json['description'] as String?,
      adminId: json['adminId'] as String?,
    );
  }
}
