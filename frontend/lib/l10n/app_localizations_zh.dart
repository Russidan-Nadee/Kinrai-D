// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Kinrai D';

  @override
  String get welcome => '欢迎来到 Kinrai D！';

  @override
  String get tapToRandomMenu => '点击按钮随机选择美味菜单';

  @override
  String get randomMenu => '随机菜单';

  @override
  String get recommendedMenu => '推荐菜单';

  @override
  String get cannotRandomMenu => '无法随机选择菜单，请重试。';

  @override
  String get noRating => '暂无评分';

  @override
  String get user => '用户';

  @override
  String get manageSettings => '管理您的设置';

  @override
  String get selectLanguage => '选择语言';

  @override
  String languageChanged(String language) {
    return '已切换到$language';
  }

  @override
  String get otherFeaturesDeveloping => '其他功能正在开发中';

  @override
  String get comingSoon => '即将推出！';

  @override
  String get main => '主页';

  @override
  String get profile => '个人资料';

  @override
  String get admin => '管理员';

  @override
  String get errorOccurred => '发生错误，请重试';
}
