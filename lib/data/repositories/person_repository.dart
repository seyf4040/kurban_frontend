import '../models/person.dart';
import '../services/api_service.dart';

class PersonRepository {
  final ApiService _apiService;

  PersonRepository(this._apiService);

  Future<List<Person>> getPersons() async {
    return await _apiService.getPersons();
  }

  Future<Person> getPersonById(int id) async {
    return await _apiService.getPersonById(id);
  }

  Future<Person> createPerson(PersonCreateRequest request) async {
    return await _apiService.createPerson(request);
  }

  Future<Person> updatePerson(int id, PersonCreateRequest request) async {
    return await _apiService.updatePerson(id, request);
  }

  Future<void> deletePerson(int id) async {
    await _apiService.deletePerson(id);
  }
}