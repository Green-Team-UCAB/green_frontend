import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/repositories/multiplayer_session_repository.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/value_objects/qr_token.dart';
import '../../domain/value_objects/session_pin.dart';
import '../models/game_session_model.dart';
import 'package:green_frontend/core/error/failures.dart';

class MultiplayerSessionRepositoryImpl implements MultiplayerSessionRepository {
  final Dio _dio;

  MultiplayerSessionRepositoryImpl(this._dio);

  @override
  Future<Either<Failure, GameSession>> createSession({
    required String kahootId, 
    required String jwt
  }) async {
    try {
      final response = await _dio.post(
        '/multiplayer-sessions',
        data: {'kahootId': kahootId},
        options: Options(headers: {'Authorization': 'Bearer $jwt'}),
      );

      return Right(GameSessionModel.fromJson(response.data));
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Error al crear sesión'));
    }
  }

  @override
  Future<Either<Failure, SessionPin>> getPinByQrToken({required QrToken qrToken}) async {
    try {
      final response = await _dio.get('/multiplayer-sessions/qr-token/${qrToken.value}');
      return Right(SessionPin(response.data['sessionPin']));
    } on DioException catch (_) {
      return Left(ServerFailure('Código QR inválido o expirado'));
    }
  }
}