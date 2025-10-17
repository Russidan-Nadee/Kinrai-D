import 'package:equatable/equatable.dart';

class ProteinTypeEntity extends Equatable {
  final int id;
  final String key;
  final String name;

  const ProteinTypeEntity({
    required this.id,
    required this.key,
    required this.name,
  });

  @override
  List<Object?> get props => [id, key, name];
}

class ProteinPreferenceEntity extends Equatable {
  final int proteinTypeId;
  final String proteinTypeName;
  final bool exclude;

  const ProteinPreferenceEntity({
    required this.proteinTypeId,
    required this.proteinTypeName,
    required this.exclude,
  });

  @override
  List<Object?> get props => [proteinTypeId, proteinTypeName, exclude];
}
