import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:green_frontend/features/auth/application/get_user_profile.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase getUserProfile;

  ProfileBloc({required this.getUserProfile}) : super(ProfileInitial()) {
    on<ProfileGetInfo>(_onGetInfo);
    on<ProfileReset>((event, emit) => emit(ProfileInitial()));
  }

  Future<void> _onGetInfo(ProfileGetInfo event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());

    final result = await getUserProfile();

    result.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (user) => emit(ProfileLoaded(user)),
    );
  }
}