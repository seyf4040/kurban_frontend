import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/person.dart';
import '../models/sacrifice.dart';
import '../models/participation.dart';
import '../models/app_config.dart';
import '../../core/constants/api_endpoints.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
    
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ));
  }

  // Persons API
  Future<List<Person>> getPersons() async {
    final response = await _dio.get(ApiEndpoints.persons);
    return (response.data as List).map((json) => Person.fromJson(json)).toList();
  }

  Future<Person> getPersonById(int id) async {
    final response = await _dio.get(ApiEndpoints.personById(id));
    return Person.fromJson(response.data);
  }

  Future<Person> createPerson(PersonCreateRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.persons,
      data: request.toJson(),
    );
    return Person.fromJson(response.data);
  }

  Future<Person> updatePerson(int id, PersonCreateRequest request) async {
    final response = await _dio.put(
      ApiEndpoints.personById(id),
      data: request.toJson(),
    );
    return Person.fromJson(response.data);
  }

  Future<void> deletePerson(int id) async {
    await _dio.delete(ApiEndpoints.personById(id));
  }

  // Sacrifices API
  Future<List<Sacrifice>> getSacrifices() async {
    final response = await _dio.get(ApiEndpoints.sacrifices);
    return (response.data as List).map((json) => Sacrifice.fromJson(json)).toList();
  }

  Future<Sacrifice> getSacrificeById(int id) async {
    final response = await _dio.get(ApiEndpoints.sacrificeById(id));
    return Sacrifice.fromJson(response.data);
  }

  Future<Sacrifice> createSacrifice(SacrificeCreateRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.sacrifices,
      data: request.toJson(),
    );
    return Sacrifice.fromJson(response.data);
  }

  Future<Sacrifice> updateSacrifice(int id, SacrificeCreateRequest request) async {
    final response = await _dio.put(
      ApiEndpoints.sacrificeById(id),
      data: request.toJson(),
    );
    return Sacrifice.fromJson(response.data);
  }

  Future<void> deleteSacrifice(int id) async {
    await _dio.delete(ApiEndpoints.sacrificeById(id));
  }

  Future<Sacrifice> completeSacrifice(int id) async {
    final response = await _dio.put(ApiEndpoints.completeSacrifice(id));
    return Sacrifice.fromJson(response.data);
  }

  Future<Sacrifice> cancelSacrifice(int id) async {
    final response = await _dio.put(ApiEndpoints.cancelSacrifice(id));
    return Sacrifice.fromJson(response.data);
  }

  // Participations API
  Future<List<Participation>> getParticipationsBySacrifice(int sacrificeId) async {
    final response = await _dio.get(ApiEndpoints.participationsBySacrifice(sacrificeId));
    return (response.data as List).map((json) => Participation.fromJson(json)).toList();
  }

  Future<Participation> createParticipation(ParticipationCreateRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.participations,
      data: request.toJson(),
    );
    return Participation.fromJson(response.data);
  }

  Future<Participation> updateParticipation(int id, ParticipationCreateRequest request) async {
    final response = await _dio.put(
      ApiEndpoints.participationById(id),
      data: request.toJson(),
    );
    return Participation.fromJson(response.data);
  }

  Future<void> deleteParticipation(int id) async {
    await _dio.delete(ApiEndpoints.participationById(id));
  }

  Future<Participation> markParticipationPaid(int id, double amount) async {
    final response = await _dio.put(
      ApiEndpoints.markParticipationPaid(id),
      data: amount,
    );
    return Participation.fromJson(response.data);
  }

  // Config API
  Future<AppConfig> getConfig() async {
    final response = await _dio.get(ApiEndpoints.config);
    return AppConfig.fromJson(response.data);
  }

  Future<AppConfig> updateConfig(AppConfig config) async {
    final response = await _dio.put(
      ApiEndpoints.config,
      data: config.toJson(),
    );
    return AppConfig.fromJson(response.data);
  }
}