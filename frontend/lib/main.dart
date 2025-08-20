import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kinrai D',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const App(),
      debugShowCheckedModeBanner: false,
    );
  }
}

