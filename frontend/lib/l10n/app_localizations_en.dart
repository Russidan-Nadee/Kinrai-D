// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Kinrai D';

  @override
  String get welcome => 'Welcome to Kinrai D!';

  @override
  String get tapToRandomMenu => 'Tap to random delicious menu';

  @override
  String get randomMenu => 'Random Menu';

  @override
  String get recommendedMenu => 'Recommended Menu';

  @override
  String get cannotRandomMenu => 'Cannot random menu. Please try again.';

  @override
  String get noRating => 'No rating yet';

  @override
  String get user => 'User';

  @override
  String get manageSettings => 'Manage your settings';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String languageChanged(String language) {
    return 'Language changed to $language';
  }

  @override
  String get otherFeaturesDeveloping => 'Other features are being developed';

  @override
  String get comingSoon => 'Coming soon!';

  @override
  String get main => 'Main';

  @override
  String get profile => 'Profile';

  @override
  String get admin => 'Admin';
}
