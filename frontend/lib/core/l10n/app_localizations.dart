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
        return '言語を$languageに変更しました';
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

  // Authentication
  String get signInToAccount {
    switch (locale.languageCode) {
      case 'en':
        return 'Sign in to your account';
      case 'ja':
        return 'アカウントにサインイン';
      case 'zh':
        return '登录您的账户';
      default:
        return 'เข้าสู่ระบบบัญชีของคุณ';
    }
  }

  String get email {
    switch (locale.languageCode) {
      case 'en':
        return 'Email';
      case 'ja':
        return 'メール';
      case 'zh':
        return '邮箱';
      default:
        return 'อีเมล';
    }
  }

  String get password {
    switch (locale.languageCode) {
      case 'en':
        return 'Password';
      case 'ja':
        return 'パスワード';
      case 'zh':
        return '密码';
      default:
        return 'รหัสผ่าน';
    }
  }

  String get signIn {
    switch (locale.languageCode) {
      case 'en':
        return 'Sign In';
      case 'ja':
        return 'サインイン';
      case 'zh':
        return '登录';
      default:
        return 'เข้าสู่ระบบ';
    }
  }

  String get signUp {
    switch (locale.languageCode) {
      case 'en':
        return 'Sign Up';
      case 'ja':
        return 'サインアップ';
      case 'zh':
        return '注册';
      default:
        return 'สมัครสมาชิก';
    }
  }

  String get dontHaveAccount {
    switch (locale.languageCode) {
      case 'en':
        return 'Don\'t have an account?';
      case 'ja':
        return 'アカウントをお持ちではありませんか？';
      case 'zh':
        return '还没有账户？';
      default:
        return 'ยังไม่มีบัญชี?';
    }
  }

  String get emailRequired {
    switch (locale.languageCode) {
      case 'en':
        return 'Email is required';
      case 'ja':
        return 'メールは必須です';
      case 'zh':
        return '邮箱为必填项';
      default:
        return 'อีเมลจำเป็น';
    }
  }

  String get emailInvalid {
    switch (locale.languageCode) {
      case 'en':
        return 'Please enter a valid email';
      case 'ja':
        return '有効なメールを入力してください';
      case 'zh':
        return '请输入有效的邮箱';
      default:
        return 'กรุณากรอกอีเมลที่ถูกต้อง';
    }
  }

  String get passwordRequired {
    switch (locale.languageCode) {
      case 'en':
        return 'Password is required';
      case 'ja':
        return 'パスワードは必須です';
      case 'zh':
        return '密码为必填项';
      default:
        return 'รหัสผ่านจำเป็น';
    }
  }

  String get passwordMinLength {
    switch (locale.languageCode) {
      case 'en':
        return 'Password must be at least 6 characters';
      case 'ja':
        return 'パスワードは6文字以上である必要があります';
      case 'zh':
        return '密码至少需要6个字符';
      default:
        return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
    }
  }

  String get signOut {
    switch (locale.languageCode) {
      case 'en':
        return 'Sign Out';
      case 'ja':
        return 'サインアウト';
      case 'zh':
        return '退出登录';
      default:
        return 'ออกจากระบบ';
    }
  }

  String get createNewAccount {
    switch (locale.languageCode) {
      case 'en':
        return 'Create a new account';
      case 'ja':
        return '新しいアカウントを作成';
      case 'zh':
        return '创建新账户';
      default:
        return 'สร้างบัญชีใหม่';
    }
  }

  String get confirmPassword {
    switch (locale.languageCode) {
      case 'en':
        return 'Confirm Password';
      case 'ja':
        return 'パスワード確認';
      case 'zh':
        return '确认密码';
      default:
        return 'ยืนยันรหัสผ่าน';
    }
  }

  String get confirmPasswordRequired {
    switch (locale.languageCode) {
      case 'en':
        return 'Please confirm your password';
      case 'ja':
        return 'パスワードを確認してください';
      case 'zh':
        return '请确认您的密码';
      default:
        return 'กรุณายืนยันรหัสผ่าน';
    }
  }

  String get passwordsDoNotMatch {
    switch (locale.languageCode) {
      case 'en':
        return 'Passwords do not match';
      case 'ja':
        return 'パスワードが一致しません';
      case 'zh':
        return '密码不匹配';
      default:
        return 'รหัสผ่านไม่ตรงกัน';
    }
  }

  String get alreadyHaveAccount {
    switch (locale.languageCode) {
      case 'en':
        return 'Already have an account?';
      case 'ja':
        return 'すでにアカウントをお持ちですか？';
      case 'zh':
        return '已有账户？';
      default:
        return 'มีบัญชีอยู่แล้ว?';
    }
  }

  String get signUpSuccess {
    switch (locale.languageCode) {
      case 'en':
        return 'Account created successfully!';
      case 'ja':
        return 'アカウントが正常に作成されました！';
      case 'zh':
        return '账户创建成功！';
      default:
        return 'สร้างบัญชีสำเร็จ!';
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
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
