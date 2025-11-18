import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/language_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/l10n/app_localizations.dart';
import 'core/config/supabase_config.dart';
import 'core/di/injection.dart';
import 'core/cache/cache_service.dart';
import 'features/auth/presentation/widgets/auth_wrapper.dart';
import 'features/auth/l10n/auth_localizations.dart';
import 'features/dislikes/l10n/dislikes_localizations.dart';
import 'features/protein_preferences/l10n/protein_preferences_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive cache
  await CacheService.init();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Initialize dependency injection
  await setupDependencies();

  // Initialize language provider
  final languageProvider = LanguageProvider();
  await languageProvider.initLanguage();

  runApp(MyApp(languageProvider: languageProvider));
}

class MyApp extends StatelessWidget {
  final LanguageProvider languageProvider;

  const MyApp({super.key, required this.languageProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: languageProvider),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'Kinrai D',
            theme: AppTheme.lightTheme,
            themeMode: ThemeMode.light,
            home: const AuthWrapper(),
            debugShowCheckedModeBanner: false,

            // Localization setup
            locale: languageProvider.currentLocale,
            supportedLocales: languageProvider.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              AuthLocalizations.delegate,
              DislikesLocalizations.delegate,
              ProteinPreferencesLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}

