import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'data/app_store.dart';
import 'features/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppStore.instance.initialize();

  runApp(const CuestApp());
}

class CuestApp extends StatelessWidget {
  const CuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CuestApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
