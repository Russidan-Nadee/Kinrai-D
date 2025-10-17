import '../entities/protein_preference_entity.dart';

abstract class ProteinPreferenceRepository {
  Future<List<ProteinTypeEntity>> getAvailableProteinTypes({String language = 'th'});
  Future<List<ProteinPreferenceEntity>> getUserProteinPreferences({String language = 'th'});
  Future<void> setProteinPreference({required int proteinTypeId, required bool exclude});
  Future<void> removeProteinPreference({required int proteinTypeId});
}
