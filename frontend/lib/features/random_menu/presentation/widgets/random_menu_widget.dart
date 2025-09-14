import 'package:flutter/material.dart';
import '../../../../core/models/menu_model.dart';
import '../../../../core/services/menu_service.dart';
import 'random_menu_button.dart';
import 'random_menu_card.dart';

class RandomMenuWidget extends StatefulWidget {
  const RandomMenuWidget({super.key});

  @override
  State<RandomMenuWidget> createState() => _RandomMenuWidgetState();
}

class _RandomMenuWidgetState extends State<RandomMenuWidget> {
  final MenuService _menuService = MenuService();
  MenuModel? _randomMenu;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _getRandomMenu() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final randomMenu = await _menuService.getRandomMenu(language: 'th');
      setState(() {
        _randomMenu = randomMenu;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'ไม่สามารถสุ่มเมนูได้ กรุณาลองใหม่อีกครั้ง';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title
        Text(
          'กดปุ่มเพื่อสุ่มเมนูอาหารแสนอร่อย',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),

        // Random Menu Button
        RandomMenuButton(
          isLoading: _isLoading,
          onPressed: _getRandomMenu,
        ),

        const SizedBox(height: 48),

        // Display result
        if (_errorMessage != null)
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
          RandomMenuCard(menu: _randomMenu!),
      ],
    );
  }
}