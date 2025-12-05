import 'package:dio/dio.dart';
import 'package:green_frontend/features/single_player/infraestructure/models/answer_model.dart';
import 'package:green_frontend/features/single_player/infraestructure/models/answer_result_model.dart';
import 'package:green_frontend/features/single_player/infraestructure/models/attempt_model.dart';
import 'package:green_frontend/features/single_player/infraestructure/models/summary_model.dart';
import 'package:green_frontend/core/error/exceptions.dart';
import 'package:green_frontend/core/network/api_client.dart';
import 'package:green_frontend/core/network/input_validator.dart';
import 'package:green_frontend/features/single_player/infraestructure/models/kahoot_model.dart';


//Contrato de dataSource para el juego single Player
abstract class AsyncGameDataSource {
  Future<AttemptModel> startAttempt({
    required String kahootId,
  });
  
  Future<AttemptModel> getAttempt({
    required String attemptId,
  });
  
  Future<AnswerResultModel> submitAnswer({
    required String attemptId,
    required AnswerModel answer,
  });
  
  Future<SummaryModel> getSummary({
    required String attemptId,
  });
  Future<KahootModel> inspectKahoot({
    required String kahootId 
  });
}


// Implementación del dataSource
class AsyncGameDataSourceImpl implements AsyncGameDataSource {
  final ApiClient client;
  static const String _attemptsPath = '/attempts';
  
  AsyncGameDataSourceImpl({required Dio dio}) 
      : client = ApiClient(dio);
  
  AsyncGameDataSourceImpl.withBaseUrl(String baseUrl)
      : client = ApiClient.withBaseUrl(baseUrl);
  
  @override
  Future<AttemptModel> startAttempt({
    required String kahootId,
  }) async {
    InputValidator.validateNotEmpty(kahootId, 'kahootId');
    
    final response = await client.post<Map<String, dynamic>>(
      path: _attemptsPath,
      data: {'kahootId': kahootId},
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return AttemptModel.fromJson(response.data);
    }
    
    throw ServerException('Unexpected response status: ${response.statusCode}');
  }
  
  @override
  Future<AttemptModel> getAttempt({
    required String attemptId,
  }) async {
    InputValidator.validateNotEmpty(attemptId, 'attemptId');
    
    final response = await client.get<Map<String, dynamic>>(
      path: '$_attemptsPath/$attemptId',
    );
    
    if (response.statusCode == 200) {
      return AttemptModel.fromJson(response.data);
    }
    
    throw ServerException('Unexpected response status: ${response.statusCode}');
  }
  
  @override
  Future<AnswerResultModel> submitAnswer({
    required String attemptId,
    required AnswerModel answer,
  }) async {
    InputValidator.validateNotEmpty(attemptId, 'attemptId');
    
    final response = await client.post<Map<String, dynamic>>(
      path: '$_attemptsPath/$attemptId/answers',
      data: answer.toJson(),
    );
    
    if (response.statusCode == 200) {
      return AnswerResultModel.fromJson(response.data);
    }
    
    throw ServerException('Unexpected response status: ${response.statusCode}');
  }
  
  @override
  Future<SummaryModel> getSummary({
    required String attemptId,
  }) async {
    InputValidator.validateNotEmpty(attemptId, 'attemptId');
    
    final response = await client.get<Map<String, dynamic>>(
      path: '$_attemptsPath/$attemptId/summary',
    );
    
    if (response.statusCode == 200) {
      return SummaryModel.fromJson(response.data);
    }
    
    throw ServerException('Unexpected response status: ${response.statusCode}');
  }

  @override
  Future<KahootModel> inspectKahoot({ 
    required String kahootId 
  }) async {
    InputValidator.validateNotEmpty(kahootId, 'kahootId');
    
    final resp = await client.get<Map<String, dynamic>>(
      path: '/kahoots/inspect/$kahootId'
    );
    if (resp.statusCode == 200) {
      return KahootModel.fromJson(resp.data);
    }
    
    throw ServerException('Unexpected status ${resp.statusCode}');
}
}