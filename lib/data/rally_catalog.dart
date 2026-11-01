import 'package:flutter/material.dart';

class RallyPosta {
  final String name;
  final IconData icon;
  final Color color;
  final List<String> topics;

  const RallyPosta({
    required this.name,
    required this.icon,
    required this.color,
    required this.topics,
  });
}

const rallyPostas = <RallyPosta>[
  RallyPosta(
    name: 'Valores, Psicología y Filosofía',
    icon: Icons.psychology_rounded,
    color: Color(0xFFEBDDFF),
    topics: [
      'Valores y su relación con la Biblia',
      'Desafíos de razonamiento mental',
      'Neuronas y neurotransmisores',
      'Teorías del desarrollo humano',
      'Teoría psicoanalítica de Sigmund Freud',
      'Etapas del desarrollo psicosexual',
      'Teoría psicosocial de Erik Erikson',
      'Falacias, proposiciones y tablas de verdad',
      'Argumentación, ciencia y filosofía boliviana',
      'Identidad, conocimiento, libertad, lenguaje y ética',
    ],
  ),
  RallyPosta(
    name: 'Comunicación y Lenguaje',
    icon: Icons.menu_book_rounded,
    color: Color(0xFFFFE3EE),
    topics: [
      'Comprensión lectora y análisis de textos breves',
      'Ortografía y vocabulario',
      'Construcción de oraciones',
      'Adivinanzas, trabalenguas y expresión oral',
      'Tipología textual',
      'Figuras literarias',
      'El discurso y sus características',
      'El vanguardismo literario',
    ],
  ),
  RallyPosta(
    name: 'Ciencias Naturales y Biología',
    icon: Icons.biotech_rounded,
    color: Color(0xFFDDF7EA),
    topics: [
      'Receptores sensoriales y su funcionamiento',
      'Anatomía del cuerpo humano',
      'Fisiología del cuerpo humano',
      'Principios fundamentales de citología',
      'Sensopercepción',
    ],
  ),
  RallyPosta(
    name: 'Ciencias Sociales, Historia, Geografía y Cívica',
    icon: Icons.public_rounded,
    color: Color(0xFFFFE9D5),
    topics: [
      'Evolución de la especie humana',
      'Invasión europea de Abya Yala',
      'Primera y segunda Revolución Industrial',
      'Revolución Francesa',
      'Movimientos indígenas',
      'Revoluciones libertarias',
      'Independencia de Bolivia',
      'Geografía general de Bolivia',
      'Actividades económicas',
      'Geopolítica',
      'Organismos internacionales',
      'Ciudadanía y derechos humanos',
      'Democracia y participación ciudadana',
      'Estado Plurinacional de Bolivia',
      'Primera Guerra Mundial',
      'Guerra del Chaco',
      'Segunda Guerra Mundial',
      'Revolución Nacional de 1952',
    ],
  ),
  RallyPosta(
    name: 'Química y Física',
    icon: Icons.science_rounded,
    color: Color(0xFFDFF1FF),
    topics: [
      'Concentración y control del pulso',
      'Reacciones químicas',
      'Cinemática',
      'Mediciones',
    ],
  ),
  RallyPosta(
    name: 'Razonamiento Lógico y Matemático',
    icon: Icons.calculate_rounded,
    color: Color(0xFFFFF2C9),
    topics: [
      'Liderazgo y resolución de conflictos',
      'Problemas y operaciones matemáticas',
      'Relaciones recurrentes y ecuaciones en diferencias',
      'Progresiones y sucesiones geométricas',
      'Pensamiento algorítmico y recursividad',
      'Inducción matemática',
      'Teoría de grafos',
      'Geometría fractal',
    ],
  ),
];
