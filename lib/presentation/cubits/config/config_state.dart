part of 'config_cubit.dart';

abstract class ConfigState extends Equatable {
  const ConfigState();

  AppConfig? get config => null;

  @override
  List<Object?> get props => [];
}

class ConfigInitial extends ConfigState {}

class ConfigLoading extends ConfigState {}

class ConfigLoaded extends ConfigState {
  @override
  final AppConfig config;

  const ConfigLoaded(this.config);

  @override
  List<Object?> get props => [config];
}

class ConfigError extends ConfigState {
  final String message;

  const ConfigError(this.message);

  @override
  List<Object?> get props => [message];
}