import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/utils/logger.dart';

class SubcategoryTranslation {
  String language;
  String name;
  String description;

  SubcategoryTranslation({
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

class CategoryOption {
  final int id;
  final String key;
  final String name;
  final int foodTypeId;

  CategoryOption({
    required this.id,
    required this.key,
    required this.name,
    required this.foodTypeId,
  });

  factory CategoryOption.fromJson(Map<String, dynamic> json) {
    return CategoryOption(
      id: json['id'],
      key: json['key'],
      name: json['Translations']?.isNotEmpty == true 
          ? json['Translations'][0]['name'] 
          : json['key'],
      foodTypeId: json['food_type_id'],
    );
  }
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

class AddSubcategoryDialog extends StatefulWidget {
  const AddSubcategoryDialog({super.key});

  @override
  State<AddSubcategoryDialog> createState() => _AddSubcategoryDialogState();
}

class _AddSubcategoryDialogState extends State<AddSubcategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _keyController = TextEditingController();
  
  String? _selectedFoodTypeKey;
  String? _selectedCategoryKey;
  List<FoodTypeOption> _foodTypes = [];
  List<CategoryOption> _categories = [];
  bool _isLoadingData = false;
  
  final List<SubcategoryTranslation> _translations = [
    SubcategoryTranslation(language: 'en', name: ''),
    SubcategoryTranslation(language: 'th', name: ''),
    SubcategoryTranslation(language: 'jp', name: ''),
    SubcategoryTranslation(language: 'zh', name: ''),
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
        Uri.parse('http://localhost:8000/api/v1/food-types?lang=en'),
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

  Future<void> _loadCategories(String foodTypeKey) async {
    if (foodTypeKey.isEmpty) return;
    
    try {
      final foodType = _foodTypes.firstWhere((ft) => ft.key == foodTypeKey);
      
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/v1/categories/food-type/${foodType.id}?lang=en'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> categoriesData = data['data'];
        
        setState(() {
          _categories = categoriesData.map((item) => CategoryOption.fromJson(item)).toList();
          _selectedCategoryKey = null;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading categories', e);
    }
  }

  Map<String, dynamic> _getSubcategoryData() {
    final selectedCategory = _categories.firstWhere((c) => c.key == _selectedCategoryKey);
    
    return {
      'category_id': selectedCategory.id,
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
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add New Subcategory',
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
                                if (newValue != null) {
                                  _loadCategories(newValue);
                                }
                              },
                            ),
                      const SizedBox(height: 16),
                      
                      // Category Selection
                      DropdownButtonFormField<String>(
                        value: _selectedCategoryKey,
                        decoration: const InputDecoration(
                          labelText: 'Category*',
                          border: OutlineInputBorder(),
                        ),
                        hint: const Text('Select category'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Category is required';
                          }
                          return null;
                        },
                        items: _categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category.key,
                            child: Text(
                              '${category.key} - ${category.name}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }).toList(),
                        onChanged: _selectedFoodTypeKey == null 
                            ? null 
                            : (String? newValue) {
                                setState(() {
                                  _selectedCategoryKey = newValue;
                                });
                              },
                      ),
                      const SizedBox(height: 16),
                      
                      // Key Field
                      TextFormField(
                        controller: _keyController,
                        decoration: const InputDecoration(
                          labelText: 'Subcategory Key*',
                          hintText: 'e.g., pad_thai',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Subcategory key is required';
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
                      final subcategoryData = _getSubcategoryData();
                      Navigator.of(context).pop(subcategoryData);
                    }
                  },
                  child: const Text('Create Subcategory'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}