import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/rally_catalog.dart';
import '../quiz/quiz_config_screen.dart';
import '../voice/voice_challenge_screen.dart';

class TopicScreen extends StatelessWidget {
  final RallyPosta posta;

  const TopicScreen({super.key, required this.posta});

  // Abre la configuración de un cuestionario.
  // Conserva dificultad y cantidad personalizables.
  void _startQuiz(
    BuildContext context, {
    required String topic,
    required String mode,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            QuizConfigScreen(subject: posta.name, topic: topic, mode: mode),
      ),
    );
  }

  // Abre el reto oral, sin modificar los cuestionarios normales.
  void _startVoice(BuildContext context, {required String topic}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VoiceChallengeScreen(
          subject: posta.name,
          topic: topic,
          difficulty: 'Intermedio',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tu aventura 📖')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              // ENCABEZADO DE LA POSTA
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB394F2), Color(0xFF8962DB)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    Icon(posta.icon, size: 52, color: Colors.white),
                    const SizedBox(height: 14),
                    Text(
                      posta.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Text(
                      '¡Cada pregunta es una oportunidad para aprender!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFFF4EEFF)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // SIMULACRO COMPLETO
              Text(
                'Desafío completo 🏆',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),

              Material(
                color: AppTheme.mint,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => _startQuiz(
                    context,
                    topic: posta.topics.join('; '),
                    mode: 'simulacro',
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(22),
                    child: Row(
                      children: [
                        Icon(
                          Icons.emoji_events_rounded,
                          size: 42,
                          color: Color(0xFF319573),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Iniciar simulacro',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.text,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Preguntas mezcladas de todos los temas de la posta',
                                style: TextStyle(color: AppTheme.muted),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.play_circle_fill_rounded,
                          size: 32,
                          color: Color(0xFF319573),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // RETO ORAL CON IA
              Text(
                'Entrena hablando 🎙️',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Practica explicando tus conocimientos con tus propias palabras.',
                style: TextStyle(color: AppTheme.muted, fontSize: 14),
              ),
              const SizedBox(height: 14),

              Material(
                color: AppTheme.lavender,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () =>
                      _startVoice(context, topic: posta.topics.join('; ')),
                  child: const Padding(
                    padding: EdgeInsets.all(22),
                    child: Row(
                      children: [
                        Icon(
                          Icons.record_voice_over_rounded,
                          color: AppTheme.primaryDark,
                          size: 40,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reto oral con IA',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.text,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Tienes 15 segundos para responder por voz. '
                                'Gemini evaluará tu explicación.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.mic_rounded,
                          size: 28,
                          color: AppTheme.primaryDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // PRÁCTICAS INDIVIDUALES
              Text(
                'Aprende a tu ritmo 💜',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecciona un tema para generar preguntas '
                'con la dificultad y cantidad que prefieras.',
                style: TextStyle(color: AppTheme.muted, fontSize: 14),
              ),
              const SizedBox(height: 17),

              ...List.generate(posta.topics.length, (index) {
                final topic = posta.topics[index];

                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 350 + index * 50),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 15 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () =>
                            _startQuiz(context, topic: topic, mode: 'practica'),
                        child: Padding(
                          padding: const EdgeInsets.all(17),
                          child: Row(
                            children: [
                              Container(
                                width: 43,
                                height: 43,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppTheme.lavender,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: AppTheme.primaryDark,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  topic,
                                  style: const TextStyle(
                                    color: AppTheme.text,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: AppTheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
