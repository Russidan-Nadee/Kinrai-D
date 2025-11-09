import 'package:flutter/material.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/protein_preference_entity.dart';
import '../../domain/usecases/get_available_protein_types.dart';
import '../../domain/usecases/get_user_protein_preferences.dart';
import '../../domain/usecases/set_protein_preference.dart';
import '../../domain/usecases/remove_protein_preference.dart';

/// Provider to manage protein preference state and operations
class ProteinPreferenceProvider extends ChangeNotifier {
  // Dependencies
  final GetAvailableProteinTypes _getAvailableProteinTypes;
  final GetUserProteinPreferences _getUserProteinPreferences;
  final SetProteinPreference _setProteinPreference;
  final RemoveProteinPreference _removeProteinPreference;

  // State
  List<ProteinTypeEntity> _availableProteinTypes = [];
  List<ProteinPreferenceEntity> _userProteinPreferences = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<ProteinTypeEntity> get availableProteinTypes => _availableProteinTypes;
  List<ProteinPreferenceEntity> get userProteinPreferences => _userProteinPreferences;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ProteinPreferenceProvider({
    required GetAvailableProteinTypes getAvailableProteinTypes,
    required GetUserProteinPreferences getUserProteinPreferences,
    required SetProteinPreference setProteinPreference,
    required RemoveProteinPreference removeProteinPreference,
  })  : _getAvailableProteinTypes = getAvailableProteinTypes,
        _getUserProteinPreferences = getUserProteinPreferences,
        _setProteinPreference = setProteinPreference,
        _removeProteinPreference = removeProteinPreference;

  /// Load protein preferences data with cache-first strategy
  Future<void> loadProteinPreferences({required String language}) async {
    try {
      AppLogger.info('🚀 [ProteinPreferenceProvider] Loading protein preferences...');
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Load protein preferences data in parallel for maximum performance
      final results = await Future.wait([
        _getAvailableProteinTypes(language: language),
        _getUserProteinPreferences(language: language),
      ]);

      _availableProteinTypes = results[0] as List<ProteinTypeEntity>;
      _userProteinPreferences = results[1] as List<ProteinPreferenceEntity>;

      AppLogger.info('✅ [ProteinPreferenceProvider] Loaded ${_availableProteinTypes.length} protein types');
    } catch (e) {
      AppLogger.error('❌ [ProteinPreferenceProvider] Error loading protein preferences', e);
      _errorMessage = 'Failed to load protein preferences';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle protein preference with optimistic UI update
  Future<bool> toggleProteinPreference(int proteinTypeId, bool exclude, String language) async {
    // OPTIMISTIC UPDATE: Update UI immediately before API call
    final previousPreferences = List<ProteinPreferenceEntity>.from(_userProteinPreferences);

    try {
      AppLogger.info('🔄 [ProteinPreferenceProvider] Toggling protein $proteinTypeId to exclude=$exclude');

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

      AppLogger.info('✅ [ProteinPreferenceProvider] Successfully toggled protein preference');
      return true;
    } catch (e) {
      AppLogger.error('❌ [ProteinPreferenceProvider] Error toggling protein preference - rolling back', e);

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

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
