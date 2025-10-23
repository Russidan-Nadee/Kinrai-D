import 'package:equatable/equatable.dart';

class DislikeEntity extends Equatable {
  final int menuId;
  final String menuName;
  final String? menuDescription;
  final String? reason;
  final DateTime createdAt;

  const DislikeEntity({
    required this.menuId,
    required this.menuName,
    this.menuDescription,
    this.reason,
    required this.createdAt,
  });

  /// Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'menuId': menuId,
      'menuName': menuName,
      'menuDescription': menuDescription,
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON (cached data)
  factory DislikeEntity.fromJson(Map<String, dynamic> json) {
    return DislikeEntity(
      menuId: json['menuId'] as int,
      menuName: json['menuName'] as String,
      menuDescription: json['menuDescription'] as String?,
      reason: json['reason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [menuId, menuName, menuDescription, reason, createdAt];
}
