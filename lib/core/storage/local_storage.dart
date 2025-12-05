import 'package:shared_preferences/shared_preferences.dart';

class GameStorage {
  static const String attemptIdKey = 'attemptId';
  static const String kahootIdKey = 'kahootId';

  static Future<void> saveAttempt(String attemptId, String kahootId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(attemptIdKey, attemptId);
    await prefs.setString(kahootIdKey, kahootId);
  }

  static Future<Map<String, String?>> getAttempt() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'attemptId': prefs.getString(attemptIdKey),
      'kahootId': prefs.getString(kahootIdKey),
    };
  }

  static Future<void> clearAttempt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(attemptIdKey);
    await prefs.remove(kahootIdKey);
  }
}
