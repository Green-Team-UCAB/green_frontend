import 'package:green_frontend/core/error/exceptions.dart';

class InputValidator {
  static void validateNotEmpty(String value, String fieldName) {
    if (value.trim().isEmpty) {
      throw InvalidInputException('El campo $fieldName no puede estar vacío');
    }
  }
  static void validateUsername(String value) {

    validateNotEmpty(value, 'username');


    final regex = RegExp(r'^[a-zA-Z0-9_]{6,20}$');
    if (!regex.hasMatch(value)) {
      throw InvalidInputException(
        'El nombre de usuario debe tener entre 6 y 20 caracteres y solo puede contener letras, números o guion bajo (_)',
      );
    }
  }

  static void validatePassword(String value) {

    validateNotEmpty(value, 'password');

    if (value.length < 8) {
      throw InvalidInputException('La contraseña debe tener al menos 6 caracteres');
    }
  }


}

  