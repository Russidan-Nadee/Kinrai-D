import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/menu_model.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/utils/logger.dart';

class RandomMenuCard extends StatefulWidget {
  final MenuModel menu;
  final VoidCallback? onDisliked;

  const RandomMenuCard({
    super.key,
    required this.menu,
    this.onDisliked,
  });

  @override
  State<RandomMenuCard> createState() => _RandomMenuCardState();
}

class _RandomMenuCardState extends State<RandomMenuCard> {
  final UserService _userService = UserService();
  bool _isDisliked = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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
      final isDisliked = await _userService.isMenuDisliked(widget.menu.id);
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
        await _userService.removeDislike(menuId: widget.menu.id);
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
        await _userService.addDislike(menuId: widget.menu.id);
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

    return Center(
      child: SizedBox(
        width: 320,
        child: Card(
          elevation: 8,
          shadowColor: const Color(0xFFFF6B35).withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.orange[50]!],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Menu Image
                  if (widget.menu.imageUrl != null) ...[
                    Hero(
                      tag: 'menu-${widget.menu.key}',
                      child: Container(
                        width: 250,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            widget.menu.imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Colors.grey[200]!, Colors.grey[300]!],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.restaurant,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Menu Name
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.menu.getName(language: languageProvider.currentLanguageCode),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B35),
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Meal time indicator
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getMealTimeIcon(widget.menu.mealTime),
                          size: 16,
                          color: const Color(0xFFFF6B35),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getMealTimeText(
                            widget.menu.mealTime,
                            languageProvider.currentLanguageCode,
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF6B35),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dislike button
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
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
                            _isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
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
                      elevation: _isDisliked ? 2 : 4,
                      shadowColor: _isDisliked
                          ? Colors.grey.withValues(alpha: 0.3)
                          : Colors.red.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getMealTimeIcon(String? mealTime) {
    switch (mealTime?.toLowerCase()) {
      case 'breakfast':
        return Icons.wb_sunny;
      case 'lunch':
        return Icons.wb_sunny_outlined;
      case 'dinner':
        return Icons.nights_stay;
      default:
        return Icons.restaurant;
    }
  }

  String _getMealTimeText(String? mealTime, String languageCode) {
    switch (mealTime?.toLowerCase()) {
      case 'breakfast':
        switch (languageCode) {
          case 'en':
            return 'Breakfast';
          case 'ja':
            return '朝食';
          case 'zh':
            return '早餐';
          default:
            return 'มื้อเช้า';
        }
      case 'lunch':
        switch (languageCode) {
          case 'en':
            return 'Lunch';
          case 'ja':
            return '昼食';
          case 'zh':
            return '午餐';
          default:
            return 'มื้อกลางวัน';
        }
      case 'dinner':
        switch (languageCode) {
          case 'en':
            return 'Dinner';
          case 'ja':
            return '夕食';
          case 'zh':
            return '晚餐';
          default:
            return 'มื้อเย็น';
        }
      default:
        switch (languageCode) {
          case 'en':
            return 'Any time';
          case 'ja':
            return 'いつでも';
          case 'zh':
            return '随时';
          default:
            return 'ทุกเวลา';
        }
    }
  }
}