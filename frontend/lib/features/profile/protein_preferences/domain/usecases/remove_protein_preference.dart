import '../repositories/protein_preference_repository.dart';

class RemoveProteinPreference {
  final ProteinPreferenceRepository repository;

  RemoveProteinPreference(this.repository);

  Future<void> call({required int proteinTypeId}) async {
    return await repository.removeProteinPreference(proteinTypeId: proteinTypeId);
  }
}
