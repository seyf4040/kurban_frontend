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
    // ✅ Load sacrifice details on init since providers are passed from navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SacrificeCubit>().loadSacrificeById(widget.sacrificeId);
    });
  }

  @override
  void dispose() {
    _shareCountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIXED: Removed MultiBlocProvider wrapper - providers are passed via navigation
    return Scaffold(
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
                if (sacrifice.isPending)
                  _buildAddParticipationForm(sacrifice),
              ],
            );
          }
          
          return const SizedBox.shrink();
        },
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
                    : sacrifice.isCancelled 
                      ? AppColors.cancelled 
                      : AppColors.pending,
                  radius: 24,
                  child: Text(
                    '#${sacrifice.sacrificeNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sacrifice #${sacrifice.sacrificeNumber}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${sacrifice.animalType} • ${AppDateUtils.formatDate(sacrifice.sacrificeDate ?? DateTime.now().add(const Duration(days: 30)))}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
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
                      : sacrifice.isCancelled 
                        ? AppColors.cancelled 
                        : AppColors.pending,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    sacrifice.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Cost',
                    CurrencyUtils.format(sacrifice.totalCost ?? 0.0),
                    Icons.attach_money,
                    AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Per Share',
                    CurrencyUtils.format(sacrifice.costPerCurrentShare),
                    Icons.share,
                    AppColors.lightGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Participants',
                    '${sacrifice.totalParticipants}/7',
                    Icons.people,
                    AppColors.mediumGreen,
                  ),
                ),
              ],
            ),
            
            if (sacrifice.availableShares > 0 && sacrifice.isPending) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.pending.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.pending),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.pending, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${sacrifice.availableShares} share${sacrifice.availableShares == 1 ? '' : 's'} still available',
                      style: const TextStyle(
                        color: AppColors.pending,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
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
                const SizedBox(height: 16),
                Text('Error loading participations: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<ParticipationCubit>()
                      .loadParticipationsBySacrifice(widget.sacrificeId),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (state is ParticipationLoaded) {
          final participations = state.participations;
          
          if (participations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No Participations Yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add the first participation below',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async => context.read<ParticipationCubit>()
                .loadParticipationsBySacrifice(widget.sacrificeId),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: participations.length,
              itemBuilder: (context, index) {
                final participation = participations[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: participation.isPaid 
                        ? AppColors.completed 
                        : AppColors.pending,
                      radius: 20,
                      child: Text(
                        (participation.personName ?? '').substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      participation.personName ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${participation.shareCount} share${participation.shareCount == 1 ? '' : 's'}'),
                        if (participation.notes?.isNotEmpty == true)
                          Text(
                            participation.notes!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyUtils.format(participation.shareAmount ?? 0.0),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: participation.isPaid 
                              ? AppColors.completed 
                              : AppColors.pending,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            participation.isPaid ? 'PAID' : 'PENDING',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _showParticipationActions(context, participation, sacrifice),
                  ),
                );
              },
            ),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAddParticipationForm(Sacrifice sacrifice) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: _isFormExpanded,
        onExpansionChanged: (expanded) => setState(() => _isFormExpanded = expanded),
        title: Text(
          'Add New Participation',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: sacrifice.availableShares > 0 ? AppColors.primaryGreen : Colors.grey,
          ),
        ),
        subtitle: Text(
          sacrifice.availableShares > 0 
            ? '${sacrifice.availableShares} share${sacrifice.availableShares == 1 ? '' : 's'} available'
            : 'No shares available',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Person Selector
                  _buildPersonSelector(),
                  const SizedBox(height: 16),
                  
                  // Share Count
                  TextFormField(
                    controller: _shareCountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Number of Shares',
                      hintText: 'Enter number of shares (1-${sacrifice.availableShares})',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.share),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter number of shares';
                      }
                      final shares = int.tryParse(value);
                      if (shares == null || shares < 1) {
                        return 'Please enter a valid number of shares';
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
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'Add any additional notes...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: sacrifice.availableShares > 0 && _selectedPerson != null
                        ? () => _submitParticipation(sacrifice) 
                        : null,
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (_selectedPerson!.hasContactInfo)
                            const Text(
                              'Has contact info',
                              style: TextStyle(fontSize: 12, color: Colors.green),
                            )
                          else if (_selectedPerson!.contactIntermediaryName != null)
                            Text(
                              'Contact via: ${_selectedPerson!.contactIntermediaryName}',
                              style: const TextStyle(fontSize: 12, color: Colors.orange),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _selectedPerson = null;
                          _personSearchQuery = '';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ] else if (_personSearchQuery.isNotEmpty && persons.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: persons.length,
                  itemBuilder: (context, index) {
                    final person = persons[index];
                    return ListTile(
                      dense: true,
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
                      subtitle: person.hasContactInfo
                          ? const Text('Has contact info', style: TextStyle(color: Colors.green, fontSize: 11))
                          : person.contactIntermediaryName != null
                              ? Text('Via: ${person.contactIntermediaryName}', style: const TextStyle(color: Colors.orange, fontSize: 11))
                              : const Text('No contact info', style: TextStyle(color: Colors.red, fontSize: 11)),
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
    if (!_formKey.currentState!.validate() || _selectedPerson == null) return;

    final shareCount = int.parse(_shareCountController.text);
    final amount = sacrifice.costPerCurrentShare * shareCount;

    final participation = ParticipationCreateRequest(
      sacrificeId: sacrifice.id!,
      personId: _selectedPerson!.id!,
      shareCount: shareCount,
      shareAmount: amount,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    try {
      await context.read<ParticipationCubit>().createParticipation(participation);
      
      // Clear form
      setState(() {
        _selectedPerson = null;
        _personSearchQuery = '';
        _shareCountController.text = '1';
        _notesController.clear();
      });
      
      // Refresh sacrifice details to update available shares
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

  Future<void> _showParticipationActions(BuildContext context, Participation participation, Sacrifice sacrifice) async {
    if (sacrifice.isCompleted || sacrifice.isCancelled) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              participation.personName ?? 'Unknown',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${participation.shareCount} share${participation.shareCount == 1 ? '' : 's'} • ${CurrencyUtils.format(participation.shareAmount ?? 0.0)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            
            if (!participation.isPaid) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _markParticipationPaid(participation);
                  },
                  icon: const Icon(Icons.payment),
                  label: const Text('Mark as Paid'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.completed,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteParticipation(participation);
                },
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text('Delete Participation', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markParticipationPaid(Participation participation) async {
    try {
      await context.read<ParticipationCubit>().markAsPaid(participation.id!, participation.shareAmount!, participation.sacrificeId!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Participation marked as paid'),
            backgroundColor: AppColors.completed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating participation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteParticipation(Participation participation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Participation'),
        content: Text('Are you sure you want to delete ${participation.personName}\'s participation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<ParticipationCubit>().deleteParticipation(participation.id!, participation.sacrificeId!);
        
        // Refresh sacrifice details to update available shares
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