import 'package:green_frontend/features/auth/infraestructure/models/user_model.dart';
import 'package:green_frontend/core/error/exceptions.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/network/api_client.dart';
import 'package:green_frontend/core/network/input_validator.dart';

//Contrato del DataSource para la autenticación

abstract class AuthDataSource {
  Future<UserModel> register({
    required String userName,
    required String email,
    required String password,
    required String name,           
    required String type,           
    String? description,            
    String? avatarAssetUrl,         
  });

  Future<UserModel> login({required String username, required String password});

  Future<void> logout();

  Future<void> resetPassword({required String email});

  Future<UserModel> updateProfile({
    required Map<String, dynamic> body,
  });

  Future<UserModel> getUserProfile();
}

// Implementación del DataSource
class AuthRemoteDataSourceImpl implements AuthDataSource {
  final ApiClient client;
  static const String _authPath = '/auth';
  static const String _usersPath = '/users';

  AuthRemoteDataSourceImpl({required this.client});

  AuthRemoteDataSourceImpl.withBaseUrl(String baseUrl)
    : client = ApiClient.withBaseUrl(baseUrl);
  /*
  @override
  Future<UserModel> register({
    required String userName,
    required String email,
    required String password,
  }) async {
    InputValidator.validateNotEmpty(userName, 'username');
    InputValidator.validateNotEmpty(email, 'email');
    InputValidator.validateNotEmpty(password, 'password');

    final response = await client.post<Map<String, dynamic>>(
      path: _authPath,
      data: {
        "email": email,
        "username": userName,
        "password": password,
      },
    );

    if (response.statusCode == 201) {
      return UserModel.fromJson(response.data);
    }
    throw ServerException('Unexpected status: ${response.statusCode}');
  }
*/

  @override
  @override
Future<UserModel> register({
  required String userName,
  required String email,
  required String password,
  required String name,
  required String type,
  String? description,
  String? avatarAssetUrl,
}) async {
  // El "Esqueleto JSON (Request)" pide estos campos específicos
  final response = await client.post<Map<String, dynamic>>(
    path: '/user/register', 
    data: {
      "email": email,
      "username": userName,
      "password": password,
      "name": name,
      "type": type,
    },
  );

  if (response.statusCode == 201) {
    // Retorna el usuario con sus datos
    return UserModel.fromJson(response.data);
  }
  
  throw ServerException('Error 400: Datos incorrectos'); 
}

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    InputValidator.validateNotEmpty(username, 'username');
    InputValidator.validateNotEmpty(password, 'password');

    final response = await client.post<Map<String, dynamic>>(
      path: '$_authPath/login',
      data: {"username": username, "password": password},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;

      final userJson = data['user'] as Map<String, dynamic>;
      final token = data['token'] as String;

      client.setAuthToken(token);
      await TokenStorage.saveToken(token);

      return UserModel.fromJson(userJson);
    }
    throw AuthException('Login failed: ${response.statusCode}');
  }

  @override
  Future<void> logout() async {
    final response = await client.post<Map<String, dynamic>>(
      path: '$_authPath/logout',
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      await TokenStorage.deleteToken();
      client.clearAuthToken();
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
  @override
  Future<UserModel> updateProfile({
    required Map<String, dynamic> body,
  }) async {
    // 1. La documentación indica el path '/user/profile/' y método PATCH
    final response = await client.patch<Map<String, dynamic>>(
      path: '/user/profile/',
      data: body,
    );

    if (response.statusCode == 200) {
      final data = response.data;
      
      // 2. La documentación muestra que el recurso actualizado viene dentro de la llave "user"
      if (data != null && data.containsKey('user')) {
        return UserModel.fromJson(data['user'] as Map<String, dynamic>);
      }
      throw ServerException('Formato de respuesta inesperado');
    }

    // 3. Manejo de errores específicos según la documentación
    if (response.statusCode == 400) {
      throw ServerException('Datos incorrectos');
    }
    
    if (response.statusCode == 401) {
      throw AuthException('Credenciales inválidas');
    }

    throw ServerException('Unexpected status: ${response.statusCode}');
  }

  @override
  Future<UserModel> getUserProfile() async {
    // La documentación especifica el path '/user/profile/' y método GET
    final response = await client.get<Map<String, dynamic>>(
      path: '/user/profile/',
    );

    if (response.statusCode == 200) {
      final data = response.data;
      // La documentación muestra que el objeto usuario viene dentro de la llave "user"
      if (data != null && data.containsKey('user')) {
        return UserModel.fromJson(data['user'] as Map<String, dynamic>);
      }
      throw ServerException('Formato de respuesta inesperado');
    }

    if (response.statusCode == 401) {
      throw AuthException('Credenciales inválidas');
    }

    throw ServerException('Error al recuperar perfil: ${response.statusCode}');
  }
}
