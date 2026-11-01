import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/rally_catalog.dart';
import '../subjects/subjects_screen.dart';
import '../topics/topic_screen.dart';
import '../ranking/ranking_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final materias = [
      _HomeSubject(
        'Literatura',
        'Historias y palabras',
        Icons.auto_stories_rounded,
        const Color(0xFFECE0FF),
        const Color(0xFF8257CD),
        rallyPostas[1],
      ),
      _HomeSubject(
        'Matemáticas',
        'Retos para tu mente',
        Icons.functions_rounded,
        const Color(0xFFDFF7EA),
        const Color(0xFF258C70),
        rallyPostas[5],
      ),
      _HomeSubject(
        'Historia',
        'Explora el pasado',
        Icons.public_rounded,
        const Color(0xFFFFEBD8),
        const Color(0xFFD48A43),
        rallyPostas[3],
      ),
      _HomeSubject(
        'Biología',
        'Descubre la vida',
        Icons.biotech_rounded,
        const Color(0xFFFFE3EC),
        const Color(0xFFDC688B),
        rallyPostas[2],
      ),
    ];

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            _open(context, const RankingScreen());
          }
          if (index == 2) {
            _open(context, const ProfileScreen());
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            label: 'Ranking',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Perfil',
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 25),
              children: [
                _AnimatedEntrance(
                  delay: 0,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¡Hola, estudiante! 👋',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Hoy es un buen día para aprender ✨',
                              style: TextStyle(
                                color: AppTheme.muted,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () => _open(context, const ProfileScreen()),
                        child: Container(
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: AppTheme.lavender,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.face_rounded,
                            color: AppTheme.primaryDark,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _AnimatedEntrance(
                  delay: 120,
                  child: Container(
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFAF8DF4), Color(0xFF8059D7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.20),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        const Positioned(
                          right: 0,
                          top: 0,
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            size: 56,
                            color: Color(0x70FFFFFF),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TU AVENTURA COMIENZA AQUÍ',
                              style: TextStyle(
                                color: Color(0xFFEFE6FF),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              '¡Convierte tus conocimientos en superpoderes!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Explora las postas, supera retos y prepárate para el rally.',
                              style: TextStyle(
                                color: Color(0xFFF3EFFF),
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: () =>
                                  _open(context, const SubjectsScreen()),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.lime,
                                foregroundColor: AppTheme.text,
                              ),
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Text('¡Empezar a jugar!'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _AnimatedEntrance(
                  delay: 240,
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tu progreso 🌟',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const Text(
                              'Nivel 1',
                              style: TextStyle(
                                color: AppTheme.primaryDark,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 0.35),
                          duration: const Duration(milliseconds: 1100),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) {
                            return LinearProgressIndicator(
                              value: value,
                              minHeight: 12,
                              borderRadius: BorderRadius.circular(12),
                              color: AppTheme.primary,
                              backgroundColor: AppTheme.lavender,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '350 / 1000 XP · ¡Sigue aprendiendo!',
                          style: TextStyle(color: AppTheme.muted),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _AnimatedEntrance(
                  delay: 340,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Explora las materias 📚',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _open(context, const SubjectsScreen()),
                        child: const Text('Ver todas'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: materias.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 245,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            mainAxisExtent: 175,
                          ),
                      itemBuilder: (context, index) {
                        final materia = materias[index];

                        return _AnimatedEntrance(
                          delay: 400 + index * 90,
                          child: Material(
                            color: materia.background,
                            borderRadius: BorderRadius.circular(25),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(25),
                              onTap: () => _open(
                                context,
                                TopicScreen(posta: materia.posta),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(19),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      materia.icon,
                                      color: materia.foreground,
                                      size: 36,
                                    ),
                                    const Spacer(),
                                    Text(
                                      materia.name,
                                      style: TextStyle(
                                        color: materia.foreground,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      materia.subtitle,
                                      style: TextStyle(
                                        color: materia.foreground.withValues(
                                          alpha: 0.80,
                                        ),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 25),
                _AnimatedEntrance(
                  delay: 750,
                  child: OutlinedButton.icon(
                    onPressed: () => _open(context, const SubjectsScreen()),
                    icon: const Icon(Icons.grid_view_rounded),
                    label: const Text('Explorar las 6 postas del rally'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeSubject {
  final String name;
  final String subtitle;
  final IconData icon;
  final Color background;
  final Color foreground;
  final RallyPosta posta;

  const _HomeSubject(
    this.name,
    this.subtitle,
    this.icon,
    this.background,
    this.foreground,
    this.posta,
  );
}

class _AnimatedEntrance extends StatelessWidget {
  final Widget child;
  final int delay;

  const _AnimatedEntrance({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 550 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 22 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
