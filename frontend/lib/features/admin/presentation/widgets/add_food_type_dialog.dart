import 'package:flutter/material.dart';

class FoodTypeTranslation {
  String language;
  String name;
  String description;

  FoodTypeTranslation({
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

class AddFoodTypeDialog extends StatefulWidget {
  const AddFoodTypeDialog({super.key});

  @override
  State<AddFoodTypeDialog> createState() => _AddFoodTypeDialogState();
}

class _AddFoodTypeDialogState extends State<AddFoodTypeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _keyController = TextEditingController();
  
  List<FoodTypeTranslation> _translations = [
    FoodTypeTranslation(language: 'en', name: ''),
    FoodTypeTranslation(language: 'th', name: ''),
    FoodTypeTranslation(language: 'jp', name: ''),
    FoodTypeTranslation(language: 'zh', name: ''),
  ];

  final Map<String, String> _languageNames = {
    'en': 'English',
    'th': 'Thai (ไทย)',
    'jp': 'Japanese (日本語)',
    'zh': 'Chinese (中文)',
  };

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getFoodTypeData() {
    return {
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
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add New Food Type',
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
                      // Key Field
                      TextFormField(
                        controller: _keyController,
                        decoration: const InputDecoration(
                          labelText: 'Food Type Key*',
                          hintText: 'e.g., savory_food',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Food type key is required';
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
                      final foodTypeData = _getFoodTypeData();
                      Navigator.of(context).pop(foodTypeData);
                    }
                  },
                  child: const Text('Create Food Type'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}