import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:car_reservation_app/data/api/api_service.dart';
import 'package:car_reservation_app/data/local/secure_storage.dart';
import 'package:car_reservation_app/data/repositories/auth_repository_impl.dart';
import 'package:car_reservation_app/domain/repositories/auth_repository.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = ApiService.createDio();
  return dio;
});

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthRepositoryImpl(ApiService(dio), secureStorage);
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository, ref);
});

class AuthNotifier extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthNotifier(this._authRepository, this._ref) : super(false) {
    _checkLoggedIn();
  }

  Future<void> _checkLoggedIn() async {
    final token = await _authRepository.getAccessToken();
    state = token != null;
  }

  Future<bool> login(String username, String password) async {
    final success = await _authRepository.login(username, password);
    state = success;
    if (success) {
      _setupDioInterceptors();
    }
    return success;
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = false;
  }

  Future<bool> refreshToken() async {
    final success = await _authRepository.refreshToken();
    if (!success) {
      await logout();
    }
    return success;
  }

  void _setupDioInterceptors() {
    final dio = _ref.read(dioProvider);
    dio.interceptors.clear();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _authRepository.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer \$token';
        }
        return handler.next(options);
      },
      onError: (DioError error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await refreshToken();
          if (refreshed) {
            final requestOptions = error.requestOptions;
            final token = await _authRepository.getAccessToken();
            requestOptions.headers['Authorization'] = 'Bearer \$token';
            final response = await dio.fetch(requestOptions);
            return handler.resolve(response);
          } else {
            await logout();
          }
        }
        return handler.next(error);
      },
    ));
  }
}
