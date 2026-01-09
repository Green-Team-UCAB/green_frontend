import 'package:green_frontend/features/auth/domain/entities/user.dart';

class UserModel extends User {


  UserModel({
    required super.id,
    required super.userName,
    required super.email,
    required super.role,
    super.description,
    required super.createdAt,
  });

factory UserModel.fromJson(Map<String, dynamic> json) {
  return UserModel(
    id: json['id'] ?? '', 
    userName: json['username'] ?? '',
    email: json['email'] ?? '',
    role: json['role'] ?? 'user', 
    description: json['description'],
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(), 
  );
}


  factory UserModel.fromEntity(User user) { 
    return UserModel( 
      id: user.id, 
      userName: user.userName, 
      email: user.email, 
      role: user.role, 
      description: user.description, 
      createdAt: user.createdAt, 
    ); 
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": userName,
      "email": email,
      "role": role,
      "description": description,
      "createdAt": createdAt.toIso8601String(),
    };
  }

  // Conversión a entidad de dominio
  User toEntity() => User(
        id: id,
        userName: userName,
        email: email,
        role: role,
        description: description,
        createdAt: createdAt,
      );
}
