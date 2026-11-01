import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/app_store.dart';

String formatAttemptDate(DateTime date) {
  final d = date.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year} · '
      '${two(d.hour)}:${two(d.minute)}';
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi historial 📚')),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final attempts = store.attempts;

          if (attempts.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history_edu_rounded,
                      size: 75,
                      color: AppTheme.primary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '¡Tu historia comienza aquí!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 9),
                    Text(
                      'Completa una práctica para guardar tus respuestas.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView(
                padding: const EdgeInsets.all(22),
                children: [
                  const Text(
                    'Mis prácticas anteriores 💜',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text('${attempts.length} retos completados'),
                  const SizedBox(height: 20),
                  ...attempts.map(
                    (attempt) => Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              attempt.subject,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              attempt.mode == 'simulacro'
                                  ? 'Simulacro de la posta'
                                  : attempt.topic,
                            ),
                            const SizedBox(height: 9),
                            Text(
                              formatAttemptDate(attempt.date),
                              style: const TextStyle(
                                color: AppTheme.muted,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              children: [
                                Chip(label: Text(attempt.difficulty)),
                                Chip(
                                  label: Text(
                                    '${attempt.correct}/${attempt.total} aciertos',
                                  ),
                                ),
                                Chip(label: Text('${attempt.percentage}%')),
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AttemptDetailScreen(attempt: attempt),
                                  ),
                                ),
                                icon: const Icon(Icons.visibility_rounded),
                                label: const Text('Ver respuestas'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AttemptDetailScreen extends StatelessWidget {
  final QuizAttempt attempt;

  const AttemptDetailScreen({super.key, required this.attempt});

  Widget _multipleChoice(SavedAnswer answer) {
    return Column(
      children: List.generate(answer.options.length, (index) {
        final correct = index == answer.correctIndex;
        final selected = index == answer.selectedIndex;

        Color color = const Color(0xFFF6F3FA);

        if (correct) {
          color = const Color(0xFFDDF6E8);
        } else if (selected) {
          color = const Color(0xFFFFE3EC);
        }

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Text('${String.fromCharCode(65 + index)}. '),
              Expanded(child: Text(answer.options[index])),
              if (selected) const Icon(Icons.person_rounded, size: 17),
              if (correct)
                const Icon(Icons.check_rounded, color: Color(0xFF30966B)),
            ],
          ),
        );
      }),
    );
  }

  Widget _writtenAnswer(SavedAnswer answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: answer.isCorrect
                ? const Color(0xFFDDF6E8)
                : const Color(0xFFFFE3EC),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text('Escribiste: ${answer.writtenAnswer}'),
        ),
        const SizedBox(height: 9),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFDDF6E8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text('Respuesta correcta: ${answer.correctText}'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis respuestas 💜')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              Text(
                attempt.subject,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(formatAttemptDate(attempt.date)),
              const SizedBox(height: 10),
              Text(
                '${attempt.correct} correctas · '
                '${attempt.incorrect} incorrectas',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              ...List.generate(attempt.answers.length, (index) {
                final answer = attempt.answers[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 17),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              answer.isCorrect
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              color: answer.isCorrect
                                  ? const Color(0xFF30966B)
                                  : const Color(0xFFD96E91),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Pregunta ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              answer.isCorrect ? 'Correcta' : 'Incorrecta',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: answer.isCorrect
                                    ? const Color(0xFF30966B)
                                    : const Color(0xFFD96E91),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          answer.question,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (answer.isText)
                          _writtenAnswer(answer)
                        else
                          _multipleChoice(answer),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: AppTheme.lavender,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            'Explicación: ${answer.explanation}',
                            style: const TextStyle(color: AppTheme.text),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
