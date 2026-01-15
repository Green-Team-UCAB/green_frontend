abstract class AuthEvent {}

class AuthSignUp extends AuthEvent {
  final String userName;
  final String email;
  final String password;
  AuthSignUp({required this.userName, required this.email, required this.password});
}

class AuthLogin extends AuthEvent {
  final String username;
  final String password;
  AuthLogin({required this.username, required this.password});
}
