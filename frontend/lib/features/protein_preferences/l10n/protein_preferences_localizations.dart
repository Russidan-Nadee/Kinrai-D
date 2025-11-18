import 'package:flutter/material.dart';

class ProteinPreferencesLocalizations {
  final Locale locale;

  ProteinPreferencesLocalizations(this.locale);

  static ProteinPreferencesLocalizations of(BuildContext context) {
    return Localizations.of<ProteinPreferencesLocalizations>(
        context, ProteinPreferencesLocalizations)!;
  }

  static const LocalizationsDelegate<ProteinPreferencesLocalizations> delegate =
      _ProteinPreferencesLocalizationsDelegate();

  String get proteinPreferences {
    switch (locale.languageCode) {
      case 'en':
        return 'Protein Preferences';
      case 'ja':
        return '食べたくないタンパク質';
      case 'zh':
        return '不想吃的肉类';
      default:
        return 'ไม่อยากกินเนื้อสัตว์';
    }
  }

  String get manageProteinPreferences {
    switch (locale.languageCode) {
      case 'en':
        return 'Choose which proteins you don\'t want to eat';
      case 'ja':
        return '食べたくないタンパク質を選択';
      case 'zh':
        return '选择不想吃的肉类';
      default:
        return 'เลือกเนื้อสัตว์ที่ไม่อยากกิน';
    }
  }

  String get noProteinTypesAvailable {
    switch (locale.languageCode) {
      case 'en':
        return 'No protein types available';
      case 'ja':
        return '利用可能なタンパク質がありません';
      case 'zh':
        return '没有可用的肉类';
      default:
        return 'ไม่มีประเภทเนื้อสัตว์';
    }
  }

  String get dontEat {
    switch (locale.languageCode) {
      case 'en':
        return 'Don\'t eat:';
      case 'ja':
        return '食べない：';
      case 'zh':
        return '不吃：';
      default:
        return 'ไม่กิน:';
    }
  }

  String get proteinPreferenceUpdated {
    switch (locale.languageCode) {
      case 'en':
        return 'Protein preference updated';
      case 'ja':
        return 'タンパク質の設定を更新しました';
      case 'zh':
        return '已更新肉类偏好';
      default:
        return 'อัพเดตความชอบเนื้อสัตว์แล้ว';
    }
  }
}

class _ProteinPreferencesLocalizationsDelegate
    extends LocalizationsDelegate<ProteinPreferencesLocalizations> {
  const _ProteinPreferencesLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'th', 'ja', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<ProteinPreferencesLocalizations> load(Locale locale) async {
    return ProteinPreferencesLocalizations(locale);
  }

  @override
  bool shouldReload(_ProteinPreferencesLocalizationsDelegate old) => false;
}
