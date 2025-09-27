import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/app_config.dart';
import '../../../data/repositories/config_repository.dart';

part 'config_state.dart';

class ConfigCubit extends Cubit<ConfigState> {
  final ConfigRepository _repository;

  ConfigCubit(this._repository) : super(ConfigInitial());

  Future<void> loadConfig() async {
    try {
      emit(ConfigLoading());
      final config = await _repository.getConfig();
      emit(ConfigLoaded(config));
    } catch (e) {
      // If config fails to load, use default config
      emit(ConfigLoaded(const AppConfig()));
    }
  }

  Future<void> updateConfig(AppConfig config) async {
    try {
      emit(ConfigLoading());
      final updatedConfig = await _repository.updateConfig(config);
      emit(ConfigLoaded(updatedConfig));
    } catch (e) {
      emit(ConfigError(e.toString()));
    }
  }
}