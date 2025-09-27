import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/participation.dart';
import '../../../data/repositories/participation_repository.dart';

part 'participation_state.dart';

class ParticipationCubit extends Cubit<ParticipationState> {
  final ParticipationRepository _repository;

  ParticipationCubit(this._repository) : super(ParticipationInitial());

  Future<void> loadParticipationsBySacrifice(int sacrificeId) async {
    try {
      emit(ParticipationLoading());
      final participations = await _repository.getParticipationsBySacrifice(sacrificeId);
      emit(ParticipationLoaded(participations));
    } catch (e) {
      emit(ParticipationError(e.toString()));
    }
  }

  Future<void> createParticipation(ParticipationCreateRequest request) async {
    try {
      await _repository.createParticipation(request);
      // Reload participations for the same sacrifice
      await loadParticipationsBySacrifice(request.sacrificeId);
    } catch (e) {
      emit(ParticipationError(e.toString()));
    }
  }

  Future<void> updateParticipation(int id, ParticipationCreateRequest request) async {
    try {
      await _repository.updateParticipation(id, request);
      // Reload participations for the same sacrifice
      await loadParticipationsBySacrifice(request.sacrificeId);
    } catch (e) {
      emit(ParticipationError(e.toString()));
    }
  }

  Future<void> deleteParticipation(int id, int sacrificeId) async {
    try {
      await _repository.deleteParticipation(id);
      // Reload participations for the same sacrifice
      await loadParticipationsBySacrifice(sacrificeId);
    } catch (e) {
      emit(ParticipationError(e.toString()));
    }
  }

  Future<void> markAsPaid(int id, double amount, int sacrificeId) async {
    try {
      await _repository.markParticipationPaid(id, amount);
      // Reload participations for the same sacrifice
      await loadParticipationsBySacrifice(sacrificeId);
    } catch (e) {
      emit(ParticipationError(e.toString()));
    }
  }
}