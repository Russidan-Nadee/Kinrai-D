import 'package:flutter/material.dart';

class AuthLocalizations {
  final Locale locale;

  AuthLocalizations(this.locale);

  static AuthLocalizations of(BuildContext context) {
    return Localizations.of<AuthLocalizations>(context, AuthLocalizations)!;
  }

  static const LocalizationsDelegate<AuthLocalizations> delegate =
      _AuthLocalizationsDelegate();

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

class _AuthLocalizationsDelegate
    extends LocalizationsDelegate<AuthLocalizations> {
  const _AuthLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'th', 'ja', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AuthLocalizations> load(Locale locale) async {
    return AuthLocalizations(locale);
  }

  @override
  bool shouldReload(_AuthLocalizationsDelegate old) => false;
}
