import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;

class AiService {
  static const String _apiKey = 'AIzaSyBiN1xsuPduKG5CqTTMbOnJSJMfKuTyDbo';

  // Usamos el modelo confirmado
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  AiService();

  Future<Map<String, dynamic>?> generateFullQuiz(String topic) async {
    dev.log('🤖 [AiService] Solicitando quiz sobre: "$topic"');

    final url = Uri.parse('$_baseUrl?key=$_apiKey');

    final prompt = '''
      Crea un quiz educativo sobre "$topic".
      Responde ÚNICAMENTE con un JSON válido.
      El JSON debe tener esta estructura exacta:
      {
        "title": "Título sugerido",
        "description": "Descripción sugerida",
        "questions": [
          {
            "text": "¿Pregunta?",
            "type": "quiz",
            "timeLimit": 20,
            "points": 1000,
            "answers": [
              {"text": "Opción A", "isCorrect": false},
              {"text": "Opción B", "isCorrect": true},
              {"text": "Opción C", "isCorrect": false},
              {"text": "Opción D", "isCorrect": false}
            ]
          }
        ]
      }
      Genera al menos 4 preguntas.
    ''';

    try {
      final body = jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.7,
          "responseMimeType": "application/json"
        }
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String? rawText =
            data['candidates']?[0]?['content']?['parts']?[0]?['text'];

        if (rawText != null) {
          dev.log('✅ [AiService] Éxito con la IA real');
          return _parseJsonFromText(rawText);
        }
      } else {
        // Si hay error (429 Quota, 500 Server, etc), mostramos log pero NO rompemos la app
        dev.log(
            '⚠️ [AiService] Falló la IA (${response.statusCode}). Usando Mock de respaldo.');
      }
    } catch (e) {
      dev.log('❌ [AiService] Excepción de red: $e. Usando Mock de respaldo.');
    }

    // 🛡️ SALVAVIDAS: Si llegamos aquí, algo falló. Devolvemos el Mock.
    return _getMockQuiz(topic);
  }

  /// Parsea el JSON que viene de la IA
  Map<String, dynamic>? _parseJsonFromText(String text) {
    try {
      final cleanText =
          text.replaceAll('```json', '').replaceAll('```', '').trim();
      final startIndex = cleanText.indexOf('{');
      final endIndex = cleanText.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1) {
        final jsonString = cleanText.substring(startIndex, endIndex + 1);
        return Map<String, dynamic>.from(jsonDecode(jsonString));
      }
    } catch (e) {
      dev.log('⚠️ Error parseando JSON: $e');
    }
    return null;
  }

  /// 🎭 MOCK DATA: Genera un quiz falso pero válido si la IA falla
  Map<String, dynamic> _getMockQuiz(String topic) {
    dev.log('🎭 Generando datos simulados para "$topic"');
    return {
      "title": "Quiz sobre $topic (Modo Demo)",
      "description":
          "Este quiz fue generado automáticamente para la demostración sobre $topic.",
      "questions": [
        {
          "text": "¿Cuál es el concepto principal de $topic?",
          "type": "quiz",
          "timeLimit": 20,
          "points": 1000,
          "answers": [
            {"text": "Es algo irrelevante", "isCorrect": false},
            {"text": "Es el concepto clave A", "isCorrect": true},
            {"text": "No tiene definición", "isCorrect": false},
            {"text": "Es una fruta", "isCorrect": false}
          ]
        },
        {
          "text": "¿Verdadero o Falso? $topic es importante.",
          "type": "quiz", // O true_false si tu app lo soporta en la UI
          "timeLimit": 10,
          "points": 500,
          "answers": [
            {"text": "Verdadero", "isCorrect": true},
            {"text": "Falso", "isCorrect": false}
          ]
        },
        {
          "text": "¿En qué año se popularizó $topic?",
          "type": "quiz",
          "timeLimit": 20,
          "points": 1000,
          "answers": [
            {"text": "1990", "isCorrect": false},
            {"text": "2024", "isCorrect": true},
            {"text": "1500", "isCorrect": false},
            {"text": "Nunca", "isCorrect": false}
          ]
        },
        {
          "text": "Selecciona la característica de $topic",
          "type": "quiz",
          "timeLimit": 30,
          "points": 2000,
          "answers": [
            {"text": "Innovación", "isCorrect": true},
            {"text": "Aburrimiento", "isCorrect": false},
            {"text": "Lentitud", "isCorrect": false},
            {"text": "Ninguna de las anteriores", "isCorrect": false}
          ]
        }
      ]
    };
  }
}
