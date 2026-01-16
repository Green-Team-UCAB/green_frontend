import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;

class AiService {
  // Tu API Key (Validada ✅)
  static const String _apiKey = 'AIzaSyC9gR85mTN5vzH3dfSjjh8y4dmVtqm31Eo';

  // ✅ USAMOS EL ALIAS QUE FUNCIONÓ EN POWERSHELL
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent';

  AiService();

  Future<Map<String, dynamic>?> generateFullQuiz(String topic) async {
    dev.log(
        '🤖 [AiService] Solicitando quiz sobre: "$topic" (gemini-flash-latest)');

    final url = Uri.parse('$_baseUrl?key=$_apiKey');

    final prompt = '''
      Genera un quiz educativo sobre "$topic".
      Responde ÚNICAMENTE con un objeto JSON válido.
      NO uses bloques de código markdown (como ```json).
      
      Estructura JSON requerida:
      {
        "title": "Título sugerido",
        "description": "Descripción breve",
        "questions": [
          {
            "text": "¿Pregunta?",
            "type": "quiz",
            "timeLimit": 20,
            "points": 1000,
            "answers": [
              {"text": "Opción 1", "isCorrect": false},
              {"text": "Opción 2", "isCorrect": true},
              {"text": "Opción 3", "isCorrect": false},
              {"text": "Opción 4", "isCorrect": false}
            ]
          }
        ]
      }
      Genera 4 preguntas.
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
          // Este modelo soporta JSON mode nativo, lo que reduce errores de parseo
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
          dev.log('✅ [AiService] ¡Éxito! Respuesta recibida.');
          return _parseJsonSafe(rawText);
        }
      } else {
        dev.log(
            '⚠️ [AiService] Error HTTP ${response.statusCode}: ${response.body}');

        // Manejo de Cuota Excedida (Error 429)
        if (response.statusCode == 429) {
          dev.log('⏳ Cuota excedida momentáneamente. Intenta en 1 min.');
        }
      }
    } catch (e) {
      dev.log('❌ [AiService] Error de conexión: $e');
    }

    // Fallback al Mock si falla la red o la cuota
    return _getMockQuiz(topic);
  }

  Map<String, dynamic>? _parseJsonSafe(String text) {
    try {
      String clean =
          text.replaceAll('```json', '').replaceAll('```', '').trim();
      return jsonDecode(clean) as Map<String, dynamic>;
    } catch (e) {
      dev.log('Error parseando JSON: $e');
      return null;
    }
  }

  Map<String, dynamic> _getMockQuiz(String topic) {
    dev.log('🎭 Usando Mock Data (Respaldo)');
    return {
      "title": "Quiz sobre $topic (Modo Demo)",
      "description": "Generado localmente (Sin conexión a IA)",
      "questions": [
        {
          "text": "¿Pregunta de prueba sobre $topic?",
          "type": "quiz",
          "timeLimit": 20,
          "points": 1000,
          "answers": [
            {"text": "A", "isCorrect": true},
            {"text": "B", "isCorrect": false},
            {"text": "C", "isCorrect": false},
            {"text": "D", "isCorrect": false}
          ]
        },
        {
          "text": "Segunda pregunta mock",
          "type": "quiz",
          "timeLimit": 15,
          "points": 1000,
          "answers": [
            {"text": "Falso", "isCorrect": false},
            {"text": "Verdadero", "isCorrect": true}
          ]
        }
      ]
    };
  }
}
