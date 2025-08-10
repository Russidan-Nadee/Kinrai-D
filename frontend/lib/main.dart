import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection_container.dart';
import 'features/authentication/presentation/providers/auth_provider.dart';
import 'features/admin/presentation/providers/admin_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  final di = InjectionContainer();
  await di.init();
  
  runApp(MyApp(di: di));
}

class MyApp extends StatelessWidget {
  final InjectionContainer di;
  
  const MyApp({super.key, required this.di});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(
          value: di.authProvider,
        ),
        ChangeNotifierProvider<AdminProvider>.value(
          value: di.adminProvider,
        ),
      ],
      child: MaterialApp(
        title: 'Kinrai D',
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light, // Force light theme
        home: const App(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

