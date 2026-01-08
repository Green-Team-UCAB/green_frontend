import 'package:green_frontend/features/auth/infraestructure/models/user_model.dart';
import 'package:dio/dio.dart';
import 'package:green_frontend/core/error/exceptions.dart';
import 'package:green_frontend/core/network/api_client.dart';
import 'package:green_frontend/core/network/input_validator.dart';


//Contrato del DataSource para la autenticación

abstract class AuthDataSource {
  Future<UserModel> register({
    required String userName,
    required String email,
    required String password,
  });

  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<void> resetPassword({
    required String email,
  });

  Future<UserModel> updateProfile({
    required String id,
    required Map<String, dynamic> body,
  });
}

// Implementación del DataSource 
class AuthRemoteDataSourceImpl implements AuthDataSource {
  final ApiClient client;
  static const String _authPath = '/auth';
  static const String _usersPath = '/users';

  AuthRemoteDataSourceImpl({required Dio dio})
      : client = ApiClient(dio);

  AuthRemoteDataSourceImpl.withBaseUrl(String baseUrl)
      : client = ApiClient.withBaseUrl(baseUrl);

  @override
  Future<UserModel> register({
    required String userName,
    required String email,
    required String password,
  }) async {
    InputValidator.validateNotEmpty(userName, 'userName');
    InputValidator.validateNotEmpty(email, 'email');
    InputValidator.validateNotEmpty(password, 'password');

    final response = await client.post<Map<String, dynamic>>(
      path: '$_authPath/register',
      data: {
        "email": email,
        "userName": userName,
        "password": password,
      },
    );

    if (response.statusCode == 201) {
      return UserModel.fromJson(response.data);
    }
    throw ServerException('Unexpected status: ${response.statusCode}');
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    InputValidator.validateNotEmpty(email, 'email');
    InputValidator.validateNotEmpty(password, 'password');

    final response = await client.post<Map<String, dynamic>>(
      path: '$_authPath/login',
      data: {
        "email": email,
        "password": password,
      },
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data);
    }
    throw AuthException('Login failed: ${response.statusCode}');
  }

  @override
  Future<void> logout() async {
    final response = await client.post<Map<String, dynamic>>(
      path: '$_authPath/logout',
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }
    throw ServerException('Unexpected status: ${response.statusCode}');
  }

  @override
  Future<void> resetPassword({required String email}) async {
    InputValidator.validateNotEmpty(email, 'email');

    final response = await client.post<Map<String, dynamic>>(
      path: '$_authPath/reset-password',
      data: {"email": email},
    );

    if (response.statusCode == 200) {
      return;
    }
    throw ServerException('Unexpected status: ${response.statusCode}');
  }

  @override
  Future<UserModel> updateProfile({
    required String id,
    required Map<String, dynamic> body,
  }) async {
    InputValidator.validateNotEmpty(id, 'id');

    final response = await client.patch<Map<String, dynamic>>(
      path: '$_usersPath/$id',
      data: body,
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data);
    }
    throw ServerException('Unexpected status: ${response.statusCode}');
  }
}


