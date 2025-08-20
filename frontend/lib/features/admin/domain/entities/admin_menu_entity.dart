class AdminMenuEntity {
  final int id;
  final String key;
  final String? imageUrl;
  final String mealTime;
  final bool isActive;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AdminMenuEntity({
    required this.id,
    required this.key,
    this.imageUrl,
    required this.mealTime,
    required this.isActive,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
}

class PaginationEntity {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginationEntity({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });
}

class AdminMenuListEntity {
  final List<AdminMenuEntity> menus;
  final PaginationEntity pagination;

  const AdminMenuListEntity({
    required this.menus,
    required this.pagination,
  });
}