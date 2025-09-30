import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kurban_frontend/dependencies.dart';
import 'package:kurban_frontend/presentation/cubits/config/config_cubit.dart';
import 'package:kurban_frontend/presentation/cubits/participation/participation_cubit.dart';
import 'package:kurban_frontend/presentation/cubits/person/person_cubit.dart';
import '../../cubits/sacrifice/sacrifice_cubit.dart';
import '../../../data/models/sacrifice.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';
import 'add_sacrifice_screen.dart';
import 'edit_sacrifice_screen.dart';
import 'sacrifice_detail_screen.dart';

class SacrificesScreen extends StatelessWidget {
  const SacrificesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sacrifices'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<SacrificeCubit>().loadSacrifices(),
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
                    onPressed: () => context.read<SacrificeCubit>().loadSacrifices(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (state is SacrificeLoaded) {
            final sacrifices = state.sacrifices;
            
            if (sacrifices.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.agriculture,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No sacrifices yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first sacrifice to get started',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return RefreshIndicator(
              onRefresh: () async => context.read<SacrificeCubit>().loadSacrifices(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sacrifices.length,
                itemBuilder: (context, index) {
                  final sacrifice = sacrifices[index];
                  return _SacrificeCard(
                    sacrifice: sacrifice,
                    onTap: () => _navigateToDetail(context, sacrifice),
                    onEdit: () => _navigateToEdit(context, sacrifice),
                    onDelete: () => _showDeleteDialog(context, sacrifice),
                    onComplete: sacrifice.isPending 
                      ? () => _completeSacrifice(context, sacrifice) 
                      : null,
                    onCancel: sacrifice.isPending 
                      ? () => _cancelSacrifice(context, sacrifice) 
                      : null,
                  );
                },
              ),
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "sacrifice_fab",
        onPressed: () => _navigateToAdd(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _navigateToAdd(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: getIt<SacrificeCubit>()),
            BlocProvider.value(value: getIt<ConfigCubit>()),
          ],
          child: const AddSacrificeScreen(),
        ),
      ),
    );
    
    if (result == true) {
      context.read<SacrificeCubit>().loadSacrifices();
    }
  }

  Future<void> _navigateToEdit(BuildContext context, Sacrifice sacrifice) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: getIt<SacrificeCubit>()),
            BlocProvider.value(value: getIt<ConfigCubit>()),
          ],
          child: EditSacrificeScreen(sacrifice: sacrifice),
        ),
      ),
    );
    
    if (result == true) {
      context.read<SacrificeCubit>().loadSacrifices();
    }
  }

  Future<void> _navigateToDetail(BuildContext context, Sacrifice sacrifice) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            // ✅ Use existing singleton instances
            BlocProvider.value(value: getIt<SacrificeCubit>()),
            BlocProvider.value(value: getIt<PersonCubit>()),
            // ✅ Only ParticipationCubit is new since it's sacrifice-specific
            BlocProvider(
              create: (context) => getIt<ParticipationCubit>()
                ..loadParticipationsBySacrifice(sacrifice.id!),
            ),
          ],
          child: SacrificeDetailScreen(sacrificeId: sacrifice.id!),
        ),
      ),
    );
    
    // Refresh list when returning from detail screen
    context.read<SacrificeCubit>().loadSacrifices();
  }

  Future<void> _showDeleteDialog(BuildContext context, Sacrifice sacrifice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sacrifice'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete Sacrifice #${sacrifice.sacrificeNumber}?'),
            if (sacrifice.totalParticipants > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Warning: This sacrifice has ${sacrifice.totalParticipants} participant${sacrifice.totalParticipants == 1 ? '' : 's'}.',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
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

    if (confirmed == true) {
      try {
        await context.read<SacrificeCubit>().deleteSacrifice(sacrifice.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sacrifice deleted successfully'),
              backgroundColor: AppColors.completed,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting sacrifice: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _completeSacrifice(BuildContext context, Sacrifice sacrifice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Sacrifice'),
        content: Text('Mark Sacrifice #${sacrifice.sacrificeNumber} as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<SacrificeCubit>().completeSacrifice(sacrifice.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sacrifice completed successfully'),
              backgroundColor: AppColors.completed,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error completing sacrifice: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _cancelSacrifice(BuildContext context, Sacrifice sacrifice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Sacrifice'),
        content: Text('Cancel Sacrifice #${sacrifice.sacrificeNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancel Sacrifice'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<SacrificeCubit>().cancelSacrifice(sacrifice.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sacrifice cancelled'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error cancelling sacrifice: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _SacrificeCard extends StatelessWidget {
  final Sacrifice sacrifice;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  const _SacrificeCard({
    required this.sacrifice,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onComplete,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header Row
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getStatusColor(),
                    radius: 20,
                    child: Text(
                      sacrifice.sacrificeNumber.toString(),
                      style: const TextStyle(
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
                          sacrifice.animalType.toUpperCase(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          CurrencyUtils.format(sacrifice.totalCost ?? 0),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      sacrifice.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Stats Row
              Row(
                children: [
                  _buildStat(
                    context,
                    'Participants',
                    sacrifice.totalParticipants.toString(),
                    Icons.people,
                  ),
                  _buildStat(
                    context,
                    'Shares',
                    '${sacrifice.totalShares}/7',
                    Icons.pie_chart,
                  ),
                  _buildStat(
                    context,
                    'Collected',
                    CurrencyUtils.formatCompact(sacrifice.totalPaidAmount ?? 0),
                    Icons.account_balance_wallet,
                  ),
                  _buildStat(
                    context,
                    'Pending',
                    CurrencyUtils.formatCompact(sacrifice.pendingAmount),
                    Icons.pending,
                  ),
                ],
              ),
              
              if (sacrifice.sacrificeDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      AppDateUtils.formatDate(sacrifice.sacrificeDate!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Action Buttons
              Row(
                children: [
                  if (onComplete != null) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onComplete,
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Complete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.completed,
                          side: const BorderSide(color: AppColors.completed),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (onCancel != null) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      foregroundColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      foregroundColor: Colors.red,
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

  Widget _buildStat(BuildContext context, String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryGreen),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (sacrifice.status) {
      case 'completed':
        return AppColors.completed;
      case 'cancelled':
        return AppColors.cancelled;
      default:
        return AppColors.pending;
    }
  }
}