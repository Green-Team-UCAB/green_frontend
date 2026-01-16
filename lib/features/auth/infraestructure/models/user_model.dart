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

    final profile = json['userProfileDetails'] ?? {};

    return UserModel(
      id: json['id']?.toString() ?? '',

      userName: json['username'] ?? '',

      name: profile['name'] ?? json['name'] ?? 'Usuario', 
      email: json['email'] ?? '',

      type: json['type'] ?? json['role'] ?? 'user',

      description: profile['description'] ?? json['description'],
      avatarAssetUrl: profile['avatarAssetUrl'] ?? json['avatarAssetUrl'],
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
