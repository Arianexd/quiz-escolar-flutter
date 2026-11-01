import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/answer_checker.dart';
import '../../data/app_store.dart';
import '../../data/services/quiz_api_service.dart';
import '../history/history_screen.dart';

class QuizScreen extends StatefulWidget {
  final String subject;
  final String topic;
  final String mode;
  final String difficulty;
  final int quantity;

  const QuizScreen({
    super.key,
    required this.subject,
    required this.topic,
    required this.mode,
    required this.difficulty,
    required this.quantity,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static final Map<String, List<String>> _history = {};

  late Future<List<QuizQuestion>> _future;
  final TextEditingController _textController = TextEditingController();
  final List<SavedAnswer> _answers = [];

  int _current = 0;
  int _score = 0;
  int? _selected;
  bool? _textCorrect;
  bool _answered = false;
  bool _finished = false;
  bool _saving = false;
  QuizAttempt? _savedAttempt;

  String get _historyKey => '${widget.subject}|${widget.topic}|${widget.mode}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _load() {
    _future = QuizApiService.generarPreguntas(
      posta: widget.subject,
      tema: widget.topic,
      modo: widget.mode,
      dificultad: widget.difficulty,
      cantidad: widget.quantity,
      anteriores: List.of(_history[_historyKey] ?? []),
    );
  }

  void _remember(String question) {
    final list = _history.putIfAbsent(_historyKey, () => []);
    list.add(question);
    if (list.length > 30) list.removeAt(0);
  }

  void _newQuiz() {
    if (_saving) return;
    setState(() {
      _current = 0;
      _score = 0;
      _selected = null;
      _textCorrect = null;
      _answered = false;
      _finished = false;
      _savedAttempt = null;
      _answers.clear();
      _textController.clear();
      _load();
    });
  }

  void _answerOption(int index, QuizQuestion question) {
    if (_answered || _saving) return;

    setState(() {
      _selected = index;
      _answered = true;

      if (index == question.correcta) _score++;

      _answers.add(
        SavedAnswer(
          question: question.pregunta,
          options: List.of(question.opciones),
          correctIndex: question.correcta,
          selectedIndex: index,
          explanation: question.explicacion,
        ),
      );

      _remember(question.pregunta);
    });
  }

  void _answerText(QuizQuestion question) {
    if (_answered || _saving) return;

    final input = _textController.text.trim();
    if (input.isEmpty) return;

    final correct = AnswerChecker.isCorrect(
      userAnswer: input,
      correctAnswer: question.respuestaTexto,
      variants: question.variantesValidas,
    );

    setState(() {
      _answered = true;
      _textCorrect = correct;

      if (correct) _score++;

      _answers.add(
        SavedAnswer(
          question: question.pregunta,
          options: const [],
          correctIndex: -1,
          selectedIndex: -1,
          explanation: question.explicacion,
          type: 'texto',
          writtenAnswer: input,
          correctText: question.respuestaTexto,
          wasCorrect: correct,
        ),
      );

      _remember(question.pregunta);
    });
  }

  Future<void> _next(List<QuizQuestion> questions) async {
    if (!_answered || _saving) return;

    if (_current < questions.length - 1) {
      setState(() {
        _current++;
        _selected = null;
        _textCorrect = null;
        _answered = false;
        _textController.clear();
      });
      return;
    }

    setState(() => _saving = true);

    final now = DateTime.now();
    final attempt = QuizAttempt(
      id: now.microsecondsSinceEpoch.toString(),
      date: now,
      subject: widget.subject,
      topic: widget.topic,
      mode: widget.mode,
      difficulty: widget.difficulty,
      answers: List.of(_answers),
    );

    try {
      await AppStore.instance.saveAttempt(attempt);
      if (!mounted) return;
      setState(() {
        _savedAttempt = attempt;
        _finished = true;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar. Intenta nuevamente.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _option(int index, QuizQuestion q) {
    final correct = index == q.correcta;
    final selected = index == _selected;

    Color background = Colors.white;
    Color border = const Color(0xFFE9E1F5);

    if (_answered) {
      if (correct) {
        background = const Color(0xFFDCF7E8);
        border = const Color(0xFF3DA779);
      } else if (selected) {
        background = const Color(0xFFFFE3EB);
        border = const Color(0xFFE27491);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(19),
            onTap: _answered ? null : () => _answerOption(index, q),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.lavender,
                    child: Text(
                      String.fromCharCode(65 + index),
                      style: const TextStyle(
                        color: AppTheme.primaryDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      q.opciones[index],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (_answered && correct)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF3DA779),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _writtenQuestion(QuizQuestion q) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _textController,
          enabled: !_answered,
          textCapitalization: TextCapitalization.sentences,
          maxLength: 150,
          decoration: InputDecoration(
            labelText: 'Tu respuesta',
            hintText: 'Escribe aquí...',
            prefixIcon: const Icon(Icons.edit_rounded),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          ),
          onSubmitted: (_) => _answerText(q),
        ),
        const SizedBox(height: 12),
        if (!_answered)
          FilledButton.icon(
            onPressed: () => _answerText(q),
            icon: const Icon(Icons.check_rounded),
            label: const Text('Comprobar respuesta'),
          ),
        if (_answered)
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: _textCorrect == true
                  ? const Color(0xFFDCF7E8)
                  : const Color(0xFFFFE3EB),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _textCorrect == true
                      ? '¡Respuesta correcta! 🎉'
                      : '¡Sigue practicando! 💜',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Respuesta esperada: ${q.respuestaTexto}'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _questions(List<QuizQuestion> questions) {
    final q = questions[_current];
    final answeredCorrectly = q.isText
        ? _textCorrect == true
        : _selected == q.correcta;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            Text(
              widget.subject,
              style: const TextStyle(
                color: AppTheme.primaryDark,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.mode == 'simulacro' ? 'Simulacro completo' : widget.topic,
              style: const TextStyle(color: AppTheme.muted),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text(widget.difficulty)),
                Chip(label: Text('${widget.quantity} preguntas')),
                Chip(
                  label: Text(
                    q.isText ? 'Respuesta escrita' : 'Opción múltiple',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Pregunta ${_current + 1} de ${questions.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (_current + 1) / questions.length,
              minHeight: 10,
              borderRadius: BorderRadius.circular(12),
              color: AppTheme.primary,
              backgroundColor: AppTheme.lavender,
            ),
            const SizedBox(height: 25),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(_current),
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  q.pregunta,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.text,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            if (q.isText)
              _writtenQuestion(q)
            else
              ...List.generate(4, (i) => _option(i, q)),
            if (_answered) ...[
              const SizedBox(height: 19),
              if (!q.isText)
                Text(
                  answeredCorrectly
                      ? '¡Respuesta correcta! 🎉'
                      : '¡Sigue practicando! 💜',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.lavender,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  q.explicacion,
                  style: const TextStyle(fontSize: 15, color: AppTheme.text),
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: _saving ? null : () => _next(questions),
                child: Text(
                  _saving
                      ? 'Guardando...'
                      : _current == questions.length - 1
                      ? 'Ver resultados'
                      : 'Siguiente pregunta',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _results(List<QuizQuestion> questions) {
    final percent = (_score / questions.length * 100).round();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(26),
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              size: 85,
              color: Color(0xFFFFC348),
            ),
            const SizedBox(height: 17),
            const Text(
              '¡Reto completado! 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(
              '$_score de ${questions.length} correctas',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19),
            ),
            const SizedBox(height: 8),
            Text(
              '$percent% de aciertos',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.primaryDark,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '¡Tu intento se guardó en el historial!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.muted),
            ),
            const SizedBox(height: 24),
            if (_savedAttempt != null)
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AttemptDetailScreen(attempt: _savedAttempt!),
                  ),
                ),
                icon: const Icon(Icons.visibility_rounded),
                label: const Text('Revisar mis respuestas'),
              ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _newQuiz,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Generar otro reto con IA'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver a la configuración'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode == 'simulacro' ? 'Simulacro' : 'Práctica'),
      ),
      body: FutureBuilder<List<QuizQuestion>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Gemini está preparando tu reto... ✨'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        size: 55,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'No pudimos obtener tus preguntas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('${snapshot.error}', textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _newQuiz,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final questions = snapshot.data ?? [];

          if (questions.isEmpty) {
            return Center(
              child: FilledButton(
                onPressed: _newQuiz,
                child: const Text('Generar preguntas'),
              ),
            );
          }

          return _finished ? _results(questions) : _questions(questions);
        },
      ),
    );
  }
}
