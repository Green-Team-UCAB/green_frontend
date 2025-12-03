import 'package:green_frontend/features/single_player/infraestructure/models/answer_model.dart';
import 'package:green_frontend/features/single_player/infraestructure/models/answer_result_model.dart';
import 'package:green_frontend/features/single_player/infraestructure/models/attempt_model.dart';
import 'package:green_frontend/features/single_player/infraestructure/models/summary_model.dart';
import "package:dio/dio.dart";

abstract class AsyncGameDataSource {

  Future<AttemptModel> startAttempt({required String kahootId});
  Future<AttemptModel> getAttempt({required String attemptId});
  Future<AnswerResultModel> submitAnswer({required String attemptId, required AnswerModel answer});
  Future<SummaryModel> getSummary({required String attemptId});
}

class NotFoundException implements Exception { final String message; NotFoundException([this.message = 'Not found']); }
class NetworkException implements Exception { final String message; NetworkException([this.message = 'Network error']); }
class InvalidInputException implements Exception { final String message; InvalidInputException([this.message = 'Invalid input']); }
class BadRequestException implements Exception { final String message; BadRequestException([this.message = 'Bad Request']); }
class ServerException implements Exception { final String message; ServerException([this.message = 'Server error']); }
class UnauthorizedException implements Exception { final String message; UnauthorizedException([this.message = 'Unauthorized']); }



class AsyncGameDatasourceImpl implements AsyncGameDataSource{

  final Dio dio ;

  AsyncGameDatasourceImpl({required this.dio});


  @override
  Future<AttemptModel> startAttempt({required String kahootId}) async {
    if (kahootId.isEmpty) {
      throw Exception('El ID de Kahoot no puede estar vacío');
    }
    final path = '/attempts';
    final body = {'kahootId': kahootId};

    try {
      final response = await dio.post(path, data: body);

      final status = response.statusCode;
      if (status == 201) {
        return AttemptModel.fromJson(response.data);
      } else {
        throw Exception('Respuesta inesperada al iniciar intento: status=$status message=${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Error de red al iniciar intento: ${e.message}');
    } catch (e) {
      throw Exception('Error al iniciar el intento: $e');
    }
  }
  

  @override
  Future<AttemptModel> getAttempt({required String attemptId}) async {
    if (attemptId.isEmpty) {
      throw Exception('El ID del intento no puede estar vacío');
    }
    final path = '/attempts/$attemptId';

    try {
      final response = await dio.get(path);

      final status = response.statusCode;
      if (status == 200) {
        return AttemptModel.fromJson(response.data);
      } else if (status == 404) {
        throw Exception('Intento no encontrado: status=404');
      } else {
        throw Exception('Respuesta inesperada al obtener intento: status=$status message=${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Error de red al obtener el intento: ${e.message}');
    } catch (e) {
      throw Exception('Error al obtener el intento: $e');
    }
  }

  @override
  Future<AnswerResultModel> submitAnswer({required String attemptId, required AnswerModel answer}) async {
    if (attemptId.isEmpty) {
      throw Exception('El ID del intento no puede estar vacío');
    }
    final path = '/attempts/$attemptId/answers';
    final body = answer.toJson();

    try {
      final response = await dio.post(path, data: body);

      final status = response.statusCode;
      if (status == 200) {
        return AnswerResultModel.fromJson(response.data);
      } else if (status == 404) {
        throw Exception('Attempt o slide no encontrado: status=404');
      } else {
        throw Exception('Respuesta inesperada al enviar respuesta: status=$status message=${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Error de red al enviar la respuesta: ${e.message}');
    } catch (e) {
      throw Exception('Error al enviar la respuesta: $e');
    }
  } 

  @override
  Future<SummaryModel> getSummary({required String attemptId}) async {
    if (attemptId.isEmpty) {
      throw Exception('El ID del intento no puede estar vacío');
    }
    final path = '/attempts/$attemptId/summary';

    try {
      final response = await dio.get(path);

      final status = response.statusCode;
      if (status == 200) {
        return SummaryModel.fromJson(response.data);
      } else if (status == 404) {
        throw Exception('Resumen no encontrado: status=404');
      } else {
        throw Exception('Respuesta inesperada al obtener resumen: status=$status message=${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Error de red al obtener el resumen: ${e.message}');
    } catch (e) {
      throw Exception('Error al obtener el resumen: $e');
    }
  }
}