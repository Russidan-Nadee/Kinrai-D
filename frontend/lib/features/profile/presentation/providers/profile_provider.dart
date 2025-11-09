import 'package:flutter/material.dart';
import '../../../../core/utils/logger.dart';
import '../../../protein_preferences/domain/entities/protein_preference_entity.dart';
import '../../../protein_preferences/domain/usecases/get_available_protein_types.dart';
import '../../../protein_preferences/domain/usecases/get_user_protein_preferences.dart';
import '../../../protein_preferences/domain/usecases/set_protein_preference.dart';
import '../../../protein_preferences/domain/usecases/remove_protein_preference.dart';

/// Provider to manage profile-related data (protein preferences only)
/// Note: Dislike management has been moved to DislikeProvider
class ProfileProvider extends ChangeNotifier {
  // Dependencies
  final GetAvailableProteinTypes _getAvailableProteinTypes;
  final GetUserProteinPreferences _getUserProteinPreferences;
  final SetProteinPreference _setProteinPreference;
  final RemoveProteinPreference _removeProteinPreference;

  // Protein Preferences State
  List<ProteinTypeEntity> _availableProteinTypes = [];
  List<ProteinPreferenceEntity> _userProteinPreferences = [];

  // Getters
  List<ProteinTypeEntity> get availableProteinTypes => _availableProteinTypes;
  List<ProteinPreferenceEntity> get userProteinPreferences => _userProteinPreferences;

  ProfileProvider({
    required GetAvailableProteinTypes getAvailableProteinTypes,
    required GetUserProteinPreferences getUserProteinPreferences,
    required SetProteinPreference setProteinPreference,
    required RemoveProteinPreference removeProteinPreference,
  })  : _getAvailableProteinTypes = getAvailableProteinTypes,
        _getUserProteinPreferences = getUserProteinPreferences,
        _setProteinPreference = setProteinPreference,
        _removeProteinPreference = removeProteinPreference;

  /// Load all profile data in parallel for optimal performance
  Future<void> loadAllProfileData({required String language}) async {
    try {
      AppLogger.info('🚀 [ProfileProvider] Loading protein preferences data in parallel...');
      final startTime = DateTime.now();

      // NEVER show loading spinner - we'll use cache-first strategy
      // This prevents the spinner from showing even when data is being fetched
      // Users will see cached data instantly, and UI will update silently if needed

      // Load protein preferences data in parallel for maximum performance
      final results = await Future.wait([
        _getAvailableProteinTypes(language: language),
        _getUserProteinPreferences(language: language),
      ]);

      final duration = DateTime.now().difference(startTime);
      AppLogger.info('✅ [ProfileProvider] Loaded all data in ${duration.inMilliseconds}ms');

      _availableProteinTypes = results[0] as List<ProteinTypeEntity>;
      _userProteinPreferences = results[1] as List<ProteinPreferenceEntity>;

      notifyListeners();
    } catch (e) {
      AppLogger.error('❌ [ProfileProvider] Error loading profile data', e);
      notifyListeners();
    }
  }

  /// Toggle protein preference with optimistic UI update
  Future<bool> toggleProteinPreference(int proteinTypeId, bool exclude, String language) async {
    // OPTIMISTIC UPDATE: Update UI immediately before API call
    final previousPreferences = List<ProteinPreferenceEntity>.from(_userProteinPreferences);

    try {
      // Update UI instantly for better UX
      if (exclude) {
        // Add to excluded list immediately
        final proteinType = _availableProteinTypes.firstWhere(
          (p) => p.id == proteinTypeId,
          orElse: () => ProteinTypeEntity(id: proteinTypeId, key: '', name: ''),
        );

        _userProteinPreferences = [
          ..._userProteinPreferences,
          ProteinPreferenceEntity(
            proteinTypeId: proteinTypeId,
            proteinTypeName: proteinType.name,
            exclude: true,
          ),
        ];
      } else {
        // Remove from excluded list immediately
        _userProteinPreferences = _userProteinPreferences
            .where((pref) => pref.proteinTypeId != proteinTypeId)
            .toList();
      }

      // Notify listeners immediately - UI updates now!
      notifyListeners();

      // Now make API call in background
      if (exclude) {
        await _setProteinPreference(proteinTypeId: proteinTypeId, exclude: true);
      } else {
        await _removeProteinPreference(proteinTypeId: proteinTypeId);
      }

      // Reload from server to ensure consistency (silent update)
      final results = await Future.wait([
        _getAvailableProteinTypes(language: language),
        _getUserProteinPreferences(language: language),
      ]);

      _availableProteinTypes = results[0] as List<ProteinTypeEntity>;
      _userProteinPreferences = results[1] as List<ProteinPreferenceEntity>;
      notifyListeners();

      return true;
    } catch (e) {
      AppLogger.error('❌ [ProfileProvider] Error toggling protein preference - rolling back', e);

      // ROLLBACK: Restore previous state on error
      _userProteinPreferences = previousPreferences;
      notifyListeners();

      return false;
    }
  }

  /// Check if a protein is excluded
  bool isProteinExcluded(int proteinTypeId) {
    return _userProteinPreferences.any(
      (pref) => pref.proteinTypeId == proteinTypeId && pref.exclude,
    );
  }
}
