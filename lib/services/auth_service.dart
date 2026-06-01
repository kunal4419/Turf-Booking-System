import 'http_service.dart';
import 'local_storage_service.dart';
import '../utils/api_constants.dart';
import '../models/user_model.dart';

/// Handles authentication: login, signup, logout, and session management.
class AuthService {
  final HttpService _httpService = HttpService();
  final LocalStorageService _localStorage = LocalStorageService();

  // ─── Sign Up ─────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String name,
    String? phone,
    String role = 'customer',
  }) async {
    final response = await _httpService.post(
      ApiConstants.authSignup,
      body: {
        'email': email,
        'password': password,
        'name': name,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'role': role,
      },
    );

    if (response['success'] == true) {
      // Persist session if returned
      if (response['session'] != null) {
        final token = response['session']['access_token'];
        final refreshToken = response['session']['refresh_token'];
        if (token != null) await _localStorage.saveToken(token);
        if (refreshToken != null) {
          await _localStorage.saveRefreshToken(refreshToken);
        }
      }
      if (response['user'] != null) {
        final user = User.fromJson(response['user']);
        await _localStorage.saveUser(user);
      }
      return response;
    }
    throw Exception(response['error'] ?? 'Signup failed');
  }

  // ─── Login ───────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _httpService.post(
      ApiConstants.authLogin,
      body: {'email': email, 'password': password},
    );

    if (response['success'] == true) {
      final token = response['session']['access_token'];
      final refreshToken = response['session']['refresh_token'];
      final user = User.fromJson(response['user']);

      await _localStorage.saveToken(token);
      await _localStorage.saveUser(user);
      if (refreshToken != null) {
        await _localStorage.saveRefreshToken(refreshToken);
      }
      return response;
    }
    throw Exception(response['error'] ?? 'Login failed');
  }

  // ─── Logout ──────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      final token = getSavedToken();
      if (token != null) {
        await _httpService.post(
          ApiConstants.authLogout,
          body: {},
          token: token,
        );
      }
    } catch (_) {
      // Ignore server-side errors on logout; always clear local data.
    } finally {
      await _localStorage.clearAll();
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────
  User? getSavedUser() => _localStorage.getUser();
  String? getSavedToken() => _localStorage.getToken();
  bool isLoggedIn() => _localStorage.getToken() != null;

  Future<void> saveUser(User user) async {
    await _localStorage.saveUser(user);
  }

  Future<void> changePassword(String newPassword) async {
    final token = getSavedToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _httpService.put(
      '${ApiConstants.baseUrl}/auth/v1/user',
      token: token,
      body: {
        'password': newPassword,
      },
    );

    if (response == null || response['error'] != null) {
      throw Exception(response?['error'] ?? 'Failed to change password');
    }
  }
}
