import '../models/app_config.dart';
import '../services/api_service.dart';

class ConfigRepository {
  final ApiService _apiService;

  ConfigRepository(this._apiService);

  Future<AppConfig> getConfig() async {
    return await _apiService.getConfig();
  }

  Future<AppConfig> updateConfig(AppConfig config) async {
    return await _apiService.updateConfig(config);
  }
}