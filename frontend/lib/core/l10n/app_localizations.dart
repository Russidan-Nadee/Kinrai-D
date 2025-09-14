import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Navigation
  String get appName => 'Kinrai D';

  String get main {
    switch (locale.languageCode) {
      case 'en':
        return 'Main';
      case 'ja':
        return 'メイン';
      case 'zh':
        return '主页';
      default:
        return 'หน้าหลัก';
    }
  }

  String get profile {
    switch (locale.languageCode) {
      case 'en':
        return 'Profile';
      case 'ja':
        return 'プロフィール';
      case 'zh':
        return '个人资料';
      default:
        return 'โปรไฟล์';
    }
  }

  String get admin {
    switch (locale.languageCode) {
      case 'en':
        return 'Admin';
      case 'ja':
        return '管理者';
      case 'zh':
        return '管理员';
      default:
        return 'ผู้ดูแล';
    }
  }

  // Home Page
  String get welcome {
    switch (locale.languageCode) {
      case 'en':
        return 'Welcome to Kinrai D!';
      case 'ja':
        return 'Kinrai Dへようこそ！';
      case 'zh':
        return '欢迎来到 Kinrai D！';
      default:
        return 'ยินดีต้อนรับสู่ Kinrai D!';
    }
  }

  String get tapToRandomMenu {
    switch (locale.languageCode) {
      case 'en':
        return 'Tap to random delicious menu';
      case 'ja':
        return 'ボタンを押して美味しいメニューをランダムに選択';
      case 'zh':
        return '点击按钮随机选择美味菜单';
      default:
        return 'กดปุ่มเพื่อสุ่มเมนูอาหารแสนอร่อย';
    }
  }

  // Random Menu
  String get randomMenu {
    switch (locale.languageCode) {
      case 'en':
        return 'Random Menu';
      case 'ja':
        return 'ランダムメニュー';
      case 'zh':
        return '随机菜单';
      default:
        return 'สุ่มเมนูอาหาร';
    }
  }

  String get cannotRandomMenu {
    switch (locale.languageCode) {
      case 'en':
        return 'Cannot random menu. Please try again.';
      case 'ja':
        return 'メニューをランダムに選択できません。もう一度お試しください。';
      case 'zh':
        return '无法随机选择菜单，请重试。';
      default:
        return 'ไม่สามารถสุ่มเมนูได้ กรุณาลองใหม่อีกครั้ง';
    }
  }

  // Profile Page
  String get user {
    switch (locale.languageCode) {
      case 'en':
        return 'User';
      case 'ja':
        return 'ユーザー';
      case 'zh':
        return '用户';
      default:
        return 'ผู้ใช้งาน';
    }
  }

  String get manageSettings {
    switch (locale.languageCode) {
      case 'en':
        return 'Manage your settings';
      case 'ja':
        return '設定を管理する';
      case 'zh':
        return '管理您的设置';
      default:
        return 'จัดการการตั้งค่าของคุณ';
    }
  }

  String get selectLanguage {
    switch (locale.languageCode) {
      case 'en':
        return 'Select Language';
      case 'ja':
        return '言語を選択';
      case 'zh':
        return '选择语言';
      default:
        return 'เลือกภาษา';
    }
  }

  String languageChanged(String language) {
    switch (locale.languageCode) {
      case 'en':
        return 'Language changed to $language';
      case 'ja':
        return '言語を${language}に変更しました';
      case 'zh':
        return '已切换到$language';
      default:
        return 'เปลี่ยนภาษาเป็น $language แล้ว';
    }
  }

  String get otherFeaturesDeveloping {
    switch (locale.languageCode) {
      case 'en':
        return 'Other features are being developed';
      case 'ja':
        return 'その他の機能を開発中';
      case 'zh':
        return '其他功能正在开发中';
      default:
        return 'ฟีเจอร์อื่นๆ กำลังพัฒนา';
    }
  }

  String get comingSoon {
    switch (locale.languageCode) {
      case 'en':
        return 'Coming soon!';
      case 'ja':
        return '近日公開！';
      case 'zh':
        return '即将推出！';
      default:
        return 'เร็วๆ นี้!';
    }
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'th', 'ja', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}