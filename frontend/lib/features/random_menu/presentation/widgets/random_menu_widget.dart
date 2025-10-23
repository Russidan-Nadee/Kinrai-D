import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/usecases/get_personalized_random_menu.dart';
import 'random_menu_button.dart';
import 'random_menu_card.dart';

class RandomMenuWidget extends StatefulWidget {
  const RandomMenuWidget({super.key});

  @override
  State<RandomMenuWidget> createState() => _RandomMenuWidgetState();
}

class _RandomMenuWidgetState extends State<RandomMenuWidget> {
  late final GetPersonalizedRandomMenu _getPersonalizedRandomMenu;
  MenuEntity? _randomMenu;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Get use case from dependency injection
    _getPersonalizedRandomMenu = getIt.get<GetPersonalizedRandomMenu>();
  }

  Future<void> _getRandomMenu() async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final randomMenu = await _getPersonalizedRandomMenu(
        language: languageProvider.currentLanguageCode,
      );
      setState(() {
        _randomMenu = randomMenu;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = l10n.cannotRandomMenu;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Show button in center when no menu is displayed (and not loading from previous state)
    if (_randomMenu == null && _errorMessage == null && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              l10n.tapToRandomMenu,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Random Menu Button (centered)
            RandomMenuButton(
              isLoading: _isLoading,
              onPressed: _getRandomMenu,
            ),
          ],
        ),
      );
    }

    // After menu is displayed (or loading from previous state), show card at top and button at bottom
    return Column(
      children: [
        // Top section with card (1/2) - card centered in this area
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading && _randomMenu == null)
                // Show loading indicator when loading for the first time
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      l10n.tapToRandomMenu,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                )
              else if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[600]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[600]),
                        ),
                      ),
                    ],
                  ),
                )
              else if (_randomMenu != null)
                RandomMenuCard(
                  key: ValueKey(_randomMenu!.id),
                  menu: _randomMenu!,
                  onDisliked: () {
                    // Optional: Auto-generate new menu after dislike
                    _getRandomMenu();
                  },
                ),
            ],
          ),
        ),

        // Bottom section with button (1/2) - button centered in this area
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RandomMenuButton(
                isLoading: _isLoading,
                onPressed: _getRandomMenu,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
