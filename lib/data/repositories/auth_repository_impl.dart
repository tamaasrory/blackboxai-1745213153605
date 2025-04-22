import 'package:car_reservation_app/data/api/api_service.dart';
import 'package:car_reservation_app/data/local/secure_storage.dart';
import 'package:car_reservation_app/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;
  final SecureStorage _secureStorage;

  AuthRepositoryImpl(this._apiService, this._secureStorage);

  @override
  Future<bool> login(String username, String password) async {
    try {
      final data = await _apiService.login(username, password);
      final accessToken = data['access_token'] as String?;
      final refreshToken = data['refresh_token'] as String?;
      if (accessToken != null && refreshToken != null) {
        await _secureStorage.saveAccessToken(accessToken);
        await _secureStorage.saveRefreshToken(refreshToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken != null) {
      await _apiService.logout(refreshToken);
    }
    await _secureStorage.clearTokens();
  }

  @override
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) return false;
      final data = await _apiService.refreshToken(refreshToken);
      final newAccessToken = data['access_token'] as String?;
      final newRefreshToken = data['refresh_token'] as String?;
      if (newAccessToken != null && newRefreshToken != null) {
        await _secureStorage.saveAccessToken(newAccessToken);
        await _secureStorage.saveRefreshToken(newRefreshToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getAccessToken() async {
    return await _secureStorage.getAccessToken();
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _secureStorage.getRefreshToken();
  }
}
