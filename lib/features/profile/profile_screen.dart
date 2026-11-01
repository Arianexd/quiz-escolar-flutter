import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_store.dart';
import '../history/history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AppStore store = AppStore.instance;
  bool _savingPhoto = false;

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: store.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar mi nombre 💜'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 40,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Tu nombre',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    // Dejamos que el diálogo termine antes de liberar el controlador.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.dispose();
    });

    if (newName == null) return;

    try {
      await store.updateName(newName);
      _showMessage('¡Nombre actualizado!');
    } catch (error) {
      _showMessage('Escribe un nombre válido (1 a 40 caracteres).');
    }
  }

  Future<void> _pickPhoto() async {
    if (_savingPhoto) return;

    setState(() => _savingPhoto = true);

    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 360,
        maxHeight: 360,
        imageQuality: 55,
      );

      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      await store.updatePhoto(bytes);
      _showMessage('¡Foto de perfil actualizada!');
    } catch (error) {
      _showMessage(
        'No se pudo guardar la foto. Prueba con una imagen más pequeña.',
      );
    } finally {
      if (mounted) {
        setState(() => _savingPhoto = false);
      }
    }
  }

  Widget _avatar() {
    final photo = store.photoBase64;

    if (photo == null) {
      return const CircleAvatar(
        radius: 55,
        backgroundColor: AppTheme.lavender,
        child: Icon(Icons.face_rounded, color: AppTheme.primaryDark, size: 65),
      );
    }

    try {
      return CircleAvatar(
        radius: 55,
        backgroundColor: AppTheme.lavender,
        backgroundImage: MemoryImage(base64Decode(photo)),
      );
    } catch (_) {
      return const CircleAvatar(
        radius: 55,
        child: Icon(Icons.person, size: 60),
      );
    }
  }

  Widget _stat(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryDark, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: AppTheme.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppTheme.muted),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil 💜')),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: ListView(
                padding: const EdgeInsets.all(22),
                children: [
                  const SizedBox(height: 12),
                  Center(child: _avatar()),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton.icon(
                      onPressed: _savingPhoto ? null : _pickPhoto,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text(
                        _savingPhoto ? 'Guardando...' : 'Cambiar foto',
                      ),
                    ),
                  ),
                  if (store.photoBase64 != null)
                    Center(
                      child: TextButton(
                        onPressed: () async {
                          await store.removePhoto();
                        },
                        child: const Text('Quitar foto'),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    store.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: _editName,
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Editar nombre'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Mis estadísticas ✨',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _stat(
                        '${store.completedQuizzes}',
                        'Retos',
                        Icons.sports_esports_rounded,
                      ),
                      const SizedBox(width: 10),
                      _stat(
                        '${store.totalCorrect}',
                        'Aciertos',
                        Icons.check_circle_rounded,
                      ),
                      const SizedBox(width: 10),
                      _stat(
                        '${store.accuracy}%',
                        'Precisión',
                        Icons.track_changes_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Material(
                    color: AppTheme.lavender,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HistoryScreen(),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(22),
                        child: Row(
                          children: [
                            Icon(
                              Icons.history_edu_rounded,
                              color: AppTheme.primaryDark,
                              size: 37,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mi historial',
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.text,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Revisa tus prácticas y respuestas anteriores',
                                    style: TextStyle(color: AppTheme.muted),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.primaryDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'Mis logros 🏅',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: Icon(
                        store.completedQuizzes > 0
                            ? Icons.emoji_events_rounded
                            : Icons.lock_outline_rounded,
                        color: AppTheme.primaryDark,
                      ),
                      title: const Text('Primer reto'),
                      subtitle: Text(
                        store.completedQuizzes > 0
                            ? '¡Completaste tu primera práctica!'
                            : 'Completa una práctica para desbloquearlo',
                      ),
                      trailing: Icon(
                        store.completedQuizzes > 0
                            ? Icons.check_circle_rounded
                            : Icons.lock_outline,
                        color: store.completedQuizzes > 0
                            ? Colors.green
                            : AppTheme.muted,
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
