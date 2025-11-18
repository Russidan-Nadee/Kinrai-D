class AdminInfoModel {
  final List<MenuSummary> menus;
  final PaginationInfo pagination;

  const AdminInfoModel({
    required this.menus,
    required this.pagination,
  });

  factory AdminInfoModel.fromJson(Map<String, dynamic> json) {
    return AdminInfoModel(
      menus: (json['menus'] as List<dynamic>)
          .map((menu) => MenuSummary.fromJson(menu))
          .toList(),
      pagination: PaginationInfo.fromJson(json['pagination']),
    );
  }
}

class MenuSummary {
  final int id;
  final String key;
  final String? imageUrl;
  final String mealTime;
  final bool isActive;
  final String name;

  const MenuSummary({
    required this.id,
    required this.key,
    this.imageUrl,
    required this.mealTime,
    required this.isActive,
    required this.name,
  });

  factory MenuSummary.fromJson(Map<String, dynamic> json) {
    // Get English translation name
    String name = json['key'];
    if (json['Translations'] != null && json['Translations'].isNotEmpty) {
      final englishTranslation = (json['Translations'] as List)
          .firstWhere((t) => t['language'] == 'en', orElse: () => null);
      if (englishTranslation != null) {
        name = englishTranslation['name'] ?? json['key'];
      }
    }

    return MenuSummary(
      id: json['id'],
      key: json['key'],
      imageUrl: json['image_url'],
      mealTime: json['meal_time'],
      isActive: json['is_active'],
      name: name,
    );
  }
}

class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'],
      limit: json['limit'],
      total: json['total'],
      totalPages: json['totalPages'],
    );
  }
}