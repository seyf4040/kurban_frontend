import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/person/person_cubit.dart';
import '../../cubits/config/config_cubit.dart';
import '../../../data/models/person.dart';
import '../../../core/constants/app_colors.dart';
import '../../../dependencies.dart';

class AddPersonScreen extends StatefulWidget {
  const AddPersonScreen({super.key});

  @override
  State<AddPersonScreen> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends State<AddPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  
  Person? _selectedIntermediary;
  bool _needsIntermediary = false;
  List<Person> _availableIntermediaries = [];

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PersonCubit>()..loadPersons(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Person'),
          centerTitle: true,
        ),
        body: BlocListener<PersonCubit, PersonState>(
          listener: (context, state) {
            if (state is PersonLoaded) {
              _availableIntermediaries = state.persons
                  .where((person) => person.hasContactInfo)
                  .toList();
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // First Name
                  TextFormField(
                    controller: _firstnameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name *',
                      hintText: 'Enter first name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'First name is required';
                      }
                      if (value.length > 50) {
                        return 'First name must not exceed 50 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Last Name
                  TextFormField(
                    controller: _lastnameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name *',
                      hintText: 'Enter last name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Last name is required';
                      }
                      if (value.length > 50) {
                        return 'Last name must not exceed 50 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Contact Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Provide at least one contact method or select an intermediary',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Phone
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter phone number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => _updateContactValidation(),
                    validator: (value) {
                      if (value != null && value.isNotEmpty && value.length > 20) {
                        return 'Phone number must not exceed 20 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'Enter email address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => _updateContactValidation(),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        if (value.length > 120) {
                          return 'Email must not exceed 120 characters';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Contact Intermediary Section
                  CheckboxListTile(
                    title: const Text('This person needs a contact intermediary'),
                    subtitle: const Text('Select if this person has no direct contact info'),
                    value: _needsIntermediary,
                    onChanged: (value) {
                      setState(() {
                        _needsIntermediary = value ?? false;
                        if (!_needsIntermediary) {
                          _selectedIntermediary = null;
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  
                  if (_needsIntermediary) ...[
                    const SizedBox(height: 16),
                    _buildIntermediarySelector(),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isFormValid() ? _submitForm : null,
                      child: const Text(
                        'Add Person',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntermediarySelector() {
    return BlocBuilder<PersonCubit, PersonState>(
      builder: (context, state) {
        if (state is PersonLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        
        if (_availableIntermediaries.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    'No Contact Intermediaries Available',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You need at least one person with contact info to act as an intermediary.',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Contact Intermediary *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _availableIntermediaries.length,
                itemBuilder: (context, index) {
                  final intermediary = _availableIntermediaries[index];
                  return RadioListTile<Person>(
                    title: Text(intermediary.fullName),
                    subtitle: Text(
                      [intermediary.phone, intermediary.email]
                          .where((contact) => contact != null && contact.isNotEmpty)
                          .join(' • '),
                    ),
                    value: intermediary,
                    groupValue: _selectedIntermediary,
                    onChanged: (value) {
                      setState(() {
                        _selectedIntermediary = value;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateContactValidation() {
    setState(() {
      // Trigger rebuild to update form validation
    });
  }

  bool _isFormValid() {
    final hasDirectContact = _phoneController.text.trim().isNotEmpty || 
                           _emailController.text.trim().isNotEmpty;
    final hasIntermediary = _needsIntermediary && _selectedIntermediary != null;
    
    return _firstnameController.text.trim().isNotEmpty &&
           _lastnameController.text.trim().isNotEmpty &&
           (hasDirectContact || hasIntermediary);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (!_isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide contact information or select an intermediary'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final request = PersonCreateRequest(
      firstname: _firstnameController.text.trim(),
      lastname: _lastnameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      contactIntermediaryId: _selectedIntermediary?.id,
    );

    try {
      await context.read<PersonCubit>().createPerson(request);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Person added successfully'),
            backgroundColor: AppColors.completed,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding person: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}