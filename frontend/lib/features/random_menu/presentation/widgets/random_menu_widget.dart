import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/usecases/get_personalized_random_menu.dart';
import 'random_menu_button.dart';
import 'random_menu_card.dart';
import 'dice_animation.dart';

class RandomMenuWidget extends StatefulWidget {
  const RandomMenuWidget({super.key});

  @override
  State<RandomMenuWidget> createState() => _RandomMenuWidgetState();
}

class _RandomMenuWidgetState extends State<RandomMenuWidget>
    with SingleTickerProviderStateMixin {
  late final GetPersonalizedRandomMenu _getPersonalizedRandomMenu;
  MenuEntity? _randomMenu;
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Get use case from dependency injection
    _getPersonalizedRandomMenu = getIt.get<GetPersonalizedRandomMenu>();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getRandomMenu() async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Run API call and minimum loading time in parallel
      final results = await Future.wait([
        _getPersonalizedRandomMenu(
          language: languageProvider.currentLanguageCode,
        ),
        Future.delayed(const Duration(milliseconds: 1000)), // Minimum 1 second to see dice
      ]);

      final randomMenu = results[0] as MenuEntity;

      if (mounted) {
        setState(() {
          _randomMenu = randomMenu;
          _isLoading = false;
        });
        // Start animation when menu is loaded
        _animationController.forward(from: 0.0);
      }
    } catch (e) {
      if (mounted) {
        // Still wait minimum time even on error
        await Future.delayed(const Duration(milliseconds: 1000));
        setState(() {
          _errorMessage = l10n.cannotRandomMenu;
          _isLoading = false;
        });
        // Start animation even on error
        _animationController.forward(from: 0.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Show button when no menu is displayed and not loading
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
              isLoading: false,
              onPressed: _getRandomMenu,
            ),
          ],
        ),
      );
    }

    // When loading with existing menu, show only dice animation centered
    if (_isLoading) {
      return const Center(
        child: DiceAnimation(
          size: 200,
        ),
      );
    }

    // After menu is displayed or when error, show card at top and button at bottom
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Column(
          children: [
            // Top section with card/error (1/2) - centered in this area
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: Offset(0, -20 * (1 - _fadeAnimation.value)),
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 800),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          // 3D Card Flip Animation
                          final rotateAnimation = Tween<double>(
                            begin: math.pi / 2, // Start rotated 90 degrees (invisible)
                            end: 0.0, // End at 0 degrees (fully visible)
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutBack,
                            ),
                          );

                          return AnimatedBuilder(
                            animation: rotateAnimation,
                            child: child,
                            builder: (context, child) {
                              // Apply 3D perspective transformation
                              final transform = Matrix4.identity()
                                ..setEntry(3, 2, 0.001) // Add perspective
                                ..rotateY(rotateAnimation.value); // Rotate around Y-axis

                              return Transform(
                                transform: transform,
                                alignment: Alignment.center,
                                child: child,
                              );
                            },
                          );
                        },
                        child: _errorMessage != null
                            ? Center(
                                key: const ValueKey('error'),
                                child: Container(
                                  width: 320,
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
                                ),
                              )
                            : _randomMenu != null
                                ? RandomMenuCard(
                                    key: ValueKey('card_${_randomMenu!.id}'),
                                    menu: _randomMenu!,
                                    onDisliked: () {
                                      // Optional: Auto-generate new menu after dislike
                                      _getRandomMenu();
                                    },
                                  )
                                : const SizedBox.shrink(key: ValueKey('empty')),
                      ),
                    ),
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
                  Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: RandomMenuButton(
                        isLoading: false,
                        onPressed: _getRandomMenu,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
