import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/menu_entity.dart';
import '../../../dislikes/domain/usecases/add_dislike.dart';
import '../../../dislikes/domain/usecases/remove_dislike.dart';
import '../../../dislikes/domain/usecases/is_menu_disliked.dart';

class RandomMenuCard extends StatefulWidget {
  final MenuEntity menu;
  final VoidCallback? onDisliked;

  const RandomMenuCard({super.key, required this.menu, this.onDisliked});

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
    // Get use cases from dependency injection
    _addDislike = getIt.get<AddDislike>();
    _removeDislike = getIt.get<RemoveDislike>();
    _isMenuDisliked = getIt.get<IsMenuDisliked>();

    _checkIfDisliked();
  }

  @override
  void didUpdateWidget(RandomMenuCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if menu changed, then refresh dislike status
    if (oldWidget.menu.id != widget.menu.id) {
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
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isDisliked) {
        await _removeDislike(menuId: widget.menu.id);
        setState(() {
          _isDisliked = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ลบออกจากรายการไม่ชอบแล้ว'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await _addDislike(menuId: widget.menu.id);
        setState(() {
          _isDisliked = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('เพิ่มในรายการไม่ชอบแล้ว'),
              backgroundColor: Colors.orange,
            ),
          );
          widget.onDisliked?.call();
        }
      }
    } catch (e) {
      AppLogger.error('[RandomMenuCard] Failed to toggle dislike', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
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
                    _getMealTimeText(
                      mealTime,
                      languageProvider.currentLanguageCode,
                    ),
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
                    const Text(
                      'Active',
                      style: TextStyle(
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
                    '$contains ingredients',
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
                      _isDisliked
                          ? (languageProvider.currentLanguageCode == 'en'
                                ? 'Disliked'
                                : 'ไม่ชอบแล้ว')
                          : (languageProvider.currentLanguageCode == 'en'
                                ? 'Dislike'
                                : 'ไม่ชอบ'),
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

  String _getMealTimeText(String mealTime, String languageCode) {
    switch (mealTime.toUpperCase()) {
      case 'BREAKFAST':
        switch (languageCode) {
          case 'en':
            return 'BREAKFAST';
          case 'ja':
            return '朝食';
          case 'zh':
            return '早餐';
          default:
            return 'BREAKFAST';
        }
      case 'LUNCH':
        switch (languageCode) {
          case 'en':
            return 'LUNCH';
          case 'ja':
            return '昼食';
          case 'zh':
            return '午餐';
          default:
            return 'LUNCH';
        }
      case 'DINNER':
        switch (languageCode) {
          case 'en':
            return 'DINNER';
          case 'ja':
            return '夕食';
          case 'zh':
            return '晚餐';
          default:
            return 'DINNER';
        }
      default:
        return mealTime;
    }
  }
}
