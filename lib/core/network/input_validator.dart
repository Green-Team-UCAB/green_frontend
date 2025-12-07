import 'package:green_frontend/core/error/exceptions.dart';

class InputValidator {
  static void validateNotEmpty(String value, String fieldName) {
    if (value.trim().isEmpty) {
      throw InvalidInputException('$fieldName cannot be empty');
    }
  }
}