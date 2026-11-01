import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedAnswer {
  final String question;
  final List<String> options;
  final int correctIndex;
  final int selectedIndex;
  final String explanation;
  final String type;
  final String writtenAnswer;
  final String correctText;
  final bool? wasCorrect;

  const SavedAnswer({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.selectedIndex,
    required this.explanation,
    this.type = 'opcion_multiple',
    this.writtenAnswer = '',
    this.correctText = '',
    this.wasCorrect,
  });

  bool get isText => type == 'texto';

  bool get isCorrect =>
      isText ? (wasCorrect ?? false) : correctIndex == selectedIndex;

  Map<String, dynamic> toJson() => {
    'question': question,
    'options': options,
    'correctIndex': correctIndex,
    'selectedIndex': selectedIndex,
    'explanation': explanation,
    'type': type,
    'writtenAnswer': writtenAnswer,
    'correctText': correctText,
    'wasCorrect': wasCorrect,
  };

  factory SavedAnswer.fromJson(Map<String, dynamic> json) {
    return SavedAnswer(
      question: json['question'] as String,
      options: List<String>.from((json['options'] as List?) ?? []),
      correctIndex: (json['correctIndex'] as int?) ?? 0,
      selectedIndex: (json['selectedIndex'] as int?) ?? -1,
      explanation: (json['explanation'] ?? '') as String,
      type: (json['type'] ?? 'opcion_multiple') as String,
      writtenAnswer: (json['writtenAnswer'] ?? '') as String,
      correctText: (json['correctText'] ?? '') as String,
      wasCorrect: json['wasCorrect'] as bool?,
    );
  }
}

class QuizAttempt {
  final String id;
  final DateTime date;
  final String subject;
  final String topic;
  final String mode;
  final String difficulty;
  final List<SavedAnswer> answers;

  const QuizAttempt({
    required this.id,
    required this.date,
    required this.subject,
    required this.topic,
    required this.mode,
    required this.difficulty,
    required this.answers,
  });

  int get total => answers.length;
  int get correct => answers.where((a) => a.isCorrect).length;
  int get incorrect => total - correct;
  int get percentage => total == 0 ? 0 : (correct / total * 100).round();

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'subject': subject,
    'topic': topic,
    'mode': mode,
    'difficulty': difficulty,
    'answers': answers.map((e) => e.toJson()).toList(),
  };

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      subject: json['subject'] as String,
      topic: json['topic'] as String,
      mode: json['mode'] as String,
      difficulty: json['difficulty'] as String,
      answers: (json['answers'] as List)
          .map((e) => SavedAnswer.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class AppStore extends ChangeNotifier {
  AppStore._();

  static final AppStore instance = AppStore._();

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  static const _nameKey = 'cuestapp_name_v1';
  static const _photoKey = 'cuestapp_photo_v1';
  static const _historyKey = 'cuestapp_history_v1';

  String name = 'Estudiante';
  String? photoBase64;
  final List<QuizAttempt> _attempts = [];

  List<QuizAttempt> get attempts => List.unmodifiable(_attempts);
  int get completedQuizzes => _attempts.length;
  int get totalCorrect => _attempts.fold(0, (sum, a) => sum + a.correct);
  int get totalQuestions => _attempts.fold(0, (sum, a) => sum + a.total);
  int get accuracy =>
      totalQuestions == 0 ? 0 : (totalCorrect / totalQuestions * 100).round();

  Future<void> initialize() async {
    name = await _prefs.getString(_nameKey) ?? 'Estudiante';
    photoBase64 = await _prefs.getString(_photoKey);

    final saved = await _prefs.getString(_historyKey);

    _attempts.clear();

    if (saved != null) {
      try {
        final items = jsonDecode(saved) as List;
        _attempts.addAll(
          items.map(
            (e) => QuizAttempt.fromJson(Map<String, dynamic>.from(e as Map)),
          ),
        );
        _attempts.sort((a, b) => b.date.compareTo(a.date));
      } catch (error) {
        debugPrint('Error leyendo historial: $error');
      }
    }

    notifyListeners();
  }

  Future<void> updateName(String newName) async {
    final clean = newName.trim();
    if (clean.isEmpty || clean.length > 40) {
      throw ArgumentError('Nombre inválido');
    }
    await _prefs.setString(_nameKey, clean);
    name = clean;
    notifyListeners();
  }

  Future<void> updatePhoto(Uint8List bytes) async {
    if (bytes.lengthInBytes > 350000) {
      throw ArgumentError('Foto demasiado grande');
    }
    final encoded = base64Encode(bytes);
    await _prefs.setString(_photoKey, encoded);
    photoBase64 = encoded;
    notifyListeners();
  }

  Future<void> removePhoto() async {
    await _prefs.remove(_photoKey);
    photoBase64 = null;
    notifyListeners();
  }

  Future<void> saveAttempt(QuizAttempt attempt) async {
    final updated = [attempt, ..._attempts]
      ..sort((a, b) => b.date.compareTo(a.date));

    await _prefs.setString(
      _historyKey,
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );

    _attempts
      ..clear()
      ..addAll(updated);

    notifyListeners();
  }
}
