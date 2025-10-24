import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../protein_preferences/domain/entities/protein_preference_entity.dart';
import '../../../protein_preferences/domain/usecases/get_available_protein_types.dart';
import '../../../protein_preferences/domain/usecases/get_user_protein_preferences.dart';
import '../../../protein_preferences/domain/usecases/set_protein_preference.dart';
import '../../../protein_preferences/domain/usecases/remove_protein_preference.dart';
import '../../../protein_preferences/data/repositories/protein_preference_repository_impl.dart';
import '../../../protein_preferences/data/datasources/protein_preference_remote_data_source.dart';

class ProteinPreferencesSection extends StatefulWidget {
  const ProteinPreferencesSection({super.key});

  @override
  State<ProteinPreferencesSection> createState() => _ProteinPreferencesSectionState();
}

class _ProteinPreferencesSectionState extends State<ProteinPreferencesSection>
    with AutomaticKeepAliveClientMixin {
  late final GetAvailableProteinTypes _getAvailableProteinTypes;
  late final GetUserProteinPreferences _getUserProteinPreferences;
  late final SetProteinPreference _setProteinPreference;
  late final RemoveProteinPreference _removeProteinPreference;

  List<ProteinTypeEntity> _availableProteinTypes = [];
  List<ProteinPreferenceEntity> _userProteinPreferences = [];
  bool _isLoadingProteins = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Initialize use cases
    final dataSource = ProteinPreferenceRemoteDataSourceImpl();
    final repository = ProteinPreferenceRepositoryImpl(remoteDataSource: dataSource);
    _getAvailableProteinTypes = GetAvailableProteinTypes(repository);
    _getUserProteinPreferences = GetUserProteinPreferences(repository);
    _setProteinPreference = SetProteinPreference(repository);
    _removeProteinPreference = RemoveProteinPreference(repository);

    _loadProteinPreferences();
  }

  Future<void> _loadProteinPreferences() async {
    // Only show loading if we don't have data yet
    if (_availableProteinTypes.isEmpty) {
      setState(() {
        _isLoadingProteins = true;
      });
    }

    try {
      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );

      // Load available protein types and user preferences
      final availableTypes = await _getAvailableProteinTypes(
        language: languageProvider.currentLanguageCode,
      );
      final userPreferences = await _getUserProteinPreferences(
        language: languageProvider.currentLanguageCode,
      );

      if (mounted) {
        setState(() {
          _availableProteinTypes = availableTypes;
          _userProteinPreferences = userPreferences;
          _isLoadingProteins = false;
        });
      }
    } catch (e) {
      // Handle error silently for now
      if (mounted) {
        setState(() {
          _isLoadingProteins = false;
        });
      }
    }
  }

  Future<void> _toggleProteinPreference(int proteinTypeId, bool exclude) async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    try {
      if (exclude) {
        // Add to preferences (don't eat)
        await _setProteinPreference(
          proteinTypeId: proteinTypeId,
          exclude: true,
        );
      } else {
        // Remove from preferences (eat normally)
        await _removeProteinPreference(
          proteinTypeId: proteinTypeId,
        );
      }

      await _loadProteinPreferences(); // Reload the list

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              languageProvider.currentLanguageCode == 'en'
                  ? 'Protein preference updated'
                  : 'อัพเดตความชอบเนื้อสัตว์แล้ว',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              languageProvider.currentLanguageCode == 'en'
                  ? 'An error occurred. Please try again'
                  : 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isProteinExcluded(int proteinTypeId) {
    return _userProteinPreferences.any((pref) =>
        pref.proteinTypeId == proteinTypeId && pref.exclude
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.restaurant_outlined,
              color: Colors.orange[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              languageProvider.currentLanguageCode == 'en'
                  ? 'Protein Preferences'
                  : 'ไม่อยากกินเนื้อสัตว์',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          languageProvider.currentLanguageCode == 'en'
              ? 'Choose which proteins you don\'t want to eat'
              : 'เลือกเนื้อสัตว์ที่ไม่อยากกิน',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _isLoadingProteins && _availableProteinTypes.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                )
              : _availableProteinTypes.isEmpty && !_isLoadingProteins
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      languageProvider.currentLanguageCode == 'en'
                          ? 'No protein types available'
                          : 'ไม่มีประเภทเนื้อสัตว์',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Show current restrictions if any
                    if (_userProteinPreferences.isNotEmpty) ...[
                      Text(
                        languageProvider.currentLanguageCode == 'en'
                            ? 'Don\'t eat:'
                            : 'ไม่กิน:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _userProteinPreferences.map((pref) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.red[300]!),
                            ),
                            child: Text(
                              pref.proteinTypeName,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.red[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey[300]),
                      const SizedBox(height: 16),
                    ],
                    // All protein types with responsive grid
                    _buildProteinGrid(languageProvider),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildProteinGrid(LanguageProvider languageProvider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate how many columns can fit
        double itemWidth = 280; // Minimum width for each item
        int crossAxisCount = (constraints.maxWidth / itemWidth).floor();
        crossAxisCount = crossAxisCount < 1 ? 1 : crossAxisCount;

        // If screen is very narrow (mobile), use single column
        if (constraints.maxWidth < 500) {
          return Column(
            children: _availableProteinTypes.map((proteinType) {
              return _buildProteinItem(proteinType, languageProvider, true);
            }).toList(),
          );
        }

        // For wider screens, use grid
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 4.5,
          ),
          itemCount: _availableProteinTypes.length,
          itemBuilder: (context, index) {
            return _buildProteinItem(_availableProteinTypes[index], languageProvider, false);
          },
        );
      },
    );
  }

  Widget _buildProteinItem(ProteinTypeEntity proteinType, LanguageProvider languageProvider, bool isMobile) {
    final isExcluded = _isProteinExcluded(proteinType.id);

    return Container(
      width: isMobile ? double.infinity : null,
      margin: isMobile ? const EdgeInsets.only(bottom: 8) : EdgeInsets.zero,
      child: InkWell(
        onTap: () => _toggleProteinPreference(proteinType.id, !isExcluded),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 16 : 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isExcluded ? Colors.red[300]! : Colors.grey[300]!,
              width: 1.5,
            ),
            color: isExcluded ? Colors.red[50] : Colors.grey[50],
          ),
          child: Row(
            children: [
              Container(
                width: isMobile ? 24 : 20,
                height: isMobile ? 24 : 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isMobile ? 6 : 4),
                  border: Border.all(
                    color: isExcluded ? Colors.red[600]! : Colors.grey[400]!,
                    width: 2,
                  ),
                  color: isExcluded ? Colors.red[600] : Colors.transparent,
                ),
                child: isExcluded
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                        size: isMobile ? 16 : 14,
                      )
                    : null,
              ),
              SizedBox(width: isMobile ? 16 : 8),
              Expanded(
                child: Text(
                  proteinType.name,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 14,
                    fontWeight: FontWeight.w500,
                    color: isExcluded ? Colors.red[700] : Colors.grey[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isExcluded)
                isMobile
                    ? Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red[600],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.block,
                          color: Colors.white,
                          size: 16,
                        ),
                      )
                    : Icon(
                        Icons.block,
                        color: Colors.red[600],
                        size: 16,
                      ),
            ],
          ),
        ),
      ),
    );
  }
}
