import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Hive inicialización ─────────────────────────────────────────────

  // ─────────────────────────────────────────────────────────────────────

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'IAymara',
    debugShowCheckedModeBanner: false, // ← oculta la etiqueta DEBUG
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
    home: const HomeScreen(),
  );
}
