import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/sacrifice/sacrifice_cubit.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kurban Management'),
        centerTitle: true,
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
            final totalSacrifices = sacrifices.length;
            final completedSacrifices = sacrifices.where((s) => s.isCompleted).length;
            final pendingSacrifices = sacrifices.where((s) => s.isPending).length;
            final totalValue = sacrifices.fold<double>(0, (sum, s) => sum + (s.totalCost ?? 0));
            final totalCollected = sacrifices.fold<double>(0, (sum, s) => sum + (s.totalPaidAmount ?? 0));
            final totalPending = totalValue - totalCollected;

            return RefreshIndicator(
              onRefresh: () async => context.read<SacrificeCubit>().loadSacrifices(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Statistics Cards
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _StatCard(
                          title: 'Total Sacrifices',
                          value: totalSacrifices.toString(),
                          icon: Icons.agriculture,
                          color: AppColors.primaryGreen,
                        ),
                        _StatCard(
                          title: 'Completed',
                          value: completedSacrifices.toString(),
                          icon: Icons.check_circle,
                          color: AppColors.completed,
                        ),
                        _StatCard(
                          title: 'Pending',
                          value: pendingSacrifices.toString(),
                          icon: Icons.pending,
                          color: AppColors.pending,
                        ),
                        _StatCard(
                          title: 'Total Value',
                          value: CurrencyUtils.format(totalValue),
                          icon: Icons.account_balance_wallet,
                          color: AppColors.mediumGreen,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Financial Summary
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Financial Summary',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _FinancialRow(
                              label: 'Total Collected',
                              amount: totalCollected,
                              color: AppColors.completed,
                            ),
                            const SizedBox(height: 8),
                            _FinancialRow(
                              label: 'Total Pending',
                              amount: totalPending,
                              color: AppColors.pending,
                            ),
                            const Divider(),
                            _FinancialRow(
                              label: 'Total Value',
                              amount: totalValue,
                              color: AppColors.primaryGreen,
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Recent Sacrifices
                    Text(
                      'Recent Sacrifices',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (sacrifices.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Column(
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
                          ),
                        ),
                      )
                    else
                      ...sacrifices.take(3).map((sacrifice) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: sacrifice.isCompleted 
                              ? AppColors.completed 
                              : AppColors.pending,
                            child: Text(
                              sacrifice.sacrificeNumber.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            '${sacrifice.animalType.toUpperCase()} - ${CurrencyUtils.format(sacrifice.totalCost ?? 0)}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            '${sacrifice.totalParticipants} participants • ${sacrifice.status}',
                          ),
                          trailing: Icon(
                            sacrifice.isCompleted 
                              ? Icons.check_circle 
                              : Icons.pending,
                            color: sacrifice.isCompleted 
                              ? AppColors.completed 
                              : AppColors.pending,
                          ),
                        ),
                      )),
                  ],
                ),
              ),
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FinancialRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isTotal;

  const _FinancialRow({
    required this.label,
    required this.amount,
    required this.color,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          CurrencyUtils.format(amount),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: color,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}