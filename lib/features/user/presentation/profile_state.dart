import 'package:green_frontend/features/auth/domain/entities/user.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final User user;
  ProfileLoaded(this.user);
}

class ProfileFailure extends ProfileState {
  final String message;
  ProfileFailure(this.message);
}