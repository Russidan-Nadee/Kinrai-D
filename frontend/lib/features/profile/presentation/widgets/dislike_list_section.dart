import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../dislikes/domain/entities/dislike_entity.dart';
import '../providers/profile_provider.dart';

class DislikeListSection extends StatefulWidget {
  const DislikeListSection({super.key});

  @override
  State<DislikeListSection> createState() => _DislikeListSectionState();
}

class _DislikeListSectionState extends State<DislikeListSection> {
  bool _isBulkMode = false;
  Set<int> _selectedMenuIds = {};
  bool _showAllDislikes = false;

  Future<void> _handleRemoveDislike(int menuId) async {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

    final success = await profileProvider.removeDislike(menuId, languageProvider.currentLanguageCode);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? (languageProvider.currentLanguageCode == 'en'
                    ? 'Removed from dislike list'
                    : 'ลบออกจากรายการไม่ชอบแล้ว')
                : (languageProvider.currentLanguageCode == 'en'
                    ? 'An error occurred. Please try again'
                    : 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง'),
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
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
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    setState(() {
      _selectedMenuIds = profileProvider.dislikes.map((d) => d.menuId).toSet();
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedMenuIds.clear();
    });
  }

  Future<void> _handleRemoveBulkDislikes() async {
    if (_selectedMenuIds.isEmpty) return;

    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final removedCount = _selectedMenuIds.length;

    final success = await profileProvider.removeBulkDislikes(
      _selectedMenuIds.toList(),
      languageProvider.currentLanguageCode,
    );

    if (success) {
      setState(() {
        _selectedMenuIds.clear();
        _isBulkMode = false;
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? (languageProvider.currentLanguageCode == 'en'
                    ? 'Removed $removedCount items from dislike list'
                    : 'ลบรายการที่ไม่ชอบ $removedCount รายการแล้ว')
                : (languageProvider.currentLanguageCode == 'en'
                    ? 'An error occurred. Please try again'
                    : 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง'),
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final dislikes = profileProvider.dislikes;
    final isLoadingDislikes = profileProvider.isLoadingDislikes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.thumb_down_outlined, color: Colors.red[600], size: 20),
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
            if (dislikes.isNotEmpty) ...[
              if (!_isBulkMode)
                TextButton.icon(
                  onPressed: _toggleBulkMode,
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(
                    languageProvider.currentLanguageCode == 'en' ? 'Select' : 'เลือก',
                  ),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue[600]),
                )
              else ...[
                TextButton(
                  onPressed: _deselectAll,
                  style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                  child: Text(
                    languageProvider.currentLanguageCode == 'en'
                        ? 'Deselect All'
                        : 'ยกเลิกทั้งหมด',
                  ),
                ),
                TextButton(
                  onPressed: _selectAll,
                  style: TextButton.styleFrom(foregroundColor: Colors.blue[600]),
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
          child: isLoadingDislikes && dislikes.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
                  ),
                )
              : dislikes.isEmpty && !isLoadingDislikes
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(Icons.sentiment_satisfied, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              languageProvider.currentLanguageCode == 'en'
                                  ? 'No dislikes yet'
                                  : 'ยังไม่มีรายการที่ไม่ชอบ',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        ...(_showAllDislikes ? dislikes : dislikes.take(3)).map((dislike) {
                          return KeyedSubtree(
                            key: ValueKey(dislike.menuId),
                            child: _buildDislikeItem(dislike, languageProvider),
                          );
                        }),
                        if (dislikes.length > 3 && !_showAllDislikes) ...[
                          const SizedBox(height: 12),
                          Center(
                            child: TextButton.icon(
                              onPressed: () => setState(() => _showAllDislikes = true),
                              icon: const Icon(Icons.expand_more, size: 18),
                              label: Text(
                                languageProvider.currentLanguageCode == 'en'
                                    ? 'Show All (${dislikes.length})'
                                    : 'ดูทั้งหมด (${dislikes.length})',
                              ),
                              style: TextButton.styleFrom(foregroundColor: Colors.blue[600]),
                            ),
                          ),
                        ],
                        if (dislikes.length > 3 && _showAllDislikes) ...[
                          const SizedBox(height: 12),
                          Center(
                            child: TextButton.icon(
                              onPressed: () => setState(() => _showAllDislikes = false),
                              icon: const Icon(Icons.expand_less, size: 18),
                              label: Text(
                                languageProvider.currentLanguageCode == 'en'
                                    ? 'Show Less'
                                    : 'ย่อเก็บ',
                              ),
                              style: TextButton.styleFrom(foregroundColor: Colors.blue[600]),
                            ),
                          ),
                        ],
                        if (_isBulkMode && dislikes.isNotEmpty) ...[
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
                                  onPressed: _selectedMenuIds.isNotEmpty
                                      ? _handleRemoveBulkDislikes
                                      : null,
                                  icon: const Icon(Icons.delete_sweep, size: 18),
                                  label: Text(
                                    languageProvider.currentLanguageCode == 'en'
                                        ? 'Remove Selected (${_selectedMenuIds.length})'
                                        : 'ลบที่เลือก (${_selectedMenuIds.length})',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _selectedMenuIds.isNotEmpty
                                        ? Colors.red[400]
                                        : Colors.grey[300],
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

  Widget _buildDislikeItem(DislikeEntity dislike, LanguageProvider languageProvider) {
    final isSelected = _selectedMenuIds.contains(dislike.menuId);

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
          if (_isBulkMode) ...[
            Checkbox(
              value: isSelected,
              onChanged: (value) => _toggleMenuSelection(dislike.menuId),
              activeColor: Colors.blue[600],
            ),
            const SizedBox(width: 8),
          ],
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dislike.menuName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[700],
                  ),
                ),
                if (dislike.menuDescription != null && dislike.menuDescription!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    dislike.menuDescription!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (dislike.reason != null && dislike.reason!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${languageProvider.currentLanguageCode == 'en' ? 'Reason' : 'เหตุผล'}: ${dislike.reason}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '${languageProvider.currentLanguageCode == 'en' ? 'Added on' : 'เพิ่มเมื่อ'}: ${_formatDate(dislike.createdAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          if (!_isBulkMode)
            IconButton(
              onPressed: () => _handleRemoveDislike(dislike.menuId),
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
