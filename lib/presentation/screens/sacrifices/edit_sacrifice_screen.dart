import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/sacrifice/sacrifice_cubit.dart';
import '../../../data/models/sacrifice.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';

class EditSacrificeScreen extends StatefulWidget {
  final Sacrifice sacrifice;

  const EditSacrificeScreen({
    super.key,
    required this.sacrifice,
  });

  @override
  State<EditSacrificeScreen> createState() => _EditSacrificeScreenState();
}

class _EditSacrificeScreenState extends State<EditSacrificeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _sacrificeNumberController;
  late TextEditingController _totalCostController;
  
  late String _selectedAnimalType;
  DateTime? _selectedDate;
  
  final List<String> _animalTypes = ['cow', 'goat', 'sheep', 'camel'];

  @override
  void initState() {
    super.initState();
    _sacrificeNumberController = TextEditingController(
      text: widget.sacrifice.sacrificeNumber.toString(),
    );
    _totalCostController = TextEditingController(
      text: widget.sacrifice.totalCost?.toString() ?? '',
    );
    _selectedAnimalType = widget.sacrifice.animalType;
    _selectedDate = widget.sacrifice.sacrificeDate;
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
        title: const Text('Edit Sacrifice'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Sacrifice Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: widget.sacrifice.isCompleted 
                          ? AppColors.completed 
                          : AppColors.pending,
                        radius: 24,
                        child: Text(
                          widget.sacrifice.sacrificeNumber.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.sacrifice.animalType.toUpperCase(),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${widget.sacrifice.totalParticipants} participants • ${widget.sacrifice.status}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              if (widget.sacrifice.totalParticipants > 0) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Warning: This sacrifice has ${widget.sacrifice.totalParticipants} participant${widget.sacrifice.totalParticipants == 1 ? '' : 's'}. Changes may affect their shares.',
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
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
                    child: Text(type.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedAnimalType = value;
                    });
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
                            'New Share Price (Total ÷ 7):',
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
                      if (widget.sacrifice.sharePrice != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Current Share Price:',
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              CurrencyUtils.format(widget.sacrifice.sharePrice!),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
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
                                : 'No date set',
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
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Update Sacrifice'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
      firstDate: now.subtract(const Duration(days: 365)),
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
      await context.read<SacrificeCubit>().updateSacrifice(widget.sacrifice.id!, request);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sacrifice updated successfully'),
            backgroundColor: AppColors.completed,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating sacrifice: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}