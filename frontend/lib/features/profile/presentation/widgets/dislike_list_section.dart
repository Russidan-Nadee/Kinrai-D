import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/services/user_service.dart';

class DislikeListSection extends StatefulWidget {
  const DislikeListSection({super.key});

  @override
  State<DislikeListSection> createState() => _DislikeListSectionState();
}

class _DislikeListSectionState extends State<DislikeListSection> {
  final UserService _userService = UserService();
  List<Map<String, dynamic>> _dislikes = [];
  bool _isLoadingDislikes = false;
  bool _isBulkMode = false;
  Set<int> _selectedMenuIds = {};
  bool _showAllDislikes = false;

  @override
  void initState() {
    super.initState();
    _loadDislikes();
  }

  Future<void> _loadDislikes() async {
    setState(() {
      _isLoadingDislikes = true;
    });

    try {
      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      final dislikes = await _userService.getUserDislikes(
        language: languageProvider.currentLanguageCode,
      );

      // Sort dislikes alphabetically by menu name
      dislikes.sort((a, b) {
        // Extract menu names for comparison
        String getMenuName(Map<String, dynamic> dislike) {
          String defaultName = languageProvider.currentLanguageCode == 'en'
              ? 'Unknown Menu'
              : 'เมนูไม่ทราบชื่อ';

          final menuData = dislike['Menu'] as Map<String, dynamic>?;
          if (menuData != null) {
            final translations = menuData['Translations'] as List<dynamic>?;
            if (translations != null && translations.isNotEmpty) {
              final translation = translations.first as Map<String, dynamic>;
              return translation['name'] as String? ?? defaultName;
            }
          }
          return defaultName;
        }

        final nameA = getMenuName(a);
        final nameB = getMenuName(b);

        // Compare using locale-aware comparison for proper Thai/English sorting
        return nameA.toLowerCase().compareTo(nameB.toLowerCase());
      });

      if (mounted) {
        setState(() {
          _dislikes = dislikes;
        });
      }
    } catch (e) {
      // Handle error silently for now
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDislikes = false;
        });
      }
    }
  }

  Future<void> _removeDislike(int menuId) async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    try {
      await _userService.removeDislike(menuId: menuId);
      await _loadDislikes(); // Reload the list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              languageProvider.currentLanguageCode == 'en'
                  ? 'Removed from dislike list'
                  : 'ลบออกจากรายการไม่ชอบแล้ว',
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

  void _toggleBulkMode() {
    setState(() {
      _isBulkMode = !_isBulkMode;
      if (!_isBulkMode) {
        _selectedMenuIds.clear();
      }
    });
  }

  void _toggleMenuSelection(int menuId) {
    setState(() {
      if (_selectedMenuIds.contains(menuId)) {
        _selectedMenuIds.remove(menuId);
      } else {
        _selectedMenuIds.add(menuId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedMenuIds = _dislikes.map((d) => d['menu_id'] as int).toSet();
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedMenuIds.clear();
    });
  }

  Future<void> _removeBulkDislikes() async {
    if (_selectedMenuIds.isEmpty) return;

    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    final removedCount = _selectedMenuIds.length; // Store count before clearing

    try {
      await _userService.removeBulkDislikes(menuIds: _selectedMenuIds.toList());
      await _loadDislikes(); // Reload the list
      setState(() {
        _selectedMenuIds.clear();
        _isBulkMode = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              languageProvider.currentLanguageCode == 'en'
                  ? 'Removed $removedCount items from dislike list'
                  : 'ลบรายการที่ไม่ชอบ $removedCount รายการแล้ว',
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.thumb_down_outlined,
              color: Colors.red[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              languageProvider.currentLanguageCode == 'en'
                  ? 'Dislike List'
                  : 'รายการที่ไม่ชอบ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const Spacer(),
            if (_dislikes.isNotEmpty) ...[
              if (!_isBulkMode)
                TextButton.icon(
                  onPressed: _toggleBulkMode,
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(
                    languageProvider.currentLanguageCode == 'en'
                        ? 'Select'
                        : 'เลือก',
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue[600],
                  ),
                )
              else ...[
                TextButton(
                  onPressed: _deselectAll,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                  child: Text(
                    languageProvider.currentLanguageCode == 'en'
                        ? 'Deselect All'
                        : 'ยกเลิกทั้งหมด',
                  ),
                ),
                TextButton(
                  onPressed: _selectAll,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue[600],
                  ),
                  child: Text(
                    languageProvider.currentLanguageCode == 'en'
                        ? 'Select All'
                        : 'เลือกทั้งหมด',
                  ),
                ),
              ],
            ],
          ],
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
          child: _isLoadingDislikes
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                )
              : _dislikes.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.sentiment_satisfied,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          languageProvider.currentLanguageCode == 'en'
                              ? 'No dislikes yet'
                              : 'ยังไม่มีรายการที่ไม่ชอบ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    ...(_showAllDislikes ? _dislikes : _dislikes.take(3)).map((dislike) {
                      return _buildDislikeItem(dislike, languageProvider);
                    }),
                    if (_dislikes.length > 3 && !_showAllDislikes) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _showAllDislikes = true;
                            });
                          },
                          icon: const Icon(Icons.expand_more, size: 18),
                          label: Text(
                            languageProvider.currentLanguageCode == 'en'
                                ? 'Show All (${_dislikes.length})'
                                : 'ดูทั้งหมด (${_dislikes.length})',
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue[600],
                          ),
                        ),
                      ),
                    ],
                    if (_dislikes.length > 3 && _showAllDislikes) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _showAllDislikes = false;
                            });
                          },
                          icon: const Icon(Icons.expand_less, size: 18),
                          label: Text(
                            languageProvider.currentLanguageCode == 'en'
                                ? 'Show Less'
                                : 'ย่อเก็บ',
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue[600],
                          ),
                        ),
                      ),
                    ],
                    if (_isBulkMode && _dislikes.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _toggleBulkMode,
                              icon: const Icon(Icons.close, size: 18),
                              label: Text(
                                languageProvider.currentLanguageCode == 'en'
                                    ? 'Cancel'
                                    : 'ยกเลิก',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.grey[700],
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _selectedMenuIds.isNotEmpty ? _removeBulkDislikes : null,
                              icon: const Icon(Icons.delete_sweep, size: 18),
                              label: Text(
                                languageProvider.currentLanguageCode == 'en'
                                    ? 'Remove Selected (${_selectedMenuIds.length})'
                                    : 'ลบที่เลือก (${_selectedMenuIds.length})',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedMenuIds.isNotEmpty ? Colors.red[400] : Colors.grey[300],
                                foregroundColor: Colors.white,
                                elevation: _selectedMenuIds.isNotEmpty ? 2 : 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildDislikeItem(Map<String, dynamic> dislike, LanguageProvider languageProvider) {
    // Extract menu data
    final menuId = dislike['menu_id'] as int;
    final reason = dislike['reason'] as String?;
    final createdAt = dislike['created_at'] as String?;

    // Extract menu data from nested Menu.Translations
    String menuName = languageProvider.currentLanguageCode == 'en'
        ? 'Unknown Menu'
        : 'เมนูไม่ทราบชื่อ';
    String? menuDescription;

    final menuData = dislike['Menu'] as Map<String, dynamic>?;
    if (menuData != null) {
      final translations = menuData['Translations'] as List<dynamic>?;
      if (translations != null && translations.isNotEmpty) {
        final translation = translations.first as Map<String, dynamic>;
        menuName = translation['name'] as String? ?? menuName;
        menuDescription = translation['description'] as String?;
      }
    }

    final isSelected = _selectedMenuIds.contains(menuId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isBulkMode && isSelected ? Colors.blue[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isBulkMode && isSelected ? Colors.blue[300]! : Colors.red[200]!,
          width: _isBulkMode && isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Checkbox for bulk mode
          if (_isBulkMode) ...[
            Checkbox(
              value: isSelected,
              onChanged: (value) => _toggleMenuSelection(menuId),
              activeColor: Colors.blue[600],
            ),
            const SizedBox(width: 8),
          ],
          // Menu icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isBulkMode && isSelected ? Colors.blue[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.restaurant,
              color: _isBulkMode && isSelected ? Colors.blue[600] : Colors.red[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Menu details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menuName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[700],
                  ),
                ),
                if (menuDescription != null && menuDescription.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    menuDescription,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (reason != null && reason.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${languageProvider.currentLanguageCode == 'en' ? 'Reason' : 'เหตุผล'}: $reason',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
                if (createdAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${languageProvider.currentLanguageCode == 'en' ? 'Added on' : 'เพิ่มเมื่อ'}: ${_formatDate(createdAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ],
            ),
          ),

          // Remove button (hidden in bulk mode)
          if (!_isBulkMode)
            IconButton(
              onPressed: () => _removeDislike(menuId),
              icon: Icon(Icons.delete_outline, color: Colors.red[600], size: 20),
              splashRadius: 20,
              tooltip: languageProvider.currentLanguageCode == 'en'
                  ? 'Remove from dislike list'
                  : 'ลบจากรายการไม่ชอบ',
            ),
        ],
      ),
    );
  }
}
