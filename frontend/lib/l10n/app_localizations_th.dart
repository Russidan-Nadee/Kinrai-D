// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appName => 'Kinrai D';

  @override
  String get welcome => 'ยินดีต้อนรับสู่ Kinrai D!';

  @override
  String get tapToRandomMenu => 'กดปุ่มเพื่อสุ่มเมนูอาหารแสนอร่อย';

  @override
  String get randomMenu => 'สุ่มเมนูอาหาร';

  @override
  String get recommendedMenu => 'เมนูที่แนะนำ';

  @override
  String get cannotRandomMenu => 'ไม่สามารถสุ่มเมนูได้ กรุณาลองใหม่อีกครั้ง';

  @override
  String get noRating => 'ยังไม่มีคะแนน';

  @override
  String get user => 'ผู้ใช้งาน';

  @override
  String get manageSettings => 'จัดการการตั้งค่าของคุณ';

  @override
  String get selectLanguage => 'เลือกภาษา';

  @override
  String languageChanged(String language) {
    return 'เปลี่ยนภาษาเป็น $language แล้ว';
  }

  @override
  String get otherFeaturesDeveloping => 'ฟีเจอร์อื่นๆ กำลังพัฒนา';

  @override
  String get comingSoon => 'เร็วๆ นี้!';

  @override
  String get main => 'หน้าหลัก';

  @override
  String get profile => 'โปรไฟล์';

  @override
  String get admin => 'ผู้ดูแล';

  @override
  String get errorOccurred => 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง';
}
