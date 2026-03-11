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

  String get errorOccurred {
    switch (locale.languageCode) {
      case 'en':
        return 'An error occurred. Please try again';
      case 'ja':
        return 'エラーが発生しました。もう一度お試しください';
      case 'zh':
        return '发生错误，请重试';
      default:
        return 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง';
    }
  }

  // Dislike actions
  String get dislikeRemoved {
    switch (locale.languageCode) {
      case 'en':
        return 'Removed from disliked list';
      case 'ja':
        return '嫌いリストから削除しました';
      case 'zh':
        return '已从不喜欢列表中移除';
      default:
        return 'ลบออกจากรายการไม่ชอบแล้ว';
    }
  }

  String get dislikeAdded {
    switch (locale.languageCode) {
      case 'en':
        return 'Added to disliked list';
      case 'ja':
        return '嫌いリストに追加しました';
      case 'zh':
        return '已添加到不喜欢列表';
      default:
        return 'เพิ่มในรายการไม่ชอบแล้ว';
    }
  }

  String get dislike {
    switch (locale.languageCode) {
      case 'en':
        return 'Dislike';
      case 'ja':
        return '嫌い';
      case 'zh':
        return '不喜欢';
      default:
        return 'ไม่ชอบ';
    }
  }

  String get disliked {
    switch (locale.languageCode) {
      case 'en':
        return 'Disliked';
      case 'ja':
        return '嫌いにした';
      case 'zh':
        return '已不喜欢';
      default:
        return 'ไม่ชอบแล้ว';
    }
  }

  // Auth dialog
  String get loginRequired {
    switch (locale.languageCode) {
      case 'en':
        return 'Account Required';
      case 'ja':
        return 'アカウントが必要';
      case 'zh':
        return '需要账户';
      default:
        return 'ต้องการบัญชี';
    }
  }

  String get loginRequiredMessage {
    switch (locale.languageCode) {
      case 'en':
        return 'This feature requires you to sign in first';
      case 'ja':
        return 'この機能を使用するにはサインインが必要です';
      case 'zh':
        return '使用此功能需要先登录';
      default:
        return 'ฟีเจอร์นี้จำเป็นต้องเข้าสู่ระบบก่อนใช้งาน';
    }
  }

  String get cancel {
    switch (locale.languageCode) {
      case 'en':
        return 'Cancel';
      case 'ja':
        return 'キャンセル';
      case 'zh':
        return '取消';
      default:
        return 'ยกเลิก';
    }
  }

  String get signInOrSignUp {
    switch (locale.languageCode) {
      case 'en':
        return 'Sign In / Sign Up';
      case 'ja':
        return 'サインイン / サインアップ';
      case 'zh':
        return '登录 / 注册';
      default:
        return 'เข้าสู่ระบบ / สมัครสมาชิก';
    }
  }

  // Menu card
  String get active {
    switch (locale.languageCode) {
      case 'en':
        return 'Active';
      case 'ja':
        return 'アクティブ';
      case 'zh':
        return '活跃';
      default:
        return 'ใช้งานอยู่';
    }
  }

  String ingredientsCount(int count) {
    switch (locale.languageCode) {
      case 'en':
        return '$count ingredients';
      case 'ja':
        return '$count個の食材';
      case 'zh':
        return '$count种食材';
      default:
        return '$count ส่วนผสม';
    }
  }

  String get mealTimeBreakfast {
    switch (locale.languageCode) {
      case 'en':
        return 'Breakfast';
      case 'ja':
        return '朝食';
      case 'zh':
        return '早餐';
      default:
        return 'อาหารเช้า';
    }
  }

  String get mealTimeLunch {
    switch (locale.languageCode) {
      case 'en':
        return 'Lunch';
      case 'ja':
        return '昼食';
      case 'zh':
        return '午餐';
      default:
        return 'อาหารกลางวัน';
    }
  }

  String get mealTimeDinner {
    switch (locale.languageCode) {
      case 'en':
        return 'Dinner';
      case 'ja':
        return '夕食';
      case 'zh':
        return '晚餐';
      default:
        return 'อาหารเย็น';
    }
  }

  String get mealTimeSnack {
    switch (locale.languageCode) {
      case 'en':
        return 'Snack';
      case 'ja':
        return 'スナック';
      case 'zh':
        return '零食';
      default:
        return 'ของว่าง';
    }
  }

  // Guest profile
  String get guestUser {
    switch (locale.languageCode) {
      case 'en':
        return 'Guest User';
      case 'ja':
        return 'ゲストユーザー';
      case 'zh':
        return '访客用户';
      default:
        return 'ผู้ใช้ชั่วคราว';
    }
  }

  String get createAccountFor {
    switch (locale.languageCode) {
      case 'en':
        return 'Create an account to:';
      case 'ja':
        return 'アカウントを作成して:';
      case 'zh':
        return '创建账户以:';
      default:
        return 'สร้างบัญชีเพื่อ:';
    }
  }

  String get benefitSaveDislikes {
    switch (locale.languageCode) {
      case 'en':
        return 'Save your dislikes';
      case 'ja':
        return '嫌いなものを保存';
      case 'zh':
        return '保存不喜欢的菜品';
      default:
        return 'บันทึกรายการไม่ชอบ';
    }
  }

  String get benefitSelectProtein {
    switch (locale.languageCode) {
      case 'en':
        return 'Select protein preferences';
      case 'ja':
        return 'タンパク質の好みを設定';
      case 'zh':
        return '设置蛋白质偏好';
      default:
        return 'เลือกเนื้อสัตว์ที่ชอบ/ไม่ชอบ';
    }
  }

  String get benefitPersonalizedMenus {
    switch (locale.languageCode) {
      case 'en':
        return 'Get personalized menu recommendations';
      case 'ja':
        return 'パーソナライズされたメニューを取得';
      case 'zh':
        return '获取个性化菜单推荐';
      default:
        return 'รับเมนูที่ปรับตามความชอบ';
    }
  }

  String get signUpOrSignIn {
    switch (locale.languageCode) {
      case 'en':
        return 'Sign Up / Sign In';
      case 'ja':
        return 'サインアップ / サインイン';
      case 'zh':
        return '注册 / 登录';
      default:
        return 'สมัครสมาชิก / เข้าสู่ระบบ';
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
