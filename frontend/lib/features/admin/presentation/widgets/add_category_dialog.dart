import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/constants.dart';

class CategoryTranslation {
  String language;
  String name;
  String description;

  CategoryTranslation({
    required this.language,
    required this.name,
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
    'language': language,
    'name': name,
    'description': description,
  };
}

class FoodTypeOption {
  final int id;
  final String key;
  final String name;

  FoodTypeOption({
    required this.id,
    required this.key,
    required this.name,
  });

  factory FoodTypeOption.fromJson(Map<String, dynamic> json) {
    return FoodTypeOption(
      id: json['id'],
      key: json['key'],
      name: json['Translations']?.isNotEmpty == true 
          ? json['Translations'][0]['name'] 
          : json['key'],
    );
  }
}

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _keyController = TextEditingController();
  
  String? _selectedFoodTypeKey;
  List<FoodTypeOption> _foodTypes = [];
  bool _isLoadingData = false;
  
  final List<CategoryTranslation> _translations = [
    CategoryTranslation(language: 'en', name: ''),
    CategoryTranslation(language: 'th', name: ''),
    CategoryTranslation(language: 'jp', name: ''),
    CategoryTranslation(language: 'zh', name: ''),
  ];

  final Map<String, String> _languageNames = {
    'en': 'English',
    'th': 'Thai (ไทย)',
    'jp': 'Japanese (日本語)',
    'zh': 'Chinese (中文)',
  };

  @override
  void initState() {
    super.initState();
    _loadFoodTypes();
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _loadFoodTypes() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.apiVersion}/food-types?lang=en'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> foodTypesData = data['data'];
        
        setState(() {
          _foodTypes = foodTypesData.map((item) => FoodTypeOption.fromJson(item)).toList();
        });
      }
    } catch (e) {
      AppLogger.error('Error loading food types', e);
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  Map<String, dynamic> _getCategoryData() {
    final selectedFoodType = _foodTypes.firstWhere((ft) => ft.key == _selectedFoodTypeKey);
    
    return {
      'food_type_id': selectedFoodType.id,
      'key': _keyController.text,
      'is_active': true,
      'translations': _translations.map((t) => t.toJson()).toList(),
    };
  }

  Color _getLanguageColor(String language) {
    switch (language) {
      case 'en':
        return Colors.blue;
      case 'th':
        return Colors.red;
      case 'jp':
        return Colors.purple;
      case 'zh':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add New Category',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Food Type Selection
                      _isLoadingData
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<String>(
                              value: _selectedFoodTypeKey,
                              decoration: const InputDecoration(
                                labelText: 'Food Type*',
                                border: OutlineInputBorder(),
                              ),
                              hint: const Text('Select food type'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Food type is required';
                                }
                                return null;
                              },
                              items: _foodTypes.map((foodType) {
                                return DropdownMenuItem<String>(
                                  value: foodType.key,
                                  child: Text(
                                    '${foodType.key} - ${foodType.name}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedFoodTypeKey = newValue;
                                });
                              },
                            ),
                      const SizedBox(height: 16),
                      
                      // Key Field
                      TextFormField(
                        controller: _keyController,
                        decoration: const InputDecoration(
                          labelText: 'Category Key*',
                          hintText: 'e.g., curry',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Category key is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      
                      // Translations Section
                      const Text(
                        'Translations (All 4 languages required)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Translation Forms
                      ...List.generate(_translations.length, (index) {
                        final language = _translations[index].language;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Language Header
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12, 
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getLanguageColor(language),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    _languageNames[language] ?? language.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Name Field
                                TextFormField(
                                  initialValue: _translations[index].name,
                                  decoration: InputDecoration(
                                    labelText: 'Name* (${language.toUpperCase()})',
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Name in ${_languageNames[language]} is required';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    _translations[index].name = value;
                                  },
                                ),
                                const SizedBox(height: 16),
                                
                                // Description Field
                                TextFormField(
                                  initialValue: _translations[index].description,
                                  decoration: InputDecoration(
                                    labelText: 'Description (${language.toUpperCase()})',
                                    border: const OutlineInputBorder(),
                                  ),
                                  maxLines: 2,
                                  onChanged: (value) {
                                    _translations[index].description = value;
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      final categoryData = _getCategoryData();
                      Navigator.of(context).pop(categoryData);
                    }
                  },
                  child: const Text('Create Category'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}