import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/language_provider.dart';
import 'core/l10n/app_localizations.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    return ChangeNotifierProvider.value(
      value: languageProvider,
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'Kinrai D',
            theme: AppTheme.lightTheme,
            themeMode: ThemeMode.light,
            home: const App(),
            debugShowCheckedModeBanner: false,

            // Localization setup
            locale: languageProvider.currentLocale,
            supportedLocales: languageProvider.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
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

