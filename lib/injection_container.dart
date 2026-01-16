import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

// Core
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';

// --- Feature: Kahoot ---
import 'features/kahoot/domain/repositories/ikahoot_repository.dart';
import 'features/kahoot/infrastructure/repositories/kahoot_repository_impl.dart';
import 'features/kahoot/infrastructure/datasources/kahoot_remote_datasource.dart';
import 'features/kahoot/application/use_cases/save_kahoot_use_case.dart';

//--- Feature: User ---
import 'features/user/presentation/profile_bloc.dart';
import 'features/auth/application/get_user_profile.dart';
import 'features/auth/application/update_profile.dart';

// --- Feature: Discovery (H6.1) ---
import 'features/discovery/data/datasources/discovery_remote_data_source.dart';
import 'features/discovery/data/repositories/discovery_repository_impl.dart';
import 'features/discovery/domain/repositories/discovery_repository.dart';
import 'features/discovery/presentation/bloc/discovery_bloc.dart';

// --- Feature: Reports (Épica 10) ---
import 'features/reports/infrastructure/datasources/reports_remote_data_source.dart';
import 'features/reports/infrastructure/repositories/reports_repository_impl.dart';
import 'features/reports/domain/repositories/reports_repository.dart';
import 'features/reports/presentation/bloc/reports_bloc.dart';
import 'features/reports/application/get_my_reports_use_case.dart';
import 'features/reports/application/get_session_report_use_case.dart';
import 'features/reports/application/get_multiplayer_result_use_case.dart';
import 'features/reports/application/get_singleplayer_result_use_case.dart';

// --- Feature: Library (Épica 7) ---
import 'features/library/infrastructure/datasources/library_remote_datasource.dart';
import 'features/library/infrastructure/datasources/library_repository_impl.dart';
import 'features/library/domain/repositories/library_repository.dart';
import 'features/library/presentation/bloc/library_bloc.dart';
import 'features/library/application/get_my_kahoots_use_case.dart';
import 'features/library/application/get_favorites_use_case.dart';
import 'features/library/application/get_in_progress_use_case.dart';
import 'features/library/application/get_completed_use_case.dart';
import 'features/library/application/toggle_favorite_use_case.dart';

// --- Feature: Groups (Épica 8) ---
import 'features/groups/infrastructure/datasources/groups_remote_data_source.dart';
import 'features/groups/infrastructure/repositories/groups_repository_impl.dart';
import 'features/groups/domain/repositories/groups_repository.dart';
import 'features/groups/presentation/bloc/groups_bloc.dart';
import 'features/groups/presentation/bloc/group_detail_bloc.dart';
import 'features/groups/presentation/bloc/group_settings_bloc.dart';
import 'features/groups/presentation/bloc/kahoot_selection_bloc.dart';

// Groups Use Cases
import 'features/groups/application/get_my_groups_use_case.dart';
import 'features/groups/application/create_group_use_case.dart';
import 'features/groups/application/join_group_use_case.dart';
import 'features/groups/application/get_group_quizzes_use_case.dart';
import 'features/groups/application/get_group_leaderboard_use_case.dart';
import 'features/groups/application/generate_invitation_use_case.dart';
import 'features/groups/application/assign_quiz_use_case.dart';
import 'features/groups/application/update_group_use_case.dart';
import 'features/groups/application/kick_member_use_case.dart';
import 'features/groups/application/delete_group_use_case.dart';
import 'features/groups/application/get_group_members_use_case.dart';

// --- Feature: IA (Épica 9) ---
import 'core/network/ai_service.dart';

// --- Feature: Single Player ---
import 'features/single_player/infraestructure/datasources/async_game_datasource.dart';
import 'features/single_player/infraestructure/repositories/async_game_repository_impl.dart';
import 'features/single_player/domain/repositories/async_game_repository.dart';
import 'features/single_player/presentation/bloc/game_bloc.dart';
import 'features/single_player/application/start_attempt.dart';
import 'features/single_player/application/submit_answer.dart';
import 'features/single_player/application/get_summary.dart';

// --- Feature: Multiplayer ---
import 'features/multiplayer/infraestructure/datasources/multiplayer_socket_datasource.dart';
import 'features/multiplayer/infraestructure/repositories/multiplayer_socket_repository_impl.dart';
import 'features/multiplayer/domain/repositories/multiplayer_socket_repository.dart';
import 'features/multiplayer/application/commands.dart';
import 'features/multiplayer/application/subscriptions.dart';
import 'features/multiplayer/presentation/bloc/multiplayer_bloc.dart';
import 'features/multiplayer/infraestructure/repositories/multiplayer_session_repository_impl.dart';
import 'features/multiplayer/domain/repositories/multiplayer_session_repository.dart';
import 'features/multiplayer/infraestructure/datasources/multiplayer_rest_datasource.dart';

import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/infraestructure/repositories/auth_repository_impl.dart';
import 'features/auth/infraestructure/datasources/auth_datasource.dart';

// Core Mappers
import 'core/mappers/exception_failure_mapper.dart';

// Instancia global del Service Locator
final sl = GetIt.instance;

// 🔴 URL BASE CENTRALIZADA PARA TODA LA APLICACIÓN
const String _baseUrl = 'https://quizzy-backend-1-zpvc.onrender.com';
const String _apiSufix = '/api';
const String apiBaseUrl = '$_baseUrl$_apiSufix';

Future<void> init() async {
  // ================================================================
  // 1. FEATURES
  // ================================================================

  // --- Kahoot (Épica de creación/edición) ---
  // Data Source
  sl.registerLazySingleton<KahootRemoteDataSource>(
    () => KahootRemoteDataSource(),
  );

  // Repository
  sl.registerLazySingleton<KahootRepository>(
    () => KahootRepositoryImpl(sl<KahootRemoteDataSource>()),
  );

  // También registrar la implementación por si acaso se necesita
  sl.registerLazySingleton<KahootRepositoryImpl>(
    () => KahootRepositoryImpl(sl<KahootRemoteDataSource>()),
  );

  // Use Cases
  sl.registerLazySingleton(() => SaveKahootUseCase(sl<KahootRepository>()));

  // --- Discovery (H6.1) ---
  sl.registerFactory(() => DiscoveryBloc(repository: sl()));

  sl.registerLazySingleton<DiscoveryRepository>(
    () => DiscoveryRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<DiscoveryRemoteDataSource>(
    () => DiscoveryRemoteDataSourceImpl(apiClient: sl()),
  );

  // --- Reports (Épica 10) ---
  // Use Cases
  sl.registerLazySingleton(() => GetMyReportSummariesUseCase(sl()));
  sl.registerLazySingleton(() => GetSessionReportUseCase(sl()));
  sl.registerLazySingleton(() => GetMultiplayerResultUseCase(sl()));
  sl.registerLazySingleton(() => GetSingleplayerResultUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => ReportsBloc(
      getMyReportSummariesUseCase: sl(),
      getSessionReportUseCase: sl(),
      getMultiplayerResultUseCase: sl(),
      getSingleplayerResultUseCase: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<ReportsRepository>(
    () => ReportsRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<ReportsRemoteDataSource>(
    () => ReportsRemoteDataSourceImpl(apiClient: sl()),
  );

  // --- Library (Épica 7) ---
  // Use Cases
  sl.registerLazySingleton(() => GetMyKahootsUseCase(sl()));
  sl.registerLazySingleton(() => GetFavoritesUseCase(sl()));
  sl.registerLazySingleton(() => GetInProgressUseCase(sl()));
  sl.registerLazySingleton(() => GetCompletedUseCase(sl()));
  sl.registerLazySingleton(() => ToggleFavoriteUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => LibraryBloc(
      getMyKahoots: sl(),
      getFavorites: sl(),
      getInProgress: sl(),
      getCompleted: sl(),
      toggleFavorite: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<LibraryRepository>(
    () => LibraryRepositoryImpl(dataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<LibraryRemoteDataSource>(
    () => LibraryRemoteDataSourceImpl(apiClient: sl()),
  );

  // --- Groups (Épica 8) ---
  // Use Cases
  sl.registerLazySingleton(() => GetMyGroupsUseCase(sl()));
  sl.registerLazySingleton(() => CreateGroupUseCase(sl()));
  sl.registerLazySingleton(() => JoinGroupUseCase(sl()));
  sl.registerLazySingleton(() => GetGroupQuizzesUseCase(sl()));
  sl.registerLazySingleton(() => GetGroupLeaderboardUseCase(sl()));
  sl.registerLazySingleton(() => GenerateInvitationUseCase(sl()));
  sl.registerLazySingleton(() => AssignQuizUseCase(sl()));
  sl.registerLazySingleton(() => UpdateGroupUseCase(sl()));
  sl.registerLazySingleton(() => KickMemberUseCase(sl()));
  sl.registerLazySingleton(() => DeleteGroupUseCase(sl()));
  sl.registerLazySingleton(() => GetGroupMembersUseCase(sl()));

  // Blocs
  sl.registerFactory(
    () => GroupsBloc(getMyGroups: sl(), createGroup: sl(), joinGroup: sl()),
  );

  sl.registerFactory(
    () => GroupDetailBloc(
      getGroupQuizzes: sl(),
      getGroupLeaderboard: sl(),
      generateInvite: sl(),
      assignQuiz: sl(),
    ),
  );

  sl.registerFactory(
    () => GroupSettingsBloc(
      updateGroup: sl(),
      kickMember: sl(),
      deleteGroup: sl(),
      getGroupMembers: sl(),
    ),
  );
  sl.registerFactory(() => KahootSelectionBloc(getMyKahoots: sl()));

  // Repository
  sl.registerLazySingleton<GroupsRepository>(
    () => GroupsRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<GroupsRemoteDataSource>(
    () => GroupsRemoteDataSourceImpl(apiClient: sl()),
  );

  // --- Single Player ---
  // Use Cases
  sl.registerLazySingleton(() => StartAttempt(sl()));
  sl.registerLazySingleton(() => SubmitAnswer(sl()));
  sl.registerLazySingleton(() => GetSummary(sl()));

  // Bloc
  sl.registerFactory(
    () => GameBloc(startAttempt: sl(), submitAnswer: sl(), getSummary: sl()),
  );

  // Repository
  sl.registerLazySingleton<AsyncGameRepository>(
    () => AsyncGameRepositoryImpl(dataSource: sl(), mapper: sl()),
  );

  // Data Source
  sl.registerLazySingleton<AsyncGameDataSource>(
    () => AsyncGameDataSourceImpl(dio: sl()),
  );

  // --- Multiplayer ---
  // Data Source
  sl.registerLazySingleton<MultiplayerSocketDataSource>(
    () => MultiplayerSocketDataSourceImpl(),
  );

  
sl.registerLazySingleton<MultiplayerRemoteDataSource>(
  () => MultiplayerRemoteDataSourceImpl(client: sl<ApiClient>()),
);


  // Repository
  sl.registerFactory<MultiplayerSocketRepository>(
    () => MultiplayerSocketRepositoryImpl(dataSource: sl(), baseUrl: _baseUrl),
  );
  sl.registerLazySingleton<MultiplayerSessionRepository>(
    () =>
        MultiplayerSessionRepositoryImpl(remoteDataSource: sl(), mapper: sl()),
  );

  // Use Cases (Comandos)
  sl.registerLazySingleton(() => CreateMultiplayerSession(sl()));
  sl.registerLazySingleton(() => ResolvePinFromQr(sl()));
  sl.registerLazySingleton(() => ConnectToGame(sl()));
  sl.registerLazySingleton(() => ConfirmClientReady(sl()));
  sl.registerLazySingleton(() => JoinRoom(sl()));
  sl.registerLazySingleton(() => StartGame(sl()));
  sl.registerLazySingleton(() => NextPhase(sl()));
  sl.registerLazySingleton(() => SubmitSyncAnswer(sl()));

  // Use Cases (Suscripciones)
  sl.registerLazySingleton(() => ListenHostConnectedSuccess(sl()));
  sl.registerLazySingleton(() => ListenPlayerConnectedSuccess(sl()));
  sl.registerLazySingleton(() => ListenRoomJoined(sl()));
  sl.registerLazySingleton(() => ListenHostLobbyUpdate(sl()));
  sl.registerLazySingleton(() => ListenQuestionStarted(sl()));
  sl.registerLazySingleton(() => ListenAnswerUpdate(sl()));
  sl.registerLazySingleton(() => ListenSocketError(sl()));
  sl.registerLazySingleton(() => ListenSessionClosed(sl()));
  sl.registerLazySingleton(() => ListenHostResults(sl()));
  sl.registerLazySingleton(() => ListenPlayerResults(sl()));
  sl.registerLazySingleton(() => ListenGameEnd(sl()));
  sl.registerLazySingleton(() => ListenPlayerLeft(sl()));

  // Bloc
  sl.registerLazySingleton(
    () => MultiplayerBloc(
      createSession: sl(),
      resolvePinFromQr: sl(),
      connectToGame: sl(),
      confirmClientReady: sl(),
      joinRoom: sl(),
      startGame: sl(),
      nextPhase: sl(),
      submitAnswer: sl(),
      listenHostSuccess: sl(),
      listenPlayerSuccess: sl(),
      listenRoomJoined: sl(),
      listenHostLobbyUpdate: sl(),
      listenQuestionStarted: sl(),
      listenAnswerCountUpdate: sl(),
      listenSocketError: sl(),
      listenSessionClosed: sl(),
      listenQuestionResults: sl(),
      listenGameResults: sl(),
      listenHostResults: sl(),
    ),
  );

  // ================================================================
  // AUTH & PROFILE FEATURE
  // ================================================================
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));

  sl.registerFactory(
    () => ProfileBloc(
      getUserProfile: sl<GetUserProfileUseCase>(),
      updateUserProfile: sl<UpdateProfileUseCase>(),
    ),
  );

  // Repository: Debes registrar la interfaz vinculada a su implementación
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(dataSource: sl(), mapper: sl()),
  );

  // Data Source: La fuente de datos remota
  sl.registerLazySingleton<AuthDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );

  // ================================================================
  // 2. CORE & EXTERNAL
  // ================================================================

  // Dio Base Configuration
  sl.registerLazySingleton(
    () => Dio(
      BaseOptions(
        baseUrl: apiBaseUrl, // 🔴 USANDO URL CENTRALIZADA
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    ),
  );

  // ApiClient Wrapper (Singleton)
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));

  // Http Client
  sl.registerLazySingleton<http.Client>(() => http.Client());

  // AI Service
  sl.registerLazySingleton<AiService>(() => AiService());

  // Mappers
  sl.registerLazySingleton(() => ExceptionFailureMapper());

  // ================================================================
  // 3. INICIALIZACIÓN DE SESIÓN
  // ================================================================
  try {
    final token = await TokenStorage.getToken();

    if (token != null && token.isNotEmpty) {
      sl<ApiClient>().setAuthToken(token);
      debugPrint(
        "✅ INJECTION: Token cargado y seteado en ApiClient globalmente.",
      );
    } else {
      debugPrint("⚠️ INJECTION: No hay token guardado.");
    }
  } catch (e) {
    debugPrint(
      "❌ INJECTION ERROR: Falló la recuperación del token al inicio: $e",
    );
  }
}