import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'quiz_screen.dart';

class QuizConfigScreen extends StatefulWidget {
  final String subject;
  final String topic;
  final String mode;

  const QuizConfigScreen({
    super.key,
    required this.subject,
    required this.topic,
    required this.mode,
  });

  @override
  State<QuizConfigScreen> createState() => _QuizConfigScreenState();
}

class _QuizConfigScreenState extends State<QuizConfigScreen> {
  String difficulty = 'Intermedio';
  int quantity = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configura tu reto ✨')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 15),
              const Icon(Icons.tune_rounded, size: 62, color: AppTheme.primary),
              const SizedBox(height: 15),
              Text(
                '¡Un reto a tu medida! 💜',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                widget.mode == 'simulacro'
                    ? 'Simulacro: ${widget.subject}'
                    : 'Práctica: ${widget.topic}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.muted, fontSize: 15),
              ),
              const SizedBox(height: 35),
              const Text(
                'Selecciona la dificultad',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.text,
                ),
              ),
              const SizedBox(height: 15),
              ...[
                ('Fácil', '🌱', 'Conceptos básicos'),
                ('Intermedio', '⭐', 'Comprensión y aplicación'),
                ('Difícil', '🔥', 'Análisis y razonamiento'),
              ].map((option) {
                final selected = difficulty == option.$1;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.lavender : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: selected ? AppTheme.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () {
                        setState(() {
                          difficulty = option.$1;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Text(
                              option.$2,
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.$1,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    option.$3,
                                    style: const TextStyle(
                                      color: AppTheme.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              selected
                                  ? Icons.check_circle_rounded
                                  : Icons.circle_outlined,
                              color: AppTheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 26),
              const Text(
                '¿Cuántas preguntas quieres?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.text,
                ),
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [5, 10, 15, 20].map((number) {
                  return ChoiceChip(
                    label: Text('$number preguntas'),
                    selected: quantity == number,
                    selectedColor: AppTheme.lavender,
                    onSelected: (_) {
                      setState(() {
                        quantity = number;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 35),
              FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizScreen(
                        subject: widget.subject,
                        topic: widget.topic,
                        mode: widget.mode,
                        difficulty: difficulty,
                        quantity: quantity,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('¡Generar preguntas con IA!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
