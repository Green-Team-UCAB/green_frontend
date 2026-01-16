import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:green_frontend/features/auth/application/get_user_profile.dart';
import 'package:green_frontend/features/auth/application/update_profile.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase getUserProfile;
  final UpdateProfileUseCase updateUserProfile;

  ProfileBloc({required this.getUserProfile, required this.updateUserProfile})
      : super(ProfileInitial()) {
    on<ProfileGetInfo>(_onGetInfo);
    on<ProfileReset>((event, emit) => emit(ProfileInitial()));
    on<ProfileUpdateInfo>(_onUpdateInfo);
  }

  Future<void> _onGetInfo(
      ProfileGetInfo event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());

    final result = await getUserProfile();

    result.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (user) => emit(ProfileLoaded(user)),
    );
  }

  Future<void> _onUpdateInfo(
    ProfileUpdateInfo event,
    Emitter<ProfileState> emit,
  ) async {
    // 1. Cambiamos a estado de carga mientras el PATCH se ejecuta
    emit(ProfileLoading());

    // 2. Ejecutamos el caso de uso con la entidad User actualizada
    final result = await updateUserProfile.execute(event.updateData);

    // 3. Manejamos el resultado (Success o Failure)
    result.fold(
      (failure) => emit(ProfileFailure(failure.toString())),
      (updatedUser) => emit(ProfileLoaded(updatedUser)),
    );
  }
}
