import 'dart:convert';
import '../../../../core/network/api_client.dart';
import '../models/group_model.dart';
import '../models/group_quiz_assignment_model.dart';
import '../models/group_leaderboard_entry_model.dart';
import '../models/group_member_model.dart';

abstract class GroupsRemoteDataSource {
  Future<List<GroupModel>> getMyGroups();
  Future<GroupModel> createGroup(String name, String description);
  Future<GroupModel> joinGroup(String token);

  // ✅ Métodos separados y tipados correctamente
  Future<List<GroupQuizAssignmentModel>> getGroupQuizzes(String groupId);
  Future<List<GroupLeaderboardEntryModel>> getGroupLeaderboard(String groupId);
  Future<List<GroupMemberModel>> getGroupMembers(String groupId);

  Future<String> generateInvitationLink(String groupId);

  // ✅ Asignación con fechas correctas
  Future<void> assignQuiz(String groupId, String quizId, DateTime availableFrom,
      DateTime availableUntil);

  Future<void> updateGroup(String groupId, String name, String description);
  Future<void> kickMember(String groupId, String memberId);
  Future<void> deleteGroup(String groupId);
}

class GroupsRemoteDataSourceImpl implements GroupsRemoteDataSource {
  final ApiClient apiClient;

  GroupsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<GroupModel>> getMyGroups() async {
    final response = await apiClient.get(path: '/groups');
    // Mapeo seguro de la lista
    return (response.data as List).map((e) => GroupModel.fromJson(e)).toList();
  }

  @override
  Future<GroupModel> createGroup(String name, String description) async {
    final response = await apiClient.post(
      path: '/groups',
      data: {
        'name': name,
        'description': description
      }, // Descripción opcional según tu doc?
    );
    return GroupModel.fromJson(response.data);
  }

  @override
  Future<GroupModel> joinGroup(String token) async {
    final response = await apiClient.post(
      path: '/groups/join',
      // ⚠️ CORRECCIÓN IMPORTANTE: La doc dice "invitationToken", no "token"
      data: {'invitationToken': token},
    );

    // La doc dice que retorna info del grupo al unirse.
    return GroupModel.fromJson(response.data);
  }

  @override
  Future<List<GroupQuizAssignmentModel>> getGroupQuizzes(String groupId) async {
    // ✅ URL ESPECÍFICA: Esto evita mezclar kahoots de otros grupos
    final response = await apiClient.get(path: '/groups/$groupId/quizzes');

    // La doc dice: { data: [...] }
    final data = response.data;
    List listData = [];

    if (data is Map && data.containsKey('data')) {
      listData = data['data'];
    } else if (data is List) {
      listData = data;
    }

    return listData.map((e) => GroupQuizAssignmentModel.fromJson(e)).toList();
  }

  @override
  Future<List<GroupLeaderboardEntryModel>> getGroupLeaderboard(
      String groupId) async {
    // ✅ URL ESPECÍFICA
    final response = await apiClient.get(path: '/groups/$groupId/leaderboard');

    // La doc dice que retorna un array directo [...]
    return (response.data as List)
        .map((e) => GroupLeaderboardEntryModel.fromJson(e))
        .toList();
  }

  @override
  Future<List<GroupMemberModel>> getGroupMembers(String groupId) async {
    try {
      final response = await apiClient.get(path: '/groups/$groupId/members');
      print("🐛 JSON MEMBER LIST: ${jsonEncode(response.data)}");

      final membersList = response.data as List;
      final List<GroupMemberModel> enrichedMembers = [];

      // Create a list of futures to fetch user profiles in parallel
      final futures = membersList.map((memberJson) async {
        final userId = memberJson['userId'] ?? memberJson['id'];
        String name = 'Usuario';
        String email = '';

        if (userId != null) {
          try {
            // Since there is no public endpoint for getting another user's profile by ID in the docs provided,
            // and /user/profile is only for the current user, this is a best-effort approach.
            // However, based on the need to show names "arausyta" and "mafeee",
            // we will attempt to fetch from /users/$userId which is a standard convention.
            // If that fails, we fallback to the "name" from memberJson if it exists (it doesn't currently).
            final userResponse = await apiClient.get(path: '/users/$userId');
            if (userResponse.data != null) {
              final userData = userResponse.data;
              // Check various locations for name
              name = userData['name'] ??
                  userData['username'] ??
                  userData['user']?['name'] ??
                  userData['user']?['username'] ??
                  'Usuario';
              email = userData['email'] ?? userData['user']?['email'] ?? '';
            }
          } catch (e) {
            print("⚠️ Could not fetch details for user $userId: $e");
          }
        }

        // Construct the model merging the member role/joined info with the fetched user details
        return GroupMemberModel.fromJson({
          ...memberJson,
          'name': name,
          'email': email,
        });
      });

      enrichedMembers.addAll(await Future.wait(futures));

      // If we still have 'Usuario' names, try to enrich from leaderboard as last resort
      // because the user reported names are visible in leaderboard
      final bool anyDefaultName =
          enrichedMembers.any((m) => m.name == 'Usuario');
      if (anyDefaultName) {
        try {
          final leaderboardResponse =
              await apiClient.get(path: '/groups/$groupId/leaderboard');
          final leaderboard = leaderboardResponse.data as List;

          for (var i = 0; i < enrichedMembers.length; i++) {
            var member = enrichedMembers[i];
            if (member.name == 'Usuario') {
              // Find this user in leaderboards
              final entry = leaderboard.firstWhere(
                (l) => l['userId'] == member.id,
                orElse: () => null,
              );
              if (entry != null && entry['name'] != null) {
                // Reconstruct member with name from leaderboard
                enrichedMembers[i] = GroupMemberModel(
                  id: member.id,
                  name: entry['name'],
                  email: member.email,
                  role: member.role,
                );
              }
            }
          }
        } catch (e) {
          print("⚠️ Could not fetch leaderboard for fallback names: $e");
        }
      }

      return enrichedMembers;
    } catch (e) {
      print("🐛 ERROR FETCHING MEMBERS: $e");
      // Fallback to leaderboard if members fails
      final response =
          await apiClient.get(path: '/groups/$groupId/leaderboard');
      return (response.data as List)
          .map((e) => GroupMemberModel.fromJson(e))
          .toList();
    }
  }

  @override
  Future<String> generateInvitationLink(String groupId) async {
    // ⚠️ CORRECCIÓN: La doc dice "/invitations", no "/invite"
    // ⚠️ CORRECCIÓN: La doc dice body { "expiresIn": "7d" }
    final response = await apiClient.post(
      path: '/groups/$groupId/invitations',
      data: {'expiresIn': '7d'},
    );

    // La doc dice response: { "invitationLink": "..." }
    return response.data['invitationLink'];
  }

  @override
  Future<void> assignQuiz(
    String groupId,
    String quizId,
    DateTime availableFrom,
    DateTime availableUntil,
  ) async {
    await apiClient.post(
      path: '/groups/$groupId/quizzes',
      data: {
        'quizId': quizId,
        'availableFrom': availableFrom.toIso8601String(),
        'availableUntil': availableUntil.toIso8601String(),
      },
    );
  }

  @override
  Future<void> updateGroup(
      String groupId, String name, String description) async {
    await apiClient.patch(
      // La doc dice PATCH, tu código tenía PUT
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
