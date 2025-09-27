part of 'sacrifice_cubit.dart';

abstract class SacrificeState extends Equatable {
  const SacrificeState();

  @override
  List<Object?> get props => [];
}

class SacrificeInitial extends SacrificeState {}

class SacrificeLoading extends SacrificeState {}

class SacrificeLoaded extends SacrificeState {
  final List<Sacrifice> sacrifices;

  const SacrificeLoaded(this.sacrifices);

  @override
  List<Object?> get props => [sacrifices];
}

class SacrificeDetailLoaded extends SacrificeState {
  final Sacrifice sacrifice;

  const SacrificeDetailLoaded(this.sacrifice);

  @override
  List<Object?> get props => [sacrifice];
}

class SacrificeError extends SacrificeState {
  final String message;

  const SacrificeError(this.message);

  @override
  List<Object?> get props => [message];
}