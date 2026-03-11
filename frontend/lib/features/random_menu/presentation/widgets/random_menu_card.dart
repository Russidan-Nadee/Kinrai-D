import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/cache/cache_service.dart';
import '../../domain/entities/menu_entity.dart';
import '../../../dislikes/domain/usecases/add_dislike.dart';
import '../../../dislikes/domain/usecases/remove_dislike.dart';
import '../../../dislikes/domain/usecases/is_menu_disliked.dart';
import '../../../dislikes/presentation/providers/dislike_provider.dart';

class RandomMenuCard extends StatefulWidget {
  final MenuEntity menu;
  final VoidCallback? onDisliked;
  final bool isGuest;

  const RandomMenuCard({
    super.key,
    required this.menu,
    this.onDisliked,
    this.isGuest = false,
  });

  @override
  State<RandomMenuCard> createState() => _RandomMenuCardState();
}

class _RandomMenuCardState extends State<RandomMenuCard> {
  late final AddDislike _addDislike;
  late final RemoveDislike _removeDislike;
  late final IsMenuDisliked _isMenuDisliked;

  bool _isDisliked = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addDislike = getIt.get<AddDislike>();
    _removeDislike = getIt.get<RemoveDislike>();
    _isMenuDisliked = getIt.get<IsMenuDisliked>();

    if (!widget.isGuest) _checkIfDisliked();
  }

  @override
  void didUpdateWidget(RandomMenuCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isGuest && oldWidget.menu.id != widget.menu.id) {
      _checkIfDisliked();
    }
  }

  Future<void> _checkIfDisliked() async {
    try {
      final isDisliked = await _isMenuDisliked(widget.menu.id);
      if (mounted) {
        setState(() {
          _isDisliked = isDisliked;
        });
      }
    } catch (e) {
      AppLogger.error('[RandomMenuCard] Failed to check dislike status', e);
    }
  }

  Future<void> _toggleDislike() async {
    if (widget.isGuest) {
      _showAuthRequiredDialog();
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Get providers and context before async gap
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);

    // Try to get DislikeProvider if it exists (it might not be provided in all contexts)
    DislikeProvider? dislikeProvider;
    try {
      dislikeProvider = Provider.of<DislikeProvider>(context, listen: false);
    } catch (e) {
      AppLogger.info('[RandomMenuCard] DislikeProvider not available in this context');
    }

    try {
      if (_isDisliked) {
        await _removeDislike(menuId: widget.menu.id);
        if (mounted) {
          setState(() {
            _isDisliked = false;
            _isLoading = false;
          });

          // Wait a bit for cache to be cleared, then refresh ProfileProvider
          if (dislikeProvider != null) {
            // Clear cache first to ensure fresh data
            await CacheService.clearDislikes();

            // Small delay to ensure cache is cleared
            await Future.delayed(const Duration(milliseconds: 100));

            // Now refresh the dislike data
            dislikeProvider.loadDislikes(
              language: languageProvider.currentLanguageCode,
            ).catchError((error) {
              AppLogger.error('[RandomMenuCard] Failed to refresh dislike data', error);
            });
          }

          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(l10n.dislikeRemoved),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await _addDislike(menuId: widget.menu.id);
        if (mounted) {
          setState(() {
            _isDisliked = true;
            _isLoading = false;
          });

          // Wait a bit for cache to be cleared, then refresh ProfileProvider
          if (dislikeProvider != null) {
            // Clear cache first to ensure fresh data
            await CacheService.clearDislikes();

            // Small delay to ensure cache is cleared
            await Future.delayed(const Duration(milliseconds: 100));

            // Now refresh the dislike data
            dislikeProvider.loadDislikes(
              language: languageProvider.currentLanguageCode,
            ).catchError((error) {
              AppLogger.error('[RandomMenuCard] Failed to refresh dislike data', error);
            });
          }

          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(l10n.dislikeAdded),
              backgroundColor: Colors.orange,
            ),
          );
          widget.onDisliked?.call();
        }
      }
    } catch (e) {
      AppLogger.error('[RandomMenuCard] Failed to toggle dislike', e);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(l10n.errorOccurred),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAuthRequiredDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.lock_outline, size: 22),
            const SizedBox(width: 8),
            Text(l10n.loginRequired, style: const TextStyle(fontSize: 18)),
          ],
        ),
        content: Text(l10n.loginRequiredMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              authProvider.exitGuestMode();
            },
            child: Text(l10n.signInOrSignUp,
                style: const TextStyle(color: Color(0xFFFF6B35))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final menuName = widget.menu.name;
    final mealTime = widget.menu.mealTime;
    final contains = widget.menu.contains?.length ?? 0;

    return Center(
      child: SizedBox(
        width: 320,
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Menu Name
                Text(
                  menuName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Meal Time
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getMealTimeColor(mealTime),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getMealTimeL10n(mealTime, l10n),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Status - Always active for random menus
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.active,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Contains count
                if (contains > 0)
                  Text(
                    l10n.ingredientsCount(contains),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),

                const SizedBox(height: 12),

                // Dislike button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _toggleDislike,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            _isDisliked
                                ? Icons.thumb_down
                                : Icons.thumb_down_outlined,
                            size: 18,
                          ),
                    label: Text(
                      _isDisliked ? l10n.disliked : l10n.dislike,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isDisliked
                          ? Colors.grey[600]
                          : Colors.red[400],
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getMealTimeColor(String mealTime) {
    switch (mealTime.toUpperCase()) {
      case 'BREAKFAST':
        return Colors.orange;
      case 'LUNCH':
        return Colors.blue;
      case 'DINNER':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getMealTimeL10n(String mealTime, AppLocalizations l10n) {
    switch (mealTime.toUpperCase()) {
      case 'BREAKFAST':
        return l10n.mealTimeBreakfast;
      case 'LUNCH':
        return l10n.mealTimeLunch;
      case 'DINNER':
        return l10n.mealTimeDinner;
      case 'SNACK':
        return l10n.mealTimeSnack;
      default:
        return mealTime;
    }
  }
}
