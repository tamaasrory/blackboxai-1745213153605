abstract class AuthRepository {
  Future<bool> login(String username, String password);
  Future<void> logout();
  Future<bool> refreshToken();
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
}
