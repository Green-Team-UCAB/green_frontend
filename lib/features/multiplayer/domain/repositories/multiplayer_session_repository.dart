import 'package:green_frontend/features/multiplayer/domain/entities/game_session.dart';
import 'package:fpdart/fpdart.dart';
import 'package:green_frontend/core/error/failures.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/qr_token.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/session_pin.dart';

abstract interface class MultiplayerSessionRepository{
  Future<Either<Failure, GameSession>> createSession({required String kahootId, required String jwt});
  Future<Either<Failure, SessionPin>> getPinByQrToken({required QrToken qrToken});
}