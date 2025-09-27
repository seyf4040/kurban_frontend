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

  // Cubits
  getIt.registerFactory<PersonCubit>(
    () => PersonCubit(getIt<PersonRepository>()),
  );
  getIt.registerFactory<SacrificeCubit>(
    () => SacrificeCubit(getIt<SacrificeRepository>()),
  );
  getIt.registerFactory<ParticipationCubit>(
    () => ParticipationCubit(getIt<ParticipationRepository>()),
  );
  getIt.registerLazySingleton<ConfigCubit>(
    () => ConfigCubit(getIt<ConfigRepository>()),
  );
}