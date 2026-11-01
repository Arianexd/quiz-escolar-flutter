import 'dart:convert';
import 'package:http/http.dart' as http;

class QuizQuestion {
  final String tipo;
  final String pregunta;
  final List<String> opciones;
  final int correcta;
  final String respuestaTexto;
  final List<String> variantesValidas;
  final String explicacion;

  const QuizQuestion({
    required this.tipo,
    required this.pregunta,
    required this.opciones,
    required this.correcta,
    required this.respuestaTexto,
    required this.variantesValidas,
    required this.explicacion,
  });

  bool get isText => tipo == 'texto';

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final tipo = (json['tipo'] ?? 'opcion_multiple') as String;
    final opciones = List<String>.from((json['opciones'] as List?) ?? []);

    if (tipo != 'texto' && tipo != 'opcion_multiple') {
      throw const FormatException('Tipo de pregunta desconocido');
    }

    final correcta = (json['correcta'] as int?) ?? 0;
    final respuestaTexto = (json['respuesta_texto'] ?? '') as String;

    if (tipo == 'opcion_multiple') {
      if (opciones.length != 4 ||
          opciones.map((e) => e.trim().toLowerCase()).toSet().length != 4 ||
          correcta < 0 ||
          correcta > 3) {
        throw const FormatException(
          'La pregunta de opción múltiple es inválida',
        );
      }
    } else if (respuestaTexto.trim().isEmpty) {
      throw const FormatException('La pregunta escrita no tiene respuesta');
    }

    return QuizQuestion(
      tipo: tipo,
      pregunta: json['pregunta'] as String,
      opciones: opciones,
      correcta: correcta,
      respuestaTexto: respuestaTexto,
      variantesValidas: List<String>.from(
        (json['variantes_validas'] as List?) ?? [],
      ),
      explicacion: json['explicacion'] as String,
    );
  }
}

class QuizApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<List<QuizQuestion>> generarPreguntas({
    required String posta,
    required String tema,
    required String modo,
    required String dificultad,
    required int cantidad,
    required List<String> anteriores,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/quiz/generar'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'posta': posta,
            'tema': tema,
            'modo': modo,
            'dificultad': dificultad,
            'cantidad': cantidad,
            'anteriores': anteriores,
          }),
        )
        .timeout(const Duration(seconds: 120));

    if (response.statusCode != 200) {
      String message = 'Error HTTP ${response.statusCode}';

      try {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is Map && decoded['detail'] != null) {
          message = decoded['detail'].toString();
        }
      } catch (_) {}

      throw Exception(message);
    }

    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    final questions = (data['preguntas'] as List)
        .map(
          (item) =>
              QuizQuestion.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();

    if (questions.length != cantidad) {
      throw const FormatException(
        'Gemini devolvió una cantidad incorrecta de preguntas',
      );
    }

    return questions;
  }
}
