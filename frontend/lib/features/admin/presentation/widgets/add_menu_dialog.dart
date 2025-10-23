import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'add_subcategory_dialog.dart';
import '../../../../core/utils/logger.dart';

class DropdownOption {
  final int id;
  final String key;
  final String name;

  DropdownOption({
    required this.id,
    required this.key,
    required this.name,
  });

  factory DropdownOption.fromJson(Map<String, dynamic> json) {
    return DropdownOption(
      id: json['id'],
      key: json['key'],
      name: json['name'] ?? json['key'],
    );
  }
}

class AddMenuDialog extends StatefulWidget {
  const AddMenuDialog({super.key});

  @override
  State<AddMenuDialog> createState() => _AddMenuDialogState();
}

class _AddMenuDialogState extends State<AddMenuDialog> {
  final _formKey = GlobalKey<FormState>();
  final _imageUrlController = TextEditingController();
  final _containsController = TextEditingController();

  String _selectedMealTime = 'LUNCH';
  String? _selectedFoodTypeKey;
  String? _selectedCategoryKey;
  String? _selectedSubcategoryKey;
  String? _selectedProteinTypeKey;

  List<DropdownOption> _foodTypes = [];
  List<DropdownOption> _categories = [];
  List<DropdownOption> _subcategories = [];
  List<DropdownOption> _proteinTypes = [];
  bool _isLoadingData = false;

  final List<String> _mealTimes = ['BREAKFAST', 'LUNCH', 'DINNER', 'SNACK'];

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    _containsController.dispose();
    super.dispose();
  }

  Future<void> _loadDropdownData() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      await Future.wait([
        _loadFoodTypes(),
        _loadProteinTypes(),
      ]);
    } catch (e) {
      AppLogger.error('Error loading dropdown data', e);
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  Future<void> _loadFoodTypes() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/v1/food-types?lang=en'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> foodTypesData = data['data'];
        
        setState(() {
          _foodTypes = foodTypesData.map((item) => DropdownOption(
            id: item['id'],
            key: item['key'],
            name: item['Translations']?.isNotEmpty == true 
                ? item['Translations'][0]['name'] 
                : item['key'],
          )).toList();
        });
      }
    } catch (e) {
      AppLogger.error('Error loading food types', e);
    }
  }

  Future<void> _loadCategories(String foodTypeKey) async {
    if (foodTypeKey.isEmpty) return;
    
    try {
      // Find food type ID by key
      final foodType = _foodTypes.firstWhere(
        (ft) => ft.key == foodTypeKey,
        orElse: () => throw Exception('Food type not found: $foodTypeKey'),
      );
      
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/v1/categories/food-type/${foodType.id}?lang=en'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> categoriesData = data['data'];
        
        setState(() {
          _categories = categoriesData.map((item) => DropdownOption(
            id: item['id'],
            key: item['key'],
            name: item['Translations']?.isNotEmpty == true 
                ? item['Translations'][0]['name'] 
                : item['key'],
          )).toList();
          
          // Reset dependent dropdowns
          _selectedCategoryKey = null;
          _selectedSubcategoryKey = null;
          _subcategories = [];
        });
      }
    } catch (e) {
      AppLogger.error('Error loading categories', e);
    }
  }

  Future<void> _loadSubcategories(String categoryKey) async {
    if (categoryKey.isEmpty) return;
    
    try {
      // Find category ID by key
      final category = _categories.firstWhere(
        (c) => c.key == categoryKey,
        orElse: () => throw Exception('Category not found: $categoryKey'),
      );
      
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/v1/subcategories/category/${category.id}?lang=en'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> subcategoriesData = data['data'];
        
        setState(() {
          _subcategories = subcategoriesData.map((item) => DropdownOption(
            id: item['id'],
            key: item['key'],
            name: item['Translations']?.isNotEmpty == true 
                ? item['Translations'][0]['name'] 
                : item['key'],
          )).toList();
          
          // Reset dependent selection
          _selectedSubcategoryKey = null;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading subcategories', e);
    }
  }

  Future<void> _loadProteinTypes() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/v1/protein-types?lang=en'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> proteinTypesData = data['data'];
        
        setState(() {
          _proteinTypes = proteinTypesData.map((item) => DropdownOption(
            id: item['id'],
            key: item['key'],
            name: item['name'],
          )).toList();
        });
      }
    } catch (e) {
      AppLogger.error('Error loading protein types', e);
    }
  }

  Future<void> _showCreateSubcategoryDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return const AddSubcategoryDialog();
      },
    );

    if (result != null) {
      // Subcategory created successfully, reload subcategories
      if (_selectedCategoryKey != null) {
        await _loadSubcategories(_selectedCategoryKey!);

        // Try to select the newly created subcategory
        final newSubcategoryKey = result['key'] as String?;
        if (newSubcategoryKey != null) {
          setState(() {
            _selectedSubcategoryKey = newSubcategoryKey;
          });
        }
      }
    }
  }

  Map<String, dynamic> _getMenuData() {
    // Find the selected subcategory ID by key
    final selectedSubcategory = _subcategories.firstWhere(
      (sc) => sc.key == _selectedSubcategoryKey,
    );

    // Find the selected protein type ID by key (if selected)
    DropdownOption? selectedProteinType;
    if (_selectedProteinTypeKey != null) {
      selectedProteinType = _proteinTypes.firstWhere(
        (pt) => pt.key == _selectedProteinTypeKey,
      );
    }

    // Build the menu data according to CreateMenuDto
    final Map<String, dynamic> menuData = {
      'subcategory_id': selectedSubcategory.id,
      'meal_time': _selectedMealTime,
      'contains': _containsController.text.isNotEmpty
          ? {'description': _containsController.text}
          : {}, // Send empty object instead of null for now
    };

    // Add optional fields only if they have values
    if (selectedProteinType != null) {
      menuData['protein_type_id'] = selectedProteinType.id;
    }

    if (_imageUrlController.text.isNotEmpty) {
      menuData['image_url'] = _imageUrlController.text;
    }

    return menuData;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
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
                  'Add New Menu Item',
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
                      // Basic Information
                      const Text(
                        'Menu Selection',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Menu name will be automatically generated from Subcategory + Protein Type',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Food Type Dropdown
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
                      
                      // Category Dropdown
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
                                if (newValue != null) {
                                  _loadSubcategories(newValue);
                                }
                              },
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedSubcategoryKey,
                                        decoration: const InputDecoration(
                                          labelText: 'Subcategory*',
                                          border: OutlineInputBorder(),
                                        ),
                                        hint: const Text('Select existing subcategory'),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Subcategory is required';
                                          }
                                          return null;
                                        },
                                        items: _subcategories.map((subcategory) {
                                          return DropdownMenuItem<String>(
                                            value: subcategory.key,
                                            child: Text(
                                              '${subcategory.key} - ${subcategory.name}',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: _selectedCategoryKey == null
                                            ? null
                                            : (String? newValue) {
                                                setState(() {
                                                  _selectedSubcategoryKey = newValue;
                                                });
                                              },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      onPressed: _selectedCategoryKey == null
                                          ? null
                                          : _showCreateSubcategoryDialog,
                                      icon: const Icon(Icons.add),
                                      label: const Text('Create New'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Protein Type Dropdown (moved to separate row)
                      _isLoadingData
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : DropdownButtonFormField<String>(
                              value: _selectedProteinTypeKey,
                              decoration: const InputDecoration(
                                labelText: 'Protein Type',
                                hintText: 'Optional',
                                border: OutlineInputBorder(),
                              ),
                              hint: const Text('Select protein type'),
                              items: _proteinTypes.map((proteinType) {
                                return DropdownMenuItem<String>(
                                  value: proteinType.key,
                                  child: Text(
                                    '${proteinType.key} - ${proteinType.name}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedProteinTypeKey = newValue;
                                });
                              },
                            ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL',
                          hintText: 'https://example.com/image.jpg',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<String>(
                        value: _selectedMealTime,
                        decoration: const InputDecoration(
                          labelText: 'Meal Time*',
                          border: OutlineInputBorder(),
                        ),
                        items: _mealTimes.map((String mealTime) {
                          return DropdownMenuItem<String>(
                            value: mealTime,
                            child: Text(mealTime),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedMealTime = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _containsController,
                        decoration: const InputDecoration(
                          labelText: 'Contains/Ingredients',
                          hintText: 'Brief description of ingredients',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
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
                      final menuData = _getMenuData();
                      Navigator.of(context).pop(menuData);
                    }
                  },
                  child: const Text('Create Menu'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}