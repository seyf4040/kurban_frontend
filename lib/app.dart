import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'presentation/cubits/config/config_cubit.dart';
import 'presentation/screens/main_navigation.dart';
import 'dependencies.dart';

class KurbanApp extends StatelessWidget {
  const KurbanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ConfigCubit>()..loadConfig(),
      child: BlocBuilder<ConfigCubit, ConfigState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Kurban Management',
            theme: AppTheme.getTheme(
              primaryColor: state.config?.primaryColor ?? Colors.green[800]!,
              accentColor: state.config?.accentColor ?? Colors.orange[100]!,
            ),
            home: const MainNavigation(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}