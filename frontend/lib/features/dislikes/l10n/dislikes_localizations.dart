import 'package:flutter/material.dart';

class DislikesLocalizations {
  final Locale locale;

  DislikesLocalizations(this.locale);

  static DislikesLocalizations of(BuildContext context) {
    return Localizations.of<DislikesLocalizations>(
        context, DislikesLocalizations)!;
  }

  static const LocalizationsDelegate<DislikesLocalizations> delegate =
      _DislikesLocalizationsDelegate();

  String get dislikeList {
    switch (locale.languageCode) {
      case 'en':
        return 'Dislike List';
      case 'ja':
        return '苦手なメニュー';
      case 'zh':
        return '不喜欢的菜单';
      default:
        return 'รายการที่ไม่ชอบ';
    }
  }

  String get noDislikes {
    switch (locale.languageCode) {
      case 'en':
        return 'No dislikes yet';
      case 'ja':
        return 'まだ苦手なメニューはありません';
      case 'zh':
        return '还没有不喜欢的菜单';
      default:
        return 'ยังไม่มีรายการที่ไม่ชอบ';
    }
  }

  String get select {
    switch (locale.languageCode) {
      case 'en':
        return 'Select';
      case 'ja':
        return '選択';
      case 'zh':
        return '选择';
      default:
        return 'เลือก';
    }
  }

  String get deselectAll {
    switch (locale.languageCode) {
      case 'en':
        return 'Deselect All';
      case 'ja':
        return 'すべて解除';
      case 'zh':
        return '取消全选';
      default:
        return 'ยกเลิกทั้งหมด';
    }
  }

  String get selectAll {
    switch (locale.languageCode) {
      case 'en':
        return 'Select All';
      case 'ja':
        return 'すべて選択';
      case 'zh':
        return '全选';
      default:
        return 'เลือกทั้งหมด';
    }
  }

  String showAllCount(int count) {
    switch (locale.languageCode) {
      case 'en':
        return 'Show All ($count)';
      case 'ja':
        return 'すべて表示 ($count)';
      case 'zh':
        return '显示全部 ($count)';
      default:
        return 'ดูทั้งหมด ($count)';
    }
  }

  String get showLess {
    switch (locale.languageCode) {
      case 'en':
        return 'Show Less';
      case 'ja':
        return '折りたたむ';
      case 'zh':
        return '收起';
      default:
        return 'ย่อเก็บ';
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

  String removeSelectedCount(int count) {
    switch (locale.languageCode) {
      case 'en':
        return 'Remove Selected ($count)';
      case 'ja':
        return '選択を削除 ($count)';
      case 'zh':
        return '删除选中 ($count)';
      default:
        return 'ลบที่เลือก ($count)';
    }
  }

  String get reason {
    switch (locale.languageCode) {
      case 'en':
        return 'Reason';
      case 'ja':
        return '理由';
      case 'zh':
        return '原因';
      default:
        return 'เหตุผล';
    }
  }

  String get addedOn {
    switch (locale.languageCode) {
      case 'en':
        return 'Added on';
      case 'ja':
        return '追加日';
      case 'zh':
        return '添加日期';
      default:
        return 'เพิ่มเมื่อ';
    }
  }

  String get removeFromDislikeList {
    switch (locale.languageCode) {
      case 'en':
        return 'Remove from dislike list';
      case 'ja':
        return '苦手リストから削除';
      case 'zh':
        return '从不喜欢列表中删除';
      default:
        return 'ลบจากรายการไม่ชอบ';
    }
  }

  String get removedFromDislikeList {
    switch (locale.languageCode) {
      case 'en':
        return 'Removed from dislike list';
      case 'ja':
        return '苦手リストから削除しました';
      case 'zh':
        return '已从不喜欢列表中删除';
      default:
        return 'ลบออกจากรายการไม่ชอบแล้ว';
    }
  }

  String removedMultipleFromDislikeList(int count) {
    switch (locale.languageCode) {
      case 'en':
        return 'Removed $count items from dislike list';
      case 'ja':
        return '$count件を苦手リストから削除しました';
      case 'zh':
        return '已从不喜欢列表中删除$count项';
      default:
        return 'ลบรายการที่ไม่ชอบ $count รายการแล้ว';
    }
  }
}

class _DislikesLocalizationsDelegate
    extends LocalizationsDelegate<DislikesLocalizations> {
  const _DislikesLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'th', 'ja', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<DislikesLocalizations> load(Locale locale) async {
    return DislikesLocalizations(locale);
  }

  @override
  bool shouldReload(_DislikesLocalizationsDelegate old) => false;
}
