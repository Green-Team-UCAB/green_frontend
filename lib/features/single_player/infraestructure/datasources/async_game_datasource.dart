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


class AsyncGameDatasourceImpl implements AsyncGameDataSource{

  final Dio dio = Dio(BaseOptions(
    baseUrl: 'https://api.green.kahoot.it',
    headers: {
      'Content-Type': 'application/json',
    },
  ));




  @override
  Future<AttemptModel> startAttempt({required String kahootId}) async {
    final path = '/attempts';
    final body = {'kahootId': kahootId};
    try{
      final response = await dio.post(path, data: body);
      if (response.statusCode == 401 || response.statusCode == 404){ 
        throw Exception('Error en la respuesta: $response.statusMessage');
      } else{
        return AttemptModel.fromJson(response.data);
      }
    }
      catch(e){
        throw Exception('Error al iniciar el intento: $e');
      }
  }
  

  @override
  Future<AttemptModel> getAttempt({required String attemptId}) async {
    final path = '/attempts/$attemptId';

    try{
      final response = await dio.get(path);
      if (response.statusCode == 404){ 
        throw Exception('Error en la respuesta: $response.statusMessage');
      } else{
        return AttemptModel.fromJson(response.data);
      }
    }
      catch(e){
        throw Exception('Error al obtener el intento: $e');
      }

  }

  @override
  Future<AnswerResultModel> submitAnswer({required String attemptId, required AnswerModel answer}) async {
    final path = '/attempts/$attemptId/answers';
    final body = answer.toJson();

    try{
      final response = await dio.post(path, data: body);
      if (response.statusCode == 401 || response.statusCode == 404){ 
        throw Exception('Error en la respuesta: $response.statusMessage');
      } else{
        return AnswerResultModel.fromJson(response.data);
      }
    }
      catch(e){
        throw Exception('Error al enviar la respuesta: $e');
      }
  } 

  @override
  Future<SummaryModel> getSummary({required String attemptId}) async {
    final path = '/attempts/$attemptId/summary';

    try{
      final response = await dio.get(path);
      if (response.statusCode == 401 || response.statusCode == 404){ 
        throw Exception('Error en la respuesta: $response.statusMessage');
      } else{
        return SummaryModel.fromJson(response.data);
      }
    }
      catch(e){
        throw Exception('Error al obtener el resumen: $e');
      }
  }
}