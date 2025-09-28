import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/person/person_cubit.dart';
import '../cubits/sacrifice/sacrifice_cubit.dart';
import 'home/home_screen.dart';
import 'persons/persons_screen.dart';
import 'sacrifices/sacrifices_screen.dart';
import 'settings/settings_screen.dart';
import '../../dependencies.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const PersonsScreen(),
    const SacrificesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ✅ FIXED: Use singleton instances instead of creating new ones
        BlocProvider.value(value: getIt<PersonCubit>()..loadPersons()),
        BlocProvider.value(value: getIt<SacrificeCubit>()..loadSacrifices()),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Persons',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.agriculture),
              label: 'Sacrifices',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}