import '../repositories/protein_preference_repository.dart';

class SetProteinPreference {
  final ProteinPreferenceRepository repository;

  SetProteinPreference(this.repository);

  Future<void> call({required int proteinTypeId, required bool exclude}) async {
    return await repository.setProteinPreference(
      proteinTypeId: proteinTypeId,
      exclude: exclude,
    );
  }
}
