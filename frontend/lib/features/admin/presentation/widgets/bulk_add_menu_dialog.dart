import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/utils/logger.dart';

class DropdownOption {
  final int id;
  final String key;
  final String name;

  DropdownOption({required this.id, required this.key, required this.name});

  factory DropdownOption.fromJson(Map<String, dynamic> json) {
    return DropdownOption(
      id: json['id'],
      key: json['key'],
      name: json['name'] ?? json['key'],
    );
  }
}

class BulkAddMenuDialog extends StatefulWidget {
  const BulkAddMenuDialog({super.key});

  @override
  State<BulkAddMenuDialog> createState() => _BulkAddMenuDialogState();
}

class _BulkAddMenuDialogState extends State<BulkAddMenuDialog> {
  final _formKey = GlobalKey<FormState>();
  final _imageUrlController = TextEditingController();
  final _containsController = TextEditingController();

  String _selectedMealTime = 'LUNCH';
  String? _selectedFoodTypeKey;
  String? _selectedCategoryKey;
  String? _selectedSubcategoryKey;
  final List<String> _selectedProteinTypeKeys = [];

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
      await Future.wait([_loadFoodTypes(), _loadProteinTypes()]);
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
          _foodTypes = foodTypesData
              .map(
                (item) => DropdownOption(
                  id: item['id'],
                  key: item['key'],
                  name: item['Translations']?.isNotEmpty == true
                      ? item['Translations'][0]['name']
                      : item['key'],
                ),
              )
              .toList();
        });
      }
    } catch (e) {
      AppLogger.error('Error loading food types', e);
    }
  }

  Future<void> _loadCategories(String foodTypeKey) async {
    if (foodTypeKey.isEmpty) return;

    try {
      final foodType = _foodTypes.firstWhere(
        (ft) => ft.key == foodTypeKey,
        orElse: () => throw Exception('Food type not found: $foodTypeKey'),
      );

      final response = await http.get(
        Uri.parse(
          'http://localhost:8000/api/v1/categories/food-type/${foodType.id}?lang=en',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> categoriesData = data['data'];

        setState(() {
          _categories = categoriesData
              .map(
                (item) => DropdownOption(
                  id: item['id'],
                  key: item['key'],
                  name: item['Translations']?.isNotEmpty == true
                      ? item['Translations'][0]['name']
                      : item['key'],
                ),
              )
              .toList();

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
      final category = _categories.firstWhere(
        (c) => c.key == categoryKey,
        orElse: () => throw Exception('Category not found: $categoryKey'),
      );

      final response = await http.get(
        Uri.parse(
          'http://localhost:8000/api/v1/subcategories/category/${category.id}?lang=en',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> subcategoriesData = data['data'];

        setState(() {
          _subcategories = subcategoriesData
              .map(
                (item) => DropdownOption(
                  id: item['id'],
                  key: item['key'],
                  name: item['Translations']?.isNotEmpty == true
                      ? item['Translations'][0]['name']
                      : item['key'],
                ),
              )
              .toList();

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
          _proteinTypes = proteinTypesData
              .map(
                (item) => DropdownOption(
                  id: item['id'],
                  key: item['key'],
                  name: item['name'],
                ),
              )
              .toList();
        });
      }
    } catch (e) {
      AppLogger.error('Error loading protein types', e);
    }
  }

  List<Map<String, dynamic>> _getMenusData() {
    final selectedSubcategory = _subcategories.firstWhere(
      (sc) => sc.key == _selectedSubcategoryKey,
    );

    final List<Map<String, dynamic>> menusData = [];

    for (final proteinKey in _selectedProteinTypeKeys) {
      final selectedProteinType = _proteinTypes.firstWhere(
        (pt) => pt.key == proteinKey,
      );

      final Map<String, dynamic> menuData = {
        'subcategory_id': selectedSubcategory.id,
        'protein_type_id': selectedProteinType.id,
        'meal_time': _selectedMealTime,
        'contains': _containsController.text.isNotEmpty
            ? {'description': _containsController.text}
            : {},
      };

      if (_imageUrlController.text.isNotEmpty) {
        menuData['image_url'] = _imageUrlController.text;
      }

      menusData.add(menuData);
    }

    return menusData;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bulk Add Menus',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Create multiple menus with different proteins at once',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
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
                            child: Text('${category.key} - ${category.name}'),
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

                      // Subcategory Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedSubcategoryKey,
                        decoration: const InputDecoration(
                          labelText: 'Subcategory*',
                          border: OutlineInputBorder(),
                        ),
                        hint: const Text('Select subcategory'),
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
                      const SizedBox(height: 24),

                      // Protein Types Multi-Select
                      const Text(
                        'Select Protein Types*',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Choose multiple proteins to create menus for each',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _proteinTypes.map((protein) {
                            final isSelected = _selectedProteinTypeKeys
                                .contains(protein.key);
                            return FilterChip(
                              label: Text(protein.name),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedProteinTypeKeys.add(protein.key);
                                  } else {
                                    _selectedProteinTypeKeys.remove(
                                      protein.key,
                                    );
                                  }
                                });
                              },
                              selectedColor: Colors.orange.shade100,
                              checkmarkColor: Colors.orange,
                            );
                          }).toList(),
                        ),
                      ),
                      if (_selectedProteinTypeKeys.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8, left: 12),
                          child: Text(
                            'Please select at least one protein type',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Meal Time
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

                      // Image URL
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL (Optional)',
                          hintText: 'https://example.com/image.jpg',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Contains
                      TextFormField(
                        controller: _containsController,
                        decoration: const InputDecoration(
                          labelText: 'Contains/Ingredients (Optional)',
                          hintText: 'Brief description of ingredients',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),

                      // Preview
                      if (_selectedProteinTypeKeys.isNotEmpty &&
                          _selectedSubcategoryKey != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: Card(
                            color: Colors.blue.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.blue,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Preview',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'This will create ${_selectedProteinTypeKeys.length} menu(s):',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 8),
                                  ...(_selectedProteinTypeKeys.map((key) {
                                    final protein = _proteinTypes.firstWhere(
                                      (p) => p.key == key,
                                    );
                                    final subcategory = _subcategories
                                        .firstWhere(
                                          (s) =>
                                              s.key == _selectedSubcategoryKey,
                                        );
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16,
                                        bottom: 4,
                                      ),
                                      child: Text(
                                        '• ${subcategory.name}${protein.name}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    );
                                  })),
                                ],
                              ),
                            ),
                          ),
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
                      if (_selectedProteinTypeKeys.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please select at least one protein type',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      final menusData = _getMenusData();
                      Navigator.of(context).pop(menusData);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Create ${_selectedProteinTypeKeys.length} Menu(s)',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
