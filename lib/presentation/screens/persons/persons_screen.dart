import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/person/person_cubit.dart';
import '../../../data/models/person.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/search_field.dart';
import 'add_person_screen.dart';
import 'edit_person_screen.dart';

class PersonsScreen extends StatefulWidget {
  const PersonsScreen({super.key});

  @override
  State<PersonsScreen> createState() => _PersonsScreenState();
}

class _PersonsScreenState extends State<PersonsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Persons'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SearchField(
            hintText: 'Search persons...',
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
              context.read<PersonCubit>().filterPersons(query);
            },
            onClear: () {
              setState(() {
                _searchQuery = '';
              });
              context.read<PersonCubit>().filterPersons('');
            },
          ),
          Expanded(
            child: BlocBuilder<PersonCubit, PersonState>(
              builder: (context, state) {
                if (state is PersonLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (state is PersonError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${state.message}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<PersonCubit>().loadPersons(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (state is PersonLoaded) {
                  final persons = state.persons;
                  
                  if (persons.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchQuery.isEmpty ? Icons.person_add : Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty 
                              ? 'No persons yet'
                              : 'No persons found',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isEmpty 
                              ? 'Add your first person to get started'
                              : 'Try a different search term',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return RefreshIndicator(
                    onRefresh: () async => context.read<PersonCubit>().loadPersons(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: persons.length,
                      itemBuilder: (context, index) {
                        final person = persons[index];
                        return _buildPersonCard(person);
                      },
                    ),
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddPerson(),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildPersonCard(Person person) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: person.hasContactInfo 
            ? AppColors.primaryGreen 
            : AppColors.pending,
          child: Text(
            person.firstname.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          person.fullName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (person.email != null || person.phone != null) ...[
              if (person.email != null)
                Text(
                  person.email!,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              if (person.phone != null)
                Text(
                  person.phone!,
                  style: TextStyle(color: Colors.grey[600]),
                ),
            ] else ...[
              Text(
                person.contactIntermediaryName != null
                  ? 'Contact via: ${person.contactIntermediaryName}'
                  : 'No contact info',
                style: TextStyle(
                  color: Colors.orange[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (person.totalParticipations > 0)
              Text(
                '${person.totalParticipations} participation${person.totalParticipations == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _navigateToEditPerson(person),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteDialog(person),
            ),
          ],
        ),
        onTap: () => _navigateToEditPerson(person),
      ),
    );
  }

  Future<void> _navigateToAddPerson() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddPersonScreen(),
      ),
    );
    
    if (result == true) {
      context.read<PersonCubit>().loadPersons();
    }
  }

  Future<void> _navigateToEditPerson(Person person) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditPersonScreen(person: person),
      ),
    );
    
    if (result == true) {
      context.read<PersonCubit>().loadPersons();
    }
  }

  Future<void> _showDeleteDialog(Person person) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Person'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete ${person.fullName}?'),
            if (person.totalParticipations > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Warning: This person has ${person.totalParticipations} participation${person.totalParticipations == 1 ? '' : 's'}.',
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

    if (confirmed == true && person.id != null) {
      try {
        await context.read<PersonCubit>().deletePerson(person.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Person deleted successfully'),
              backgroundColor: AppColors.completed,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting person: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}