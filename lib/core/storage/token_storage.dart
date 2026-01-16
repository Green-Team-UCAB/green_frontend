import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

class TokenStorage {
  static const _secureStorage = FlutterSecureStorage();

  // ✅ CLAVE CORRECTA DETECTADA
  static const _primaryKey = 'auth_token';
  // Claves secundarias por compatibilidad si cambiaste algo antes
  static const _legacyKey = 'accessToken';

  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _primaryKey, value: token);
    log('💾 Token guardado en SecureStorage con clave: $_primaryKey');
  }

  static Future<String?> getToken() async {
    // 1. Intentar con la clave principal 'auth_token'
    String? token = await _secureStorage.read(key: _primaryKey);

    // 2. Si falla, intentar con 'accessToken' (por si acaso)
    if (token == null) {
      token = await _secureStorage.read(key: _legacyKey);
    }

    // 3. Fallback a SharedPreferences (por si la librería cambió)
    if (token == null) {
      final prefs = await SharedPreferences.getInstance();
      token ??= prefs.getString(_primaryKey) ?? prefs.getString(_legacyKey);
    }

    if (token != null) {
      log('🔓 Token recuperado exitosamente (${token.substring(0, 10)}...)');
    } else {
      log('⚠️ TokenStorage: No se encontró ningún token.');
    }

    return token;
  }

  static Future<void> deleteToken() async {
    await _secureStorage.delete(key: _primaryKey);
    await _secureStorage.delete(key: _legacyKey);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_primaryKey);
    await prefs.remove(_legacyKey);
  }
}
