import 'package:fpdart/fpdart.dart';
import 'package:green_frontend/core/error/failures.dart';
import 'package:green_frontend/core/mappers/exception_failure_mapper.dart'; // Importamos el mapper
import 'package:green_frontend/features/multiplayer/domain/entities/game_session.dart';
import 'package:green_frontend/features/multiplayer/domain/repositories/multiplayer_session_repository.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/qr_token.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/session_pin.dart';
import 'package:green_frontend/features/multiplayer/infraestructure/datasources/multiplayer_rest_datasource.dart';
import 'package:green_frontend/features/multiplayer/infraestructure/models/game_session_model.dart';

class MultiplayerSessionRepositoryImpl implements MultiplayerSessionRepository {
  final MultiplayerRemoteDataSource remoteDataSource;
  final ExceptionFailureMapper mapper; 

  MultiplayerSessionRepositoryImpl({
    required this.remoteDataSource,
    required this.mapper,
  });

  @override
  Future<Either<Failure, GameSession>> createSession({
    required String kahootId,
    required String jwt,
  }) async {
    try {
      final GameSessionModel model = await remoteDataSource.createSession(
        kahootId: kahootId,
      );
      final domain = model.toEntity();
      return right(domain);      
    } on Exception catch (e) {
      return left(mapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, SessionPin>> getPinByQrToken({
    required QrToken qrToken,
  }) async {
    try {
      final String pin = await remoteDataSource.getPinByQrToken(
        qrToken: qrToken.value,
      );
      return right(SessionPin(pin));
    } on Exception catch (e) {
      return left(mapper.mapExceptionToFailure(e));
    }
  }
  

}