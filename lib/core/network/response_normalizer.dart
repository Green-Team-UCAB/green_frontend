import 'dart:convert';

class ResponseNormalizer {
  static dynamic normalize(dynamic data) {
    if (data is String) {
      try {
        return json.decode(data);
      } catch (_) {
        return data;
      }
    }
    return data;
  }
}