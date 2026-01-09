import '../../../../core/network/api_client.dart';
import '../models/group_model.dart';

abstract class GroupsRemoteDataSource {
  Future<List<GroupModel>> getMyGroups();
  Future<GroupModel> createGroup(String name, String description);
  Future<GroupModel> joinGroup(String token);
  Future<Map<String, dynamic>> getGroupDetails(String groupId);
  Future<String> generateInvitationLink(String groupId);
  Future<void> assignQuiz(String groupId, String quizId, String availableUntil);
  Future<void> updateGroup(String groupId, String name, String description);
  Future<void> kickMember(String groupId, String memberId);
  Future<void> deleteGroup(String groupId);
}

class GroupsRemoteDataSourceImpl implements GroupsRemoteDataSource {
  final ApiClient apiClient;

  GroupsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<GroupModel>> getMyGroups() async {
    // Usamos el ApiClient que ya inyecta el token automáticamente
    final response = await apiClient.get(path: '/groups');

    // La API devuelve una lista directa: [ {...}, {...} ]
    return (response.data as List).map((e) => GroupModel.fromJson(e)).toList();
  }

  @override
  Future<GroupModel> createGroup(String name, String description) async {
    final response = await apiClient.post(
      path: '/groups',
      data: {'name': name, 'description': description},
    );

    return GroupModel.fromJson(response.data);
  }

  @override
  Future<GroupModel> joinGroup(String token) async {
    final response = await apiClient.post(
      path: '/groups/join',
      data: {'token': token},
    );
    return GroupModel.fromJson(response.data);
  }

  @override
  Future<Map<String, dynamic>> getGroupDetails(String groupId) async {
    final response = await apiClient.get(path: '/groups/$groupId');
    return response.data;
  }

  @override
  Future<String> generateInvitationLink(String groupId) async {
    final response = await apiClient.post(path: '/groups/$groupId/invite');
    return response.data['link'];
  }

  @override
  Future<void> assignQuiz(
    String groupId,
    String quizId,
    String availableUntil,
  ) async {
    await apiClient.post(
      path: '/groups/$groupId/assign',
      data: {'quizId': quizId, 'availableUntil': availableUntil},
    );
  }

  @override
  Future<void> updateGroup(
    String groupId,
    String name,
    String description,
  ) async {
    await apiClient.put(
      path: '/groups/$groupId',
      data: {'name': name, 'description': description},
    );
  }

  @override
  Future<void> kickMember(String groupId, String memberId) async {
    await apiClient.delete(path: '/groups/$groupId/members/$memberId');
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    await apiClient.delete(path: '/groups/$groupId');
  }
}
