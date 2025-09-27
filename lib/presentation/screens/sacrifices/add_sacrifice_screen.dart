import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/sacrifice/sacrifice_cubit.dart';
import '../../cubits/config/config_cubit.dart';
import '../../../data/models/sacrifice.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';

class AddSacrificeScreen extends StatefulWidget {
  const AddSacrificeScreen({super.key});

  @override
  State<AddSacrificeScreen> createState() => _AddSacrificeScreenState();
}

class _AddSacrificeScreenState extends State<AddSacrificeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sacrificeNumberController = TextEditingController();
  final _totalCostController = TextEditingController();
  
  String _selectedAnimalType = 'cow';
  DateTime? _selectedDate;
  
  final List<String> _animalTypes = ['cow', 'goat', 'sheep', 'camel'];

  @override
  void initState() {
    super.initState();
    // Set default date
    _selectedDate = DateTime.now().add(const Duration(days: 30));
    
    // Set default values from config when available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final configState = context.read<ConfigCubit>().state;
      if (configState is ConfigLoaded) {
        final config = configState.config;
        setState(() {
          _selectedAnimalType = config.defaultAnimalType;
          final defaultPrice = config.defaultPriceByAnimalType[_selectedAnimalType];
          if (defaultPrice != null) {
            _totalCostController.text = defaultPrice.toString();
          }
          _selectedDate = DateTime.now().add(Duration(days: config.defaultSacrificeDaysFromNow));
        });
      }
    });
  }

  @override
  void dispose() {
    _sacrificeNumberController.dispose();
    _totalCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Sacrifice'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sacrifice Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Sacrifice Number
              TextFormField(
                controller: _sacrificeNumberController,
                decoration: const InputDecoration(
                  labelText: 'Sacrifice Number *',
                  hintText: 'Enter unique sacrifice number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Sacrifice number is required';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Animal Type
              DropdownButtonFormField<String>(
                value: _selectedAnimalType,
                decoration: const InputDecoration(
                  labelText: 'Animal Type *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.agriculture),
                ),
                items: _animalTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Text(type.toUpperCase()),
                        const SizedBox(width: 8),
                        BlocBuilder<ConfigCubit, ConfigState>(
                          builder: (context, state) {
                            if (state is ConfigLoaded) {
                              final defaultPrice = state.config.defaultPriceByAnimalType[type];
                              if (defaultPrice != null) {
                                return Text(
                                  '(${CurrencyUtils.format(defaultPrice)})',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                );
                              }
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedAnimalType = value;
                    });
                    _updateDefaultPrice(value);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an animal type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Total Cost
              TextFormField(
                controller: _totalCostController,
                decoration: const InputDecoration(
                  labelText: 'Total Cost *',
                  hintText: 'Enter total cost',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Total cost is required';
                  }
                  final cost = double.tryParse(value);
                  if (cost == null || cost <= 0) {
                    return 'Please enter a valid positive amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Share Price Calculation
              if (_totalCostController.text.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentCream,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Share Price (Total ÷ 7):',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            _calculateSharePrice(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Each share will cost this amount',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Sacrifice Date
              InkWell(
                onTap: _selectDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sacrifice Date',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedDate != null 
                                ? AppDateUtils.formatDate(_selectedDate!)
                                : 'Select date',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Preview Card
              Card(
                color: AppColors.lightGrey,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.preview, color: AppColors.primaryGreen),
                          const SizedBox(width: 8),
                          Text(
                            'Preview',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildPreviewRow('Sacrifice Number', _sacrificeNumberController.text.isEmpty ? 'Not set' : '#${_sacrificeNumberController.text}'),
                      _buildPreviewRow('Animal Type', _selectedAnimalType.toUpperCase()),
                      _buildPreviewRow('Total Cost', _totalCostController.text.isEmpty ? 'Not set' : CurrencyUtils.format(double.tryParse(_totalCostController.text) ?? 0)),
                      _buildPreviewRow('Share Price', _calculateSharePrice()),
                      _buildPreviewRow('Sacrifice Date', _selectedDate != null ? AppDateUtils.formatDate(_selectedDate!) : 'Not set'),
                      _buildPreviewRow('Status', 'PENDING'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text(
                    'Create Sacrifice',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateDefaultPrice(String animalType) {
    final configState = context.read<ConfigCubit>().state;
    if (configState is ConfigLoaded) {
      final defaultPrice = configState.config.defaultPriceByAnimalType[animalType];
      if (defaultPrice != null) {
        _totalCostController.text = defaultPrice.toString();
      }
    }
  }

  String _calculateSharePrice() {
    final cost = double.tryParse(_totalCostController.text);
    if (cost != null && cost > 0) {
      return CurrencyUtils.format(cost / 7);
    }
    return CurrencyUtils.format(0);
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Select Sacrifice Date',
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = SacrificeCreateRequest(
      sacrificeNumber: int.parse(_sacrificeNumberController.text),
      animalType: _selectedAnimalType,
      totalCost: double.parse(_totalCostController.text),
      sacrificeDate: _selectedDate,
    );

    try {
      await context.read<SacrificeCubit>().createSacrifice(request);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sacrifice created successfully'),
            backgroundColor: AppColors.completed,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating sacrifice: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}