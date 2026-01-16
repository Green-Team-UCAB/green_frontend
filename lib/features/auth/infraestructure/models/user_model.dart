import 'package:green_frontend/features/auth/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.userName,
    required super.name,
    required super.email,
    required super.type,
    required super.createdAt,
    super.description,
    super.avatarAssetUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      userName: json['username'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      type: json['role'] ?? json['userType'] ?? 'user',
      description: json['description'],
      avatarAssetUrl: json['avatarAssetUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      userName: user.userName,
      name: user.name,
      email: user.email,
      type: user.type,
      description: user.description,
      avatarAssetUrl: user.avatarAssetUrl,
      createdAt: user.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": userName,
      "name": name,
      "email": email,
      "type": type,
      "description": description,
      "avatarAssetUrl": avatarAssetUrl,
      "createdAt": createdAt.toIso8601String(),
    };
  }

  // Conversión a entidad de dominio
  User toEntity() => User(
        id: id,
        userName: userName,
        name: name,
        email: email,
        type: type,
        description: description,
        avatarAssetUrl: avatarAssetUrl,
        createdAt: createdAt,
      );
}
