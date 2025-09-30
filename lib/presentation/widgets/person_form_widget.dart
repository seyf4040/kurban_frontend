import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/person/person_cubit.dart';
import '../../../data/models/person.dart';
import '../../../core/constants/app_colors.dart';

class PersonFormWidget extends StatefulWidget {
  final Person? person; // null for create, populated for edit
  final VoidCallback? onSuccess;

  const PersonFormWidget({
    super.key,
    this.person,
    this.onSuccess,
  });

  bool get isEditMode => person != null;

  @override
  State<PersonFormWidget> createState() => _PersonFormWidgetState();
}

class _PersonFormWidgetState extends State<PersonFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  
  Person? _selectedIntermediary;
  bool _needsIntermediary = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data if in edit mode
    _firstnameController = TextEditingController(
      text: widget.person?.firstname ?? '',
    );
    _lastnameController = TextEditingController(
      text: widget.person?.lastname ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.person?.phone ?? '',
    );
    _emailController = TextEditingController(
      text: widget.person?.email ?? '',
    );
    _needsIntermediary = widget.person?.contactIntermediaryId != null;
    
    // Load persons to get available intermediaries
    context.read<PersonCubit>().loadPersons();
  }

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
    return BlocListener<PersonCubit, PersonState>(
      listener: (context, state) {
        if (state is PersonError) {
          final action = widget.isEditMode ? 'updating' : 'adding';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error $action person: ${state.message}'),
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
              // Show person info card only in edit mode
              if (widget.isEditMode) ...[
                _buildPersonInfoCard(),
                const SizedBox(height: 24),
              ],
              
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
                'Provide at least one contact method',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              
              // Phone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter phone number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16),
              
              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'Enter email address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Contact via Intermediary
              CheckboxListTile(
                title: const Text('Contact via Intermediary'),
                subtitle: const Text('This person can be contacted through someone else'),
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
                  child: Text(
                    widget.isEditMode ? 'Update Person' : 'Add Person',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonInfoCard() {
    final person = widget.person!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primaryGreen,
              radius: 24,
              child: Text(
                person.firstname.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Editing: ${person.fullName}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (person.totalParticipations > 0)
                    Text(
                      '${person.totalParticipations} participation${person.totalParticipations == 1 ? '' : 's'}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
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
        
        // Get available intermediaries directly from state
        List<Person> availableIntermediaries = [];
        if (state is PersonLoaded) {
          availableIntermediaries = state.persons.where((person) {
            // Person must have contact info
            if (!person.hasContactInfo) return false;
            
            // In edit mode, exclude the person being edited
            if (widget.isEditMode && person.id == widget.person!.id) {
              return false;
            }
            
            return true;
          }).toList();
          
          // Auto-select existing intermediary in edit mode (only once)
          if (widget.isEditMode && 
              _selectedIntermediary == null && 
              widget.person!.contactIntermediaryId != null) {
            _selectedIntermediary = availableIntermediaries
                .where((p) => p.id == widget.person!.contactIntermediaryId)
                .firstOrNull;
          }
        }
        
        if (availableIntermediaries.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 32),
                  SizedBox(height: 8),
                  Text(
                    'No Contact Intermediaries Available',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'You need at least one person with contact info to act as an intermediary.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Contact Intermediary',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Person>(
                  value: _selectedIntermediary,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  hint: const Text('Choose an intermediary'),
                  items: availableIntermediaries.map((person) {
                    return DropdownMenuItem<Person>(
                      value: person,
                      child: Text(person.fullName),
                    );
                  }).toList(),
                  onChanged: (person) {
                    setState(() => _selectedIntermediary = person);
                  },
                  validator: (value) {
                    if (_needsIntermediary && value == null) {
                      return 'Please select an intermediary';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isFormValid() {
    final hasBasicInfo = _firstnameController.text.trim().isNotEmpty &&
                        _lastnameController.text.trim().isNotEmpty;
    
    final hasContactInfo = _phoneController.text.trim().isNotEmpty ||
                          _emailController.text.trim().isNotEmpty ||
                          (_needsIntermediary && _selectedIntermediary != null);
    
    return hasBasicInfo && hasContactInfo;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (widget.isEditMode) {
        // Update existing person
        final request = PersonUpdateRequest(
          firstname: _firstnameController.text.trim(),
          lastname: _lastnameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          contactIntermediaryId: _selectedIntermediary?.id,
        );
        context.read<PersonCubit>().updatePerson(widget.person!.id!, request);
      } else {
        // Create new person
        final request = PersonCreateRequest(
          firstname: _firstnameController.text.trim(),
          lastname: _lastnameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          contactIntermediaryId: _selectedIntermediary?.id,
        );
        context.read<PersonCubit>().createPerson(request);
      }
      widget.onSuccess?.call();
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting form: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}