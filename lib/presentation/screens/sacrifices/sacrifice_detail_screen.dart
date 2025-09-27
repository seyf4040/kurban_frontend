import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/sacrifice/sacrifice_cubit.dart';
import '../../cubits/participation/participation_cubit.dart';
import '../../cubits/person/person_cubit.dart';
import '../../cubits/config/config_cubit.dart';
import '../../../data/models/sacrifice.dart';
import '../../../data/models/person.dart';
import '../../../data/models/participation.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../../dependencies.dart';

class SacrificeDetailScreen extends StatefulWidget {
  final int sacrificeId;

  const SacrificeDetailScreen({
    super.key,
    required this.sacrificeId,
  });

  @override
  State<SacrificeDetailScreen> createState() => _SacrificeDetailScreenState();
}

class _SacrificeDetailScreenState extends State<SacrificeDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shareCountController = TextEditingController();
  final _notesController = TextEditingController();
  
  Person? _selectedPerson;
  String _personSearchQuery = '';
  bool _isFormExpanded = true;

  @override
  void initState() {
    super.initState();
    _shareCountController.text = '1';
  }

  @override
  void dispose() {
    _shareCountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<SacrificeCubit>()..loadSacrificeById(widget.sacrificeId),
        ),
        BlocProvider(
          create: (context) => getIt<ParticipationCubit>()..loadParticipationsBySacrifice(widget.sacrificeId),
        ),
        BlocProvider(
          create: (context) => getIt<PersonCubit>()..loadPersons(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sacrifice Details'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<SacrificeCubit>().loadSacrificeById(widget.sacrificeId);
                context.read<ParticipationCubit>().loadParticipationsBySacrifice(widget.sacrificeId);
              },
            ),
          ],
        ),
        body: BlocBuilder<SacrificeCubit, SacrificeState>(
          builder: (context, state) {
            if (state is SacrificeLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is SacrificeError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<SacrificeCubit>().loadSacrificeById(widget.sacrificeId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            
            if (state is SacrificeDetailLoaded) {
              final sacrifice = state.sacrifice;
              
              return Column(
                children: [
                  // Sacrifice Info Header
                  _buildSacrificeHeader(sacrifice),
                  
                  // Participations List (Expandable)
                  Expanded(
                    child: _buildParticipationsList(sacrifice),
                  ),
                  
                  // Add Participation Form
                  _buildAddParticipationForm(sacrifice),
                ],
              );
            }
            
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSacrificeHeader(Sacrifice sacrifice) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: sacrifice.isCompleted 
                    ? AppColors.completed 
                    : AppColors.pending,
                  radius: 24,
                  child: Text(
                    sacrifice.sacrificeNumber.toString(),
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
                        sacrifice.animalType.toUpperCase(),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Total Cost: ${CurrencyUtils.format(sacrifice.totalCost ?? 0)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sacrifice.isCompleted 
                      ? AppColors.completed 
                      : AppColors.pending,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    sacrifice.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Financial Summary
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Participants',
                    sacrifice.totalParticipants.toString(),
                    Icons.people,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Shares Used',
                    '${sacrifice.totalShares}/7',
                    Icons.pie_chart,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Collected',
                    CurrencyUtils.formatCompact(sacrifice.totalPaidAmount ?? 0),
                    Icons.account_balance_wallet,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Pending',
                    CurrencyUtils.formatCompact(sacrifice.pendingAmount),
                    Icons.pending,
                  ),
                ),
              ],
            ),
            
            if (sacrifice.sacrificeDate != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Sacrifice Date: ${AppDateUtils.formatDate(sacrifice.sacrificeDate!)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryGreen),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildParticipationsList(Sacrifice sacrifice) {
    return BlocBuilder<ParticipationCubit, ParticipationState>(
      builder: (context, state) {
        if (state is ParticipationLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is ParticipationError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                Text('Error loading participations: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<ParticipationCubit>().loadParticipationsBySacrifice(widget.sacrificeId),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (state is ParticipationLoaded) {
          final participations = state.participations;
          
          if (participations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_add,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No participations yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add the first participation below',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }
          
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Participations (${participations.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Share Price: ${CurrencyUtils.format(sacrifice.sharePrice ?? 0)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: participations.length,
                  itemBuilder: (context, index) {
                    final participation = participations[index];
                    return _buildParticipationCard(participation, sacrifice);
                  },
                ),
              ),
            ],
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildParticipationCard(Participation participation, Sacrifice sacrifice) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: participation.paid ? AppColors.completed : AppColors.pending,
              child: Text(
                participation.shareCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    participation.personName ?? 'Unknown Person',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${participation.shareCount} ${participation.shareCount == 1 ? 'share' : 'shares'}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      if (participation.shareAmount != null) ...[
                        Text(
                          ' • ${CurrencyUtils.format(participation.shareAmount!)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (participation.notes != null && participation.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      participation.notes!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: participation.paid ? AppColors.completed : AppColors.pending,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    participation.paid ? 'PAID' : 'PENDING',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showEditParticipationDialog(participation, sacrifice),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        foregroundColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _showDeleteParticipationDialog(participation),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddParticipationForm(Sacrifice sacrifice) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          'Add Participation',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Available shares: ${sacrifice.availableShares}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        leading: const Icon(Icons.group_add),
        initiallyExpanded: _isFormExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _isFormExpanded = expanded;
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Person Selection
                  _buildPersonSelector(),
                  const SizedBox(height: 16),
                  
                  // Share Count
                  TextFormField(
                    controller: _shareCountController,
                    decoration: const InputDecoration(
                      labelText: 'Number of Shares',
                      hintText: 'Enter share count (1-7)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.pie_chart),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter share count';
                      }
                      final shares = int.tryParse(value);
                      if (shares == null || shares < 1 || shares > 7) {
                        return 'Share count must be between 1 and 7';
                      }
                      if (shares > sacrifice.availableShares) {
                        return 'Only ${sacrifice.availableShares} shares available';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Notes
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'Add any additional notes...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.notes),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  
                  // Calculate Share Amount
                  if (_shareCountController.text.isNotEmpty && sacrifice.sharePrice != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accentCream,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Calculated Amount:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            CurrencyUtils.format(
                              (int.tryParse(_shareCountController.text) ?? 0) * sacrifice.sharePrice!,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: sacrifice.availableShares > 0 ? () => _submitParticipation(sacrifice) : null,
                      child: Text(
                        sacrifice.availableShares > 0 
                          ? 'Add Participation' 
                          : 'No Shares Available',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonSelector() {
    return BlocBuilder<PersonCubit, PersonState>(
      builder: (context, state) {
        if (state is! PersonLoaded) {
          return TextFormField(
            decoration: const InputDecoration(
              labelText: 'Loading persons...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            enabled: false,
          );
        }
        
        final persons = state.persons
            .where((person) => person.fullName.toLowerCase().contains(_personSearchQuery.toLowerCase()))
            .toList();
        
        return Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Search Person',
                hintText: 'Type to search persons...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _selectedPerson != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _selectedPerson = null;
                            _personSearchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _personSearchQuery = value;
                  if (value.isEmpty) {
                    _selectedPerson = null;
                  }
                });
              },
              validator: (value) {
                if (_selectedPerson == null) {
                  return 'Please select a person';
                }
                return null;
              },
            ),
            
            if (_selectedPerson != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryGreen),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryGreen,
                      radius: 16,
                      child: Text(
                        _selectedPerson!.firstname.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
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
                            _selectedPerson!.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_selectedPerson!.email != null)
                            Text(
                              _selectedPerson!.email!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.primaryGreen,
                    ),
                  ],
                ),
              ),
            ] else if (_personSearchQuery.isNotEmpty && persons.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: persons.length,
                  itemBuilder: (context, index) {
                    final person = persons[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryGreen,
                        radius: 16,
                        child: Text(
                          person.firstname.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(person.fullName),
                      subtitle: person.email != null ? Text(person.email!) : null,
                      onTap: () {
                        setState(() {
                          _selectedPerson = person;
                          _personSearchQuery = person.fullName;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _submitParticipation(Sacrifice sacrifice) async {
    if (!_formKey.currentState!.validate() || _selectedPerson == null) {
      return;
    }

    final shareCount = int.parse(_shareCountController.text);
    final shareAmount = shareCount * (sacrifice.sharePrice ?? 0);

    // Check if person already participates
    final participationState = context.read<ParticipationCubit>().state;
    if (participationState is ParticipationLoaded) {
      final existingParticipation = participationState.participations
          .where((p) => p.personId == _selectedPerson!.id)
          .firstOrNull;

      if (existingParticipation != null) {
        final confirmed = await _showUpdateParticipationDialog(
          existingParticipation,
          shareCount,
          shareAmount,
        );
        if (!confirmed) return;
      }
    }

    final request = ParticipationCreateRequest(
      personId: _selectedPerson!.id!,
      sacrificeId: sacrifice.id!,
      shareCount: shareCount,
      shareAmount: shareAmount,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    try {
      await context.read<ParticipationCubit>().createParticipation(request);
      
      // Reset form
      setState(() {
        _selectedPerson = null;
        _personSearchQuery = '';
        _shareCountController.text = '1';
        _notesController.clear();
      });
      
      // Refresh sacrifice data to update available shares
      context.read<SacrificeCubit>().loadSacrificeById(widget.sacrificeId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Participation added successfully'),
            backgroundColor: AppColors.completed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding participation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showUpdateParticipationDialog(
    Participation existing,
    int newShareCount,
    double newShareAmount,
  ) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Participation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${existing.personName} already participates in this sacrifice.'),
            const SizedBox(height: 16),
            Text('Current: ${existing.shareCount} shares'),
            Text('Adding: $newShareCount shares'),
            Text('New Total: ${existing.shareCount + newShareCount} shares'),
            const SizedBox(height: 8),
            Text('New Amount: ${CurrencyUtils.format(newShareAmount + (existing.shareAmount ?? 0))}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Update'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _showEditParticipationDialog(Participation participation, Sacrifice sacrifice) async {
    // Implementation for edit dialog
    // This would open a dialog similar to the add form but pre-filled with existing data
  }

  Future<void> _showDeleteParticipationDialog(Participation participation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Participation'),
        content: Text('Are you sure you want to delete ${participation.personName}\'s participation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && participation.id != null) {
      try {
        await context.read<ParticipationCubit>().deleteParticipation(
          participation.id!,
          widget.sacrificeId,
        );
        
        // Refresh sacrifice data
        context.read<SacrificeCubit>().loadSacrificeById(widget.sacrificeId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Participation deleted successfully'),
              backgroundColor: AppColors.completed,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting participation: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}