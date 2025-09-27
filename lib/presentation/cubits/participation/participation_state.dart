part of 'participation_cubit.dart';

abstract class ParticipationState extends Equatable {
  const ParticipationState();

  @override
  List<Object?> get props => [];
}

class ParticipationInitial extends ParticipationState {}

class ParticipationLoading extends ParticipationState {}

class ParticipationLoaded extends ParticipationState {
  final List<Participation> participations;

  const ParticipationLoaded(this.participations);

  @override
  List<Object?> get props => [participations];
}

class ParticipationError extends ParticipationState {
  final String message;

  const ParticipationError(this.message);

  @override
  List<Object?> get props => [message];
}