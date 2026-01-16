abstract class AuthEvent {}

class AuthSignUp extends AuthEvent {
  final String userName;
  final String email;
  final String password;
  final String name;      
  final String type;      
  final String? description;
  final String? avatarAssetUrl;

  AuthSignUp({
    required this.userName,
    required this.email,
    required this.password,
    required this.name,
    required this.type,
    this.description,
    this.avatarAssetUrl,
  });
}

class AuthLogin extends AuthEvent {
  final String username;
  final String password;
  AuthLogin({required this.username, required this.password});
}
