import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/sacrifice.dart';
import '../../../data/repositories/sacrifice_repository.dart';

part 'sacrifice_state.dart';

class SacrificeCubit extends Cubit<SacrificeState> {
  final SacrificeRepository _repository;

  SacrificeCubit(this._repository) : super(SacrificeInitial());

  Future<void> loadSacrifices() async {
    try {
      emit(SacrificeLoading());
      final sacrifices = await _repository.getSacrifices();
      emit(SacrificeLoaded(sacrifices));
    } catch (e) {
      emit(SacrificeError(e.toString()));
    }
  }

  Future<void> loadSacrificeById(int id) async {
    try {
      emit(SacrificeLoading());
      final sacrifice = await _repository.getSacrificeById(id);
      emit(SacrificeDetailLoaded(sacrifice));
    } catch (e) {
      emit(SacrificeError(e.toString()));
    }
  }

  Future<void> createSacrifice(SacrificeCreateRequest request) async {
    try {
      emit(SacrificeLoading());
      await _repository.createSacrifice(request);
      await loadSacrifices(); // Reload list
    } catch (e) {
      emit(SacrificeError(e.toString()));
    }
  }

  Future<void> updateSacrifice(int id, SacrificeCreateRequest request) async {
    try {
      emit(SacrificeLoading());
      await _repository.updateSacrifice(id, request);
      await loadSacrifices(); // Reload list
    } catch (e) {
      emit(SacrificeError(e.toString()));
    }
  }

  Future<void> deleteSacrifice(int id) async {
    try {
      emit(SacrificeLoading());
      await _repository.deleteSacrifice(id);
      await loadSacrifices(); // Reload list
    } catch (e) {
      emit(SacrificeError(e.toString()));
    }
  }

  Future<void> completeSacrifice(int id) async {
    try {
      await _repository.completeSacrifice(id);
      await loadSacrifices(); // Reload list
    } catch (e) {
      emit(SacrificeError(e.toString()));
    }
  }

  Future<void> cancelSacrifice(int id) async {
    try {
      await _repository.cancelSacrifice(id);
      await loadSacrifices(); // Reload list
    } catch (e) {
      emit(SacrificeError(e.toString()));
    }
  }
}