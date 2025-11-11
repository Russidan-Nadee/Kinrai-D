// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'Kinrai D';

  @override
  String get welcome => 'Kinrai Dへようこそ！';

  @override
  String get tapToRandomMenu => 'ボタンを押して美味しいメニューをランダムに選択';

  @override
  String get randomMenu => 'ランダムメニュー';

  @override
  String get recommendedMenu => 'おすすめメニュー';

  @override
  String get cannotRandomMenu => 'メニューをランダムに選択できません。もう一度お試しください。';

  @override
  String get noRating => '評価なし';

  @override
  String get user => 'ユーザー';

  @override
  String get manageSettings => '設定を管理する';

  @override
  String get selectLanguage => '言語を選択';

  @override
  String languageChanged(String language) {
    return '言語を$languageに変更しました';
  }

  @override
  String get otherFeaturesDeveloping => 'その他の機能を開発中';

  @override
  String get comingSoon => '近日公開！';

  @override
  String get main => 'メイン';

  @override
  String get profile => 'プロフィール';

  @override
  String get admin => '管理者';

  @override
  String get proteinPreferences => '食べたくないタンパク質';

  @override
  String get manageProteinPreferences => '食べたくないタンパク質を選択';

  @override
  String get noProteinTypesAvailable => '利用可能なタンパク質がありません';

  @override
  String get dontEat => '食べない：';

  @override
  String get proteinPreferenceUpdated => 'タンパク質の設定を更新しました';

  @override
  String get errorOccurred => 'エラーが発生しました。もう一度お試しください';
}
