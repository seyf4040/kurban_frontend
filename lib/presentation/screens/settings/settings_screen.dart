import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/config/config_cubit.dart';
import '../../../data/models/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _defaultAnimalType = 'cow';
  final Map<String, TextEditingController> _priceControllers = {};
  Color _primaryColor = AppColors.primaryGreen;
  Color _accentColor = AppColors.accentCream;
  int _defaultSacrificeDays = 30;
  
  final List<String> _animalTypes = ['cow', 'goat', 'sheep', 'camel'];
  final List<Color> _availableColors = [
    AppColors.primaryGreen,
    AppColors.darkGreen,
    AppColors.mediumGreen,
    Colors.teal.shade800,
    Colors.green.shade900,
    Colors.blue.shade800,
    Colors.indigo.shade800,
    Colors.purple.shade800,
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize price controllers
    for (String type in _animalTypes) {
      _priceControllers[type] = TextEditingController();
    }
    
    // Load current config
    _loadConfig();
  }

  @override
  void dispose() {
    for (var controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _loadConfig() {
    final configState = context.read<ConfigCubit>().state;
    if (configState is ConfigLoaded) {
      final config = configState.config;
      setState(() {
        _defaultAnimalType = config.defaultAnimalType;
        _primaryColor = config.primaryColor;
        _accentColor = config.accentColor;
        _defaultSacrificeDays = config.defaultSacrificeDaysFromNow;
        
        // Set price controllers
        for (String type in _animalTypes) {
          final price = config.defaultPriceByAnimalType[type];
          _priceControllers[type]!.text = price?.toString() ?? '';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveConfig,
          ),
        ],
      ),
      body: BlocListener<ConfigCubit, ConfigState>(
        listener: (context, state) {
          if (state is ConfigLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Settings saved successfully'),
                backgroundColor: AppColors.completed,
              ),
            );
          } else if (state is ConfigError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error saving settings: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Default Animal Settings
                _buildSectionHeader('Default Animal Settings'),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  value: _defaultAnimalType,
                  decoration: const InputDecoration(
                    labelText: 'Default Animal Type',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.agriculture),
                  ),
                  items: _animalTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _defaultAnimalType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                
                // Default Prices
                _buildSectionHeader('Default Prices by Animal Type'),
                const SizedBox(height: 16),
                
                ..._animalTypes.map((type) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _priceControllers[type],
                    decoration: InputDecoration(
                      labelText: '${type.toUpperCase()} Price',
                      hintText: 'Enter default price for $type',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final price = double.tryParse(value);
                        if (price == null || price < 0) {
                          return 'Please enter a valid price';
                        }
                      }
                      return null;
                    },
                  ),
                )),
                
                const SizedBox(height: 8),
                
                // Default Sacrifice Date
                _buildSectionHeader('Default Sacrifice Date'),
                const SizedBox(height: 16),
                
                TextFormField(
                  initialValue: _defaultSacrificeDays.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Days from now',
                    hintText: 'Number of days from today',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                    suffixText: 'days',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final days = int.tryParse(value);
                    if (days != null && days >= 0) {
                      setState(() {
                        _defaultSacrificeDays = days;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    final days = int.tryParse(value);
                    if (days == null || days < 0) {
                      return 'Please enter a valid number of days';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Theme Settings
                _buildSectionHeader('Theme Settings'),
                const SizedBox(height: 16),
                
                // Primary Color
                _buildColorSelector(
                  'Primary Color',
                  _primaryColor,
                  (color) => setState(() => _primaryColor = color),
                ),
                const SizedBox(height: 16),
                
                // Accent Color
                _buildColorSelector(
                  'Accent Color',
                  _accentColor,
                  (color) => setState(() => _accentColor = color),
                ),
                const SizedBox(height: 32),
                
                // Preview Section
                _buildSectionHeader('Preview'),
                const SizedBox(height: 16),
                
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: _primaryColor,
                              child: const Text(
                                '1',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _defaultAnimalType.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    CurrencyUtils.format(
                                      double.tryParse(_priceControllers[_defaultAnimalType]!.text) ?? 0
                                    ),
                                    style: TextStyle(
                                      color: _primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _accentColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'This is how your theme will look',
                            style: TextStyle(
                              color: _primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                    ),
                    onPressed: _saveConfig,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      'Save Settings',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Reset Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _resetToDefaults,
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      'Reset to Defaults',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: _primaryColor,
      ),
    );
  }

  Widget _buildColorSelector(String label, Color selectedColor, ValueChanged<Color> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableColors.map((color) {
            final isSelected = color.value == selectedColor.value;
            return GestureDetector(
              onTap: () => onChanged(color),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey.shade300,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final priceMap = <String, double>{};
    for (String type in _animalTypes) {
      final priceText = _priceControllers[type]!.text;
      if (priceText.isNotEmpty) {
        final price = double.tryParse(priceText);
        if (price != null) {
          priceMap[type] = price;
        }
      }
    }

    final config = AppConfig(
      defaultAnimalType: _defaultAnimalType,
      defaultPriceByAnimalType: priceMap,
      primaryColor: _primaryColor,
      accentColor: _accentColor,
      defaultSacrificeDaysFromNow: _defaultSacrificeDays,
    );

    await context.read<ConfigCubit>().updateConfig(config);
  }

  void _resetToDefaults() {
    setState(() {
      _defaultAnimalType = 'cow';
      _primaryColor = AppColors.primaryGreen;
      _accentColor = AppColors.accentCream;
      _defaultSacrificeDays = 30;
      
      // Reset price controllers to default values
      _priceControllers['cow']!.text = '1000';
      _priceControllers['goat']!.text = '500';
      _priceControllers['sheep']!.text = '600';
      _priceControllers['camel']!.text = '2000';
    });
  }
}