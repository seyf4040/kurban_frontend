import '../models/participation.dart';
import '../services/api_service.dart';

class ParticipationRepository {
  final ApiService _apiService;

  ParticipationRepository(this._apiService);

  Future<List<Participation>> getParticipationsBySacrifice(int sacrificeId) async {
    return await _apiService.getParticipationsBySacrifice(sacrificeId);
  }

  Future<Participation> createParticipation(ParticipationCreateRequest request) async {
    return await _apiService.createParticipation(request);
  }

  Future<Participation> updateParticipation(int id, ParticipationCreateRequest request) async {
    return await _apiService.updateParticipation(id, request);
  }

  Future<void> deleteParticipation(int id) async {
    await _apiService.deleteParticipation(id);
  }

  Future<Participation> markParticipationPaid(int id, double amount) async {
    return await _apiService.markParticipationPaid(id, amount);
  }
}