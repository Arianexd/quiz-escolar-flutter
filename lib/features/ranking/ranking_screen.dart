import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final players = [
      ('Estudiante 1', 2450),
      ('Estudiante 2', 2100),
      ('Estudiante 3', 1850),
      ('Tú', 350),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Ranking 🏆')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFFFFD76A),
                  size: 65,
                ),
                SizedBox(height: 12),
                Text(
                  '¡Los mejores estudiantes!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '¡Sigue jugando para subir de posición!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            'Clasificación general',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          ...List.generate(players.length, (index) {
            final player = players[index];
            final isMe = player.$1 == 'Tú';

            return Card(
              elevation: 0,
              color: isMe ? const Color(0xFFECE5FF) : Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFE7DFFF),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  player.$1,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Estudiante'),
                trailing: Text(
                  '${player.$2} XP',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
