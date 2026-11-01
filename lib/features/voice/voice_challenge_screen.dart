import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../core/theme/app_theme.dart';

class VoiceChallengeScreen extends StatefulWidget {
  final String subject;
  final String topic;
  final String difficulty;

  const VoiceChallengeScreen({
    super.key,
    required this.subject,
    required this.topic,
    this.difficulty = 'Intermedio',
  });

  @override
  State<VoiceChallengeScreen> createState() => _VoiceChallengeScreenState();
}

class _VoiceChallengeScreenState extends State<VoiceChallengeScreen> {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const int totalSeconds = 15;

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  final TextEditingController _answer = TextEditingController();

  Timer? _timer;

  late String _difficulty;

  String _question = '';
  String _reference = '';
  String _status = '';
  String _result = '';
  String _explanation = '';
  String _expected = '';

  int _seconds = totalSeconds;
  int _requestId = 0;

  bool _loading = false;
  bool _starting = false;
  bool _listening = false;
  bool _answering = false;
  bool _evaluating = false;
  bool _completed = false;
  bool _micReady = false;
  bool _speechInitialized = false;
  bool _submitted = false;

  String get _storageKey => 'oral_questions_${widget.subject}_${widget.topic}';

  @override
  void initState() {
    super.initState();
    _difficulty = widget.difficulty;
    _configureTts();
  }

  Future<void> _configureTts() async {
    try {
      await _tts.setLanguage('es-ES');
      await _tts.setSpeechRate(0.48);
    } catch (error) {
      debugPrint('TTS: $error');
    }
  }

  @override
  void dispose() {
    _requestId++;
    _timer?.cancel();
    _speech.cancel();
    _tts.stop();
    _answer.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 90));

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode != 200) {
      final detail = decoded is Map ? decoded['detail'] : null;
      throw Exception(
        'HTTP ${response.statusCode}: ${detail ?? "Error del servidor"}',
      );
    }

    return Map<String, dynamic>.from(decoded as Map);
  }

  Future<void> _generateQuestion() async {
    if (_loading || _evaluating || _starting) return;

    final request = ++_requestId;

    _timer?.cancel();

    try {
      if (_speech.isListening) {
        await _speech.cancel();
      }
      await _tts.stop();
    } catch (error) {
      debugPrint('No se pudo detener audio: $error');
    }

    if (!mounted || request != _requestId) return;

    setState(() {
      _loading = true;
      _question = '';
      _reference = '';
      _status = 'Generando una pregunta nueva...';
      _result = '';
      _explanation = '';
      _expected = '';
      _seconds = totalSeconds;
      _listening = false;
      _answering = false;
      _evaluating = false;
      _completed = false;
      _submitted = false;
      _answer.clear();
    });

    try {
      final saved = await _prefs.getString(_storageKey);

      final previous = saved == null
          ? <String>[]
          : List<String>.from(jsonDecode(saved) as List);

      final data = await _post('/api/voz/pregunta', {
        'posta': widget.subject,
        'tema': widget.topic,
        'dificultad': _difficulty,
        'anteriores': previous.take(40).toList(),
      });

      if (!mounted || request != _requestId) return;

      final question = (data['pregunta'] ?? '').toString().trim();
      final reference = (data['respuesta_referencia'] ?? '').toString().trim();

      if (question.isEmpty || reference.isEmpty) {
        throw const FormatException('Gemini devolvió una pregunta vacía');
      }

      // Guardamos la nueva pregunta para evitar repetirla.
      final updated = [
        question,
        ...previous.where((item) => item != question),
      ].take(40).toList();

      try {
        await _prefs.setString(_storageKey, jsonEncode(updated));
      } catch (error) {
        debugPrint('No se pudo guardar historial oral: $error');
      }

      if (!mounted || request != _requestId) return;

      setState(() {
        _question = question;
        _reference = reference;
        _loading = false;
        _status = 'Pulsa el micrófono y responde en 15 segundos.';
      });
    } catch (error) {
      if (!mounted || request != _requestId) return;

      setState(() {
        _loading = false;
        _status = 'No se pudo generar la pregunta: $error';
      });
    }
  }

  Future<void> _speakQuestion() async {
    if (_question.isEmpty || _answering || _starting) return;

    try {
      await _tts.stop();
      await _tts.speak(_question);
    } catch (error) {
      if (mounted) {
        setState(() => _status = 'No se pudo leer la pregunta: $error');
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _seconds = totalSeconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_answering) {
        timer.cancel();
        return;
      }

      if (_seconds <= 1) {
        timer.cancel();
        setState(() => _seconds = 0);
        _finishAnswer();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  void _onSpeechResult(dynamic result) {
    if (!mounted || !_answering) return;

    setState(() {
      _answer.value = TextEditingValue(
        text: result.recognizedWords as String,
        selection: TextSelection.collapsed(
          offset: (result.recognizedWords as String).length,
        ),
      );

      _status = 'Transcribiendo tu respuesta...';
    });
  }

  // Este método se llama directamente desde el botón.
  // El navegador es quien gestiona el permiso real.
  Future<void> _startMicrophone() async {
    if (_question.isEmpty ||
        _loading ||
        _starting ||
        _answering ||
        _evaluating ||
        _completed) {
      return;
    }

    setState(() {
      _starting = true;
      _status = 'Solicitando acceso al micrófono...';
    });

    bool available = _speechInitialized;

    if (!available) {
      try {
        available = await _speech.initialize(
          onStatus: (status) {
            if (!mounted) return;

            if (status == 'done' || status == 'notListening') {
              setState(() {
                _listening = false;
                if (_answering) {
                  _status =
                      'El micrófono dejó de escuchar. '
                      'Puedes corregir el texto y enviarlo.';
                }
              });
            }
          },
          onError: (error) {
            if (!mounted) return;

            setState(() {
              _listening = false;
              _micReady = false;
              _status =
                  'Error de micrófono: ${error.errorMsg}. '
                  'Comprueba los permisos de Chrome.';
            });
          },
        );
      } catch (error) {
        debugPrint('Error initialize speech: $error');
      }

      _speechInitialized = available;
    }

    if (!mounted) return;

    if (!available) {
      setState(() {
        _starting = false;
        _micReady = false;
        _status =
            'No hay reconocimiento de voz disponible. '
            'Comprueba el permiso del micrófono en Chrome '
            'o responde escribiendo.';
      });
      return;
    }

    try {
      final locales = await _speech.locales();
      String? spanish;

      for (final locale in locales) {
        if (locale.localeId.toLowerCase().replaceAll('-', '_') == 'es_bo') {
          spanish = locale.localeId;
          break;
        }
      }

      spanish ??= locales
          .where((locale) => locale.localeId.toLowerCase().startsWith('es'))
          .map((locale) => locale.localeId)
          .firstOrNull;

      if (!mounted) return;

      // No comenzamos el contador hasta que listen
      // haya podido iniciarse.
      await _speech.listen(
        onResult: _onSpeechResult,
        listenOptions: stt.SpeechListenOptions(
          localeId: spanish,
          partialResults: true,
          listenFor: const Duration(seconds: 15),
          pauseFor: const Duration(seconds: 10),
          cancelOnError: false,
        ),
      );

      if (!mounted) return;

      if (!_speech.isListening) {
        setState(() {
          _starting = false;
          _micReady = false;
          _status =
              'El micrófono no comenzó a escuchar. '
              'Revisa el permiso o el dispositivo seleccionado.';
        });
        return;
      }

      setState(() {
        _starting = false;
        _micReady = true;
        _listening = true;
        _answering = true;
        _status = '¡Te escucho! Habla ahora.';
      });

      _startTimer();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _starting = false;
        _listening = false;
        _micReady = false;
        _status = 'No se pudo activar el micrófono: $error';
      });
    }
  }

  Future<void> _finishAnswer() async {
    if (!_answering || _submitted) return;

    _timer?.cancel();

    setState(() {
      _answering = false;
      _listening = false;
      _status = 'Preparando tu respuesta...';
    });

    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
    } catch (error) {
      debugPrint('Error stop speech: $error');
    }

    if (!mounted) return;
    await _submitAnswer();
  }

  Future<void> _submitAnswer() async {
    if (_submitted || _evaluating || _completed) return;

    final written = _answer.text.trim();

    if (written.isEmpty) {
      setState(() {
        _status =
            'No se detectó ninguna palabra. '
            'Puedes escribir tu respuesta y pulsar Evaluar.';
      });
      return;
    }

    _timer?.cancel();

    if (_speech.isListening) {
      try {
        await _speech.stop();
      } catch (_) {}
    }

    if (!mounted) return;

    setState(() {
      _answering = false;
      _submitted = true;
      _evaluating = true;
      _status = 'Gemini está evaluando tu respuesta...';
    });

    try {
      final data = await _post('/api/voz/evaluar', {
        'pregunta': _question,
        'respuesta_referencia': _reference,
        'respuesta_estudiante': written,
      });

      if (!mounted) return;

      setState(() {
        _result = (data['resultado'] ?? '').toString();
        _explanation = (data['explicacion'] ?? '').toString();
        _expected = (data['respuesta_esperada'] ?? _reference).toString();
        _evaluating = false;
        _completed = true;
        _status = '';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _submitted = false;
        _evaluating = false;
        _status = 'No se pudo evaluar: $error';
      });
    }
  }

  Widget _feedback() {
    final correct = _result == 'correcta';
    final partial = _result == 'parcial';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: correct
            ? const Color(0xFFDDF6E8)
            : partial
            ? const Color(0xFFFFF0CF)
            : const Color(0xFFFFE3EC),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            correct
                ? '¡Correcto! 🌟'
                : partial
                ? '¡Casi! ⭐'
                : 'Respuesta incorrecta 💜',
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: 10),
          Text(_explanation),
          const SizedBox(height: 14),
          Text(
            'Respuesta correcta: $_expected',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _difficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '¿Qué dificultad quieres? ✨',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w900,
            color: AppTheme.text,
          ),
        ),
        const SizedBox(height: 14),
        ...['Fácil', 'Intermedio', 'Difícil'].map((level) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: RadioListTile<String>(
              value: level,
              groupValue: _difficulty,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _difficulty = value);
                }
              },
              title: Text(
                level,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              activeColor: AppTheme.primaryDark,
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          );
        }),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: _generateQuestion,
          icon: const Icon(Icons.auto_awesome_rounded),
          label: const Text('Generar pregunta oral'),
        ),
      ],
    );
  }

  Widget _countdown() {
    return Center(
      child: SizedBox(
        width: 135,
        height: 135,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: _seconds / totalSeconds,
                strokeWidth: 9,
                color: _seconds <= 5
                    ? const Color(0xFFE17494)
                    : AppTheme.primary,
                backgroundColor: AppTheme.lavender,
              ),
            ),
            Text(
              '$_seconds s',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppTheme.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reto oral con IA 🎙️')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.all(23),
            children: [
              Text(
                widget.subject,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.topic,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppTheme.muted),
              ),
              const SizedBox(height: 22),

              if (!_loading && _question.isEmpty) _difficultySelector(),

              if (_loading) ...[
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 12),
                const Text(
                  'Gemini está creando una pregunta nueva...',
                  textAlign: TextAlign.center,
                ),
              ],

              if (_question.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: [
                      Chip(label: Text('Dificultad: $_difficulty')),
                      const SizedBox(height: 13),
                      Text(
                        _question,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.text,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _answering ? null : _speakQuestion,
                        icon: const Icon(Icons.volume_up_rounded),
                        label: const Text('Escuchar pregunta'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 23),
                _countdown(),
                const SizedBox(height: 18),

                if (!_answering && !_evaluating && !_completed)
                  FilledButton.icon(
                    onPressed: _starting ? null : _startMicrophone,
                    icon: const Icon(Icons.mic_rounded),
                    label: Text(
                      _starting
                          ? 'Solicitando micrófono...'
                          : 'Activar micrófono y responder',
                    ),
                  ),

                if (_answering)
                  FilledButton.icon(
                    onPressed: _finishAnswer,
                    icon: const Icon(Icons.stop_circle_rounded),
                    label: const Text('Terminar y evaluar'),
                  ),

                const SizedBox(height: 14),

                if (_listening)
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fiber_manual_record,
                        color: Colors.red,
                        size: 17,
                      ),
                      SizedBox(width: 7),
                      Text('Escuchando...'),
                    ],
                  ),

                const SizedBox(height: 12),

                TextField(
                  controller: _answer,
                  enabled: !_completed && !_evaluating,
                  maxLines: 2,
                  maxLength: 300,
                  decoration: InputDecoration(
                    labelText: 'Lo que dijiste',
                    hintText: 'Aquí aparecerá tu voz como texto...',
                    helperText: 'Puedes corregir la transcripción.',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                ),

                if (!_answering && !_evaluating && !_completed && !_loading)
                  OutlinedButton.icon(
                    onPressed: _submitAnswer,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Evaluar respuesta escrita'),
                  ),

                if (_evaluating) ...[
                  const SizedBox(height: 18),
                  const Center(child: CircularProgressIndicator()),
                ],

                if (_completed) ...[
                  const SizedBox(height: 15),
                  _feedback(),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () {
                      setState(() {
                        _question = '';
                        _reference = '';
                        _status = '';
                        _seconds = totalSeconds;
                      });
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Elegir dificultad y otra pregunta'),
                  ),
                ],
              ],

              if (_status.isNotEmpty && !_loading) ...[
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppTheme.lavender,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.text),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
