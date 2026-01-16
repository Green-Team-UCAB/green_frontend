// auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:green_frontend/features/auth/application/login_user.dart';
import 'package:green_frontend/features/auth/application/register_user.dart';
import 'package:green_frontend/features/auth/presentation/bloc/auth_event.dart';
import 'package:green_frontend/features/auth/presentation/bloc/auth_state.dart';
import 'package:fpdart/fpdart.dart';
import 'package:green_frontend/core/error/failures.dart';
import 'package:green_frontend/features/auth/domain/entities/user.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as dev;


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUserUseCase registerUser;
  final LoginUserUseCase loginUser;

  AuthBloc({required this.registerUser, required this.loginUser})
      : super(AuthInitial()) {
    on<AuthSignUp>(_onSignUp);
    on<AuthLogin>(_onLogin);
  }

  Future<void> _onSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    // 1. Ejecutar el registro
    final result = await registerUser(
      userName: event.userName,
      email: event.email,
      password: event.password,
      name: event.name,
      type: event.type,
      description: event.description,
      avatarAssetUrl: event.avatarAssetUrl,
    );

    await result.fold(
      (failure) async {
        emit(AuthFailure(failure.message));
      },
      (user) async {
        debugPrint("Registro exitoso: ${user.name}. Procediendo al login automático...");
        
        // 2. Disparar el login inmediatamente después del éxito
        // Usamos el username y password que vienen del evento de registro
        add(AuthLogin(
          username: event.userName,
          password: event.password,
        ));
      },
    );
  }

  Future<void> _onLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final Either<Failure, User> result = await loginUser(
      username: event.username,
      password: event.password,
    );
    result.fold(
      (failure){
        debugPrint("AuthBloc Failure on Login: ${failure.runtimeType} - ${failure.message}");
        emit(AuthFailure(failure.message));
      },
      (user) {
        debugPrint(" AuthBloc Success on Login: ${user.email}");
        emit(AuthSuccess(user));
      },
    );
  }
}
