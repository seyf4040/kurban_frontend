import '../models/sacrifice.dart';
import '../services/api_service.dart';

class SacrificeRepository {
  final ApiService _apiService;

  SacrificeRepository(this._apiService);

  Future<List<Sacrifice>> getSacrifices() async {
    return await _apiService.getSacrifices();
  }

  Future<Sacrifice> getSacrificeById(int id) async {
    return await _apiService.getSacrificeById(id);
  }

  Future<Sacrifice> createSacrifice(SacrificeCreateRequest request) async {
    return await _apiService.createSacrifice(request);
  }

  Future<Sacrifice> updateSacrifice(int id, SacrificeCreateRequest request) async {
    return await _apiService.updateSacrifice(id, request);
  }

  Future<void> deleteSacrifice(int id) async {
    await _apiService.deleteSacrifice(id);
  }

  Future<Sacrifice> completeSacrifice(int id) async {
    return await _apiService.completeSacrifice(id);
  }

  Future<Sacrifice> cancelSacrifice(int id) async {
    return await _apiService.cancelSacrifice(id);
  }
}