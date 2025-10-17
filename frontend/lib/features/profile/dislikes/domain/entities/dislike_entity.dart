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

  @override
  List<Object?> get props => [menuId, menuName, menuDescription, reason, createdAt];
}
