import 'package:dio/dio.dart';
import 'package:green_frontend/core/error/exceptions.dart';
import 'package:green_frontend/core/network/api_client.dart';
import 'package:green_frontend/core/network/input_validator.dart';
import '../models/game_session_model.dart';

abstract class MultiplayerRemoteDataSource {
  Future<GameSessionModel> createSession({required String kahootId});
  Future<String> getPinByQrToken({required String qrToken});
}

class MultiplayerRemoteDataSourceImpl implements MultiplayerRemoteDataSource {
  final ApiClient client;
  static const String _basePath = '/multiplayer-sessions';

  MultiplayerRemoteDataSourceImpl({required Dio dio}) 
      : client = ApiClient(dio);

  @override
  Future<GameSessionModel> createSession({required String kahootId}) async {
    InputValidator.validateNotEmpty(kahootId, 'kahootId');

    final response = await client.post<Map<String, dynamic>>(
      path: _basePath,
      data: {'kahootId': kahootId},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return GameSessionModel.fromJson(response.data);
    }

    throw ServerException('Error al crear sesión: ${response.statusCode}');
  }

  @override
  Future<String> getPinByQrToken({required String qrToken}) async {
    InputValidator.validateNotEmpty(qrToken, 'qrToken');

    final response = await client.get<Map<String, dynamic>>(
      path: '$_basePath/qr/$qrToken',
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final pin = response.data['sessionPin'];
      if (pin == null) throw ServerException('El formato de respuesta del QR es incorrecto');
      return pin.toString();
    }
    
    throw ServerException('Código QR no válido o expirado: ${response.statusCode}');
  }

}