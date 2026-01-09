import '../../domain/entities/group_entity.dart';

class GroupModel extends GroupEntity {
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
      id: json['id'] ?? '',
      name: json['name'] ?? 'Sin nombre',
      description: json['description'],
      role: json['role'] ?? 'member',
      // La API a veces devuelve string o int, aseguramos el parseo
      memberCount: int.tryParse(json['memberCount'].toString()) ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
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
