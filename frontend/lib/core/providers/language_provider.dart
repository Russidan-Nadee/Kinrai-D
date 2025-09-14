import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  Locale _currentLocale = const Locale('th'); // Default to Thai

  Locale get currentLocale => _currentLocale;

  String get currentLanguageCode => _currentLocale.languageCode;

  String get currentLanguageName {
    switch (_currentLocale.languageCode) {
      case 'th':
        return 'ไทย';
      case 'en':
        return 'English';
      case 'ja':
        return '日本語';
      case 'zh':
        return '中文';
      default:
        return 'ไทย';
    }
  }

  /// Initialize language from saved preference
  Future<void> initLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey) ?? 'th';
    _currentLocale = Locale(savedLanguage);
    notifyListeners();
  }

  /// Change language and save to preferences
  Future<void> changeLanguage(String languageCode) async {
    if (languageCode == _currentLocale.languageCode) return;

    _currentLocale = Locale(languageCode);

    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);

    notifyListeners();
  }

  /// Get supported locales
  List<Locale> get supportedLocales => const [
    Locale('th'),
    Locale('en'),
    Locale('ja'),
    Locale('zh'),
  ];

  /// Check if locale is supported
  bool isSupported(Locale locale) {
    return supportedLocales.any((supportedLocale) =>
        supportedLocale.languageCode == locale.languageCode);
  }
}