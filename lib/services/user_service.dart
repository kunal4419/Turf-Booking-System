import 'http_service.dart';
import 'auth_service.dart';
import '../utils/api_constants.dart';
import '../models/user_model.dart';

/// Handles user-profile operations.
class UserService {
  final HttpService _httpService = HttpService();
  final AuthService _authService = AuthService();

  String get _token => _authService.getSavedToken() ?? '';

  // ─── Get current user profile ─────────────────────────────────────────────
  Future<User> getCurrentUser() async {
    final response =
        await _httpService.get(ApiConstants.userGetCurrent, token: _token);
    if (response['success'] == true) {
      return User.fromJson(response['user']);
    }
    throw Exception(response['error'] ?? 'Failed to fetch user');
  }

  // ─── Get user by ID ───────────────────────────────────────────────────────
  Future<User> getUserById(String userId) async {
    final url = '${ApiConstants.userGetById}?user_id=$userId';
    final response = await _httpService.get(url, token: _token);
    if (response['success'] == true) {
      return User.fromJson(response['user']);
    }
    throw Exception(response['error'] ?? 'User not found');
  }

  // ─── List users by role ───────────────────────────────────────────────────
  Future<List<User>> listUsers({String? role}) async {
    final url = role != null
        ? '${ApiConstants.usersList}?role=$role'
        : ApiConstants.usersList;
    final response = await _httpService.get(url, token: _token);
    if (response['success'] == true && response['users'] != null) {
      final List<dynamic> list = response['users'];
      return list.map((u) => User.fromJson(u)).toList();
    }
    throw Exception(response['error'] ?? 'Failed to list users');
  }

  // ─── Update profile ───────────────────────────────────────────────────────
  Future<User> updateProfile({
    String? name,
    String? phone,
    String? location,
    String? profileImageUrl,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (location != null) body['location'] = location;
    if (profileImageUrl != null) body['profile_image_url'] = profileImageUrl;

    final response = await _httpService.post(
      ApiConstants.userUpdateProfile,
      body: body,
      token: _token,
    );
    if (response['success'] == true) {
      return User.fromJson(response['user']);
    }
    throw Exception(response['error'] ?? 'Failed to update profile');
  }
}
