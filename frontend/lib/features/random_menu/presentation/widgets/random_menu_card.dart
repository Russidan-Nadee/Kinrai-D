import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/menu_model.dart';
import '../../../../core/providers/language_provider.dart';

class RandomMenuCard extends StatelessWidget {
  final MenuModel menu;

  const RandomMenuCard({
    super.key,
    required this.menu,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Card(
      elevation: 8,
      shadowColor: const Color(0xFFFF6B35).withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.orange[50]!,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Menu Image with enhanced styling
              if (menu.imageUrl != null) ...[
                Hero(
                  tag: 'menu-${menu.key}',
                  child: Container(
                    width: 220,
                    height: 220,
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
                        menu.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.grey[200]!,
                                  Colors.grey[300]!,
                                ],
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
                const SizedBox(height: 24),
              ],

              // Menu Name with improved typography
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  menu.getName(language: languageProvider.currentLanguageCode),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B35),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Add meal time indicator
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getMealTimeIcon(menu.mealTime),
                      size: 16,
                      color: const Color(0xFFFF6B35),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getMealTimeText(menu.mealTime, languageProvider.currentLanguageCode),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
          case 'en': return 'Breakfast';
          case 'ja': return '朝食';
          case 'zh': return '早餐';
          default: return 'มื้อเช้า';
        }
      case 'lunch':
        switch (languageCode) {
          case 'en': return 'Lunch';
          case 'ja': return '昼食';
          case 'zh': return '午餐';
          default: return 'มื้อกลางวัน';
        }
      case 'dinner':
        switch (languageCode) {
          case 'en': return 'Dinner';
          case 'ja': return '夕食';
          case 'zh': return '晚餐';
          default: return 'มื้อเย็น';
        }
      default:
        switch (languageCode) {
          case 'en': return 'Any time';
          case 'ja': return 'いつでも';
          case 'zh': return '随时';
          default: return 'ทุกเวลา';
        }
    }
  }

}