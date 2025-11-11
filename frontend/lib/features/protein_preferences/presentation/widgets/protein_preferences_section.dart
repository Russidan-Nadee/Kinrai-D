import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../domain/entities/protein_preference_entity.dart';
import '../providers/protein_preference_provider.dart';

class ProteinPreferencesSection extends StatefulWidget {
  const ProteinPreferencesSection({super.key});

  @override
  State<ProteinPreferencesSection> createState() => _ProteinPreferencesSectionState();
}

class _ProteinPreferencesSectionState extends State<ProteinPreferencesSection> {
  String? _previousLanguage;

  Future<void> _toggleProteinPreference(
    BuildContext context,
    int proteinTypeId,
    bool exclude,
  ) async {
    final proteinProvider = Provider.of<ProteinPreferenceProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context);

    final success = await proteinProvider.toggleProteinPreference(
      proteinTypeId,
      exclude,
      languageProvider.currentLanguageCode,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? l10n.proteinPreferenceUpdated : l10n.errorOccurred,
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final proteinProvider = Provider.of<ProteinPreferenceProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations.of(context);

    // Auto-reload when language changes
    final currentLanguage = languageProvider.currentLanguageCode;
    if (_previousLanguage != null && _previousLanguage != currentLanguage) {
      // Language changed - reload data with new language
      WidgetsBinding.instance.addPostFrameCallback((_) {
        proteinProvider.loadProteinPreferences(language: currentLanguage);
      });
    }
    _previousLanguage = currentLanguage;

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
              l10n.proteinPreferences,
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
          l10n.manageProteinPreferences,
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
          child: proteinProvider.availableProteinTypes.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      l10n.noProteinTypesAvailable,
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
                    if (proteinProvider.userProteinPreferences.isNotEmpty) ...[
                      Text(
                        l10n.dontEat,
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
                        children: proteinProvider.userProteinPreferences.map((pref) {
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
                    _buildProteinGrid(context, languageProvider),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildProteinGrid(BuildContext context, LanguageProvider languageProvider) {
    final proteinProvider = Provider.of<ProteinPreferenceProvider>(context, listen: false);

    return LayoutBuilder(
      builder: (builderContext, constraints) {
        // Calculate how many columns can fit
        double itemWidth = 280; // Minimum width for each item
        int crossAxisCount = (constraints.maxWidth / itemWidth).floor();
        crossAxisCount = crossAxisCount < 1 ? 1 : crossAxisCount;

        // If screen is very narrow (mobile), use single column
        if (constraints.maxWidth < 500) {
          return Column(
            children: proteinProvider.availableProteinTypes.map((proteinType) {
              return _buildProteinItem(context, proteinType, languageProvider, true);
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
          itemCount: proteinProvider.availableProteinTypes.length,
          itemBuilder: (gridContext, index) {
            return _buildProteinItem(context, proteinProvider.availableProteinTypes[index], languageProvider, false);
          },
        );
      },
    );
  }

  Widget _buildProteinItem(BuildContext context, ProteinTypeEntity proteinType, LanguageProvider languageProvider, bool isMobile) {
    final proteinProvider = Provider.of<ProteinPreferenceProvider>(context, listen: false);
    final isExcluded = proteinProvider.isProteinExcluded(proteinType.id);

    return Container(
      width: isMobile ? double.infinity : null,
      margin: isMobile ? const EdgeInsets.only(bottom: 8) : EdgeInsets.zero,
      child: InkWell(
        onTap: () => _toggleProteinPreference(context, proteinType.id, !isExcluded),
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
