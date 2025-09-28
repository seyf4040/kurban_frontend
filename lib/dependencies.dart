import 'package:get_it/get_it.dart';
import 'data/services/api_service.dart';
import 'data/repositories/person_repository.dart';
import 'data/repositories/sacrifice_repository.dart';
import 'data/repositories/participation_repository.dart';
import 'data/repositories/config_repository.dart';
import 'presentation/cubits/person/person_cubit.dart';
import 'presentation/cubits/sacrifice/sacrifice_cubit.dart';
import 'presentation/cubits/participation/participation_cubit.dart';
import 'presentation/cubits/config/config_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Services
  getIt.registerLazySingleton<ApiService>(() => ApiService());

  // Repositories
  getIt.registerLazySingleton<PersonRepository>(
    () => PersonRepository(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<SacrificeRepository>(
    () => SacrificeRepository(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<ParticipationRepository>(
    () => ParticipationRepository(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<ConfigRepository>(
    () => ConfigRepository(getIt<ApiService>()),
  );

  // ✅ FIXED: Change to LazySingleton for state persistence
  // This ensures the same cubit instance is used throughout the app
  getIt.registerLazySingleton<PersonCubit>(
    () => PersonCubit(getIt<PersonRepository>()),
  );
  getIt.registerLazySingleton<SacrificeCubit>(
    () => SacrificeCubit(getIt<SacrificeRepository>()),
  );
  
  // ParticipationCubit can remain factory as it's context-specific
  getIt.registerFactory<ParticipationCubit>(
    () => ParticipationCubit(getIt<ParticipationRepository>()),
  );
  
  getIt.registerLazySingleton<ConfigCubit>(
    () => ConfigCubit(getIt<ConfigRepository>()),
  );
}