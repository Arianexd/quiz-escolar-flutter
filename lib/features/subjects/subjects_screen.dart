import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/rally_catalog.dart';
import '../topics/topic_screen.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Postas del Rally ✨')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 950),
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              Text(
                '¡Elige tu aventura!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Seis postas, muchos conocimientos por descubrir.',
                style: TextStyle(fontSize: 15, color: AppTheme.muted),
              ),
              const SizedBox(height: 26),
              ...List.generate(rallyPostas.length, (index) {
                final posta = rallyPostas[index];

                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 450 + index * 110),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Material(
                      color: posta.color,
                      borderRadius: BorderRadius.circular(26),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(26),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TopicScreen(posta: posta),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.70),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  posta.icon,
                                  color: AppTheme.primaryDark,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 17),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'POSTA ${index + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.primaryDark,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      posta.name,
                                      style: const TextStyle(
                                        color: AppTheme.text,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '${posta.topics.length} temas para explorar',
                                      style: const TextStyle(
                                        color: AppTheme.muted,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 17,
                                color: AppTheme.primaryDark,
                              ),
                            ],
                          ),
                        ),
                      ),
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
