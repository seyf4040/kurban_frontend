import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/person.dart';
import '../../../data/repositories/person_repository.dart';

part 'person_state.dart';

class PersonCubit extends Cubit<PersonState> {
  final PersonRepository _repository;

  PersonCubit(this._repository) : super(PersonInitial());

  Future<void> loadPersons() async {
    try {
      emit(PersonLoading());
      final persons = await _repository.getPersons();
      emit(PersonLoaded(persons));
    } catch (e) {
      emit(PersonError(e.toString()));
    }
  }

  Future<void> createPerson(PersonCreateRequest request) async {
    try {
      emit(PersonLoading());
      await _repository.createPerson(request);
      await loadPersons(); // Reload list
    } catch (e) {
      emit(PersonError(e.toString()));
    }
  }

  Future<void> updatePerson(int id, PersonUpdateRequest request) async {
    try {
      emit(PersonLoading());
      await _repository.updatePerson(id, request);
      await loadPersons(); // Reload list
    } catch (e) {
      emit(PersonError(e.toString()));
    }
  }

  Future<void> deletePerson(int id) async {
    try {
      emit(PersonLoading());
      await _repository.deletePerson(id);
      await loadPersons(); // Reload list
    } catch (e) {
      emit(PersonError(e.toString()));
    }
  }

  void filterPersons(String query) {
    if (state is PersonLoaded) {
      final currentState = state as PersonLoaded;
      if (query.isEmpty) {
        emit(PersonLoaded(currentState.allPersons));
      } else {
        final filtered = currentState.allPersons
            .where((person) =>
                person.fullName.toLowerCase().contains(query.toLowerCase()) ||
                (person.email?.toLowerCase().contains(query.toLowerCase()) ?? false))
            .toList();
        emit(PersonLoaded(filtered, allPersons: currentState.allPersons));
      }
    }
  }
}