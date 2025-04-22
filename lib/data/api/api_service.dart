import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  // Base URL of the backend API
  static const String baseUrl = 'https://your-api-base-url.com/api';

  // Initialize Dio with base options
  static Dio createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: 5000,
      receiveTimeout: 3000,
      headers: {
        'Content-Type': 'application/json',
      },
    ));
    return dio;
  }

  // Login with username and password, returns access and refresh tokens
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'username': username,
      'password': password,
    });
    return response.data;
  }

  // Refresh access token using refresh token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _dio.post('/auth/refresh', data: {
      'refresh_token': refreshToken,
    });
    return response.data;
  }

  // Logout endpoint
  Future<void> logout(String refreshToken) async {
    await _dio.post('/auth/logout', data: {
      'refresh_token': refreshToken,
    });
  }

  // Other API methods for reservation, join, process, complete, profile, etc. will be added here

  // Submit reservation without authentication
  Future<void> submitReservation(Map<String, dynamic> reservationData) async {
    await _dio.post('/reservasi', data: reservationData);
  }

  // Get list of reservations (requires authentication)
  Future<List<dynamic>> getReservations() async {
    final response = await _dio.get('/reservasi');
    return response.data as List<dynamic>;
  }

  // Join a reservation by id
  Future<void> joinReservation(String reservationId) async {
    await _dio.post('/reservasi/\$reservationId/join');
  }

  // Process a reservation by id
  Future<void> processReservation(String reservationId) async {
    await _dio.post('/reservasi/\$reservationId/process');
  }

  // Finish a reservation by id with description and photos
  Future<void> finishReservation(String reservationId, String description, List<String> photoUrls) async {
    await _dio.post('/reservasi/\$reservationId/finish', data: {
      'description': description,
      'photos': photoUrls,
    });
  }
}
