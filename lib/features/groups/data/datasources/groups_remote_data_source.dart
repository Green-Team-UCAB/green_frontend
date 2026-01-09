import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../models/group_model.dart';
// Asegúrate de tener un modelo para el Leaderboard y Quiz asignado,
// si no, usaremos Map<String, dynamic> por ahora para ir rápido.

abstract class GroupsRemoteDataSource {
  Future<List<GroupModel>> getMyGroups();
  Future<GroupModel> createGroup(String name, String description);
  Future<GroupModel> joinGroup(String token);

  // --- NUEVOS MÉTODOS PARA EL DETALLE ---
  Future<List<dynamic>> getGroupQuizzes(String groupId);
  Future<List<dynamic>> getGroupLeaderboard(String groupId);
  Future<String> generateInvitationLink(String groupId);
}

class GroupsRemoteDataSourceImpl implements GroupsRemoteDataSource {
  final ApiClient apiClient;

  GroupsRemoteDataSourceImpl({required this.apiClient});

  Future<Options> _getAuthOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    // log('🕵️‍♂️ TOKEN FANTASMA ENCONTRADO: $token');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  @override
  Future<List<GroupModel>> getMyGroups() async {
    try {
      final options = await _getAuthOptions();
      final response = await apiClient.get(path: '/groups', options: options);
      final data = response.data;

      if (data is List) {
        return data.map((e) => GroupModel.fromJson(e)).toList();
      } else if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .map((e) => GroupModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      log('⚠️ Error Backend Groups: $e', error: e);
      return []; // Retorna vacío si falla para no romper la UI
    }
  }

  @override
  Future<GroupModel> createGroup(String name, String description) async {
    final options = await _getAuthOptions();
    final response = await apiClient.post(
      path: '/groups',
      data: {'name': name, 'description': description},
      options: options,
    );
    return GroupModel.fromJson(response.data);
  }

  @override
  Future<GroupModel> joinGroup(String token) async {
    final options = await _getAuthOptions();
    final response = await apiClient.post(
      path: '/groups/join',
      data: {'invitationToken': token},
      options: options,
    );
    return GroupModel.fromJson(response.data);
  }

  // --- IMPLEMENTACIÓN NUEVOS MÉTODOS ---

  @override
  Future<List<dynamic>> getGroupQuizzes(String groupId) async {
    try {
      final options = await _getAuthOptions();
      final response = await apiClient.get(
        path: '/groups/$groupId/quizzes',
        options: options,
      );

      // Según doc: retorna { data: [...] }
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return data['data'] as List;
      } else if (data is List) {
        return data;
      }
      return [];
    } catch (e) {
      log('⚠️ Error Get Quizzes: $e');
      return [];
    }
  }

  @override
  Future<List<dynamic>> getGroupLeaderboard(String groupId) async {
    try {
      final options = await _getAuthOptions();
      // Endpoint H8.9 Ranking del grupo
      final response = await apiClient.get(
        path: '/groups/$groupId/leaderboard',
        options: options,
      );

      if (response.data is List) {
        return response.data as List;
      }
      return [];
    } catch (e) {
      log('⚠️ Error Get Leaderboard: $e');
      return [];
    }
  }

  @override
  Future<String> generateInvitationLink(String groupId) async {
    try {
      final options = await _getAuthOptions();
      // Endpoint H8.3 (Generar Link)
      // Doc dice: POST /groups/:groupId/invitations con body { expiresIn: "7d" }
      final response = await apiClient.post(
        path: '/groups/$groupId/invitations',
        data: {"expiresIn": "7d"},
        options: options,
      );

      // La respuesta es { groupId, invitationLink, expiresAt }
      final data = response.data;
      return data['invitationLink'] ?? 'Error al generar link';
    } catch (e) {
      log('⚠️ Error Inviting: $e');
      throw Exception("No se pudo generar la invitación");
    }
  }
}
