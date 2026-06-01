import 'http_service.dart';
import 'auth_service.dart';
import '../utils/api_constants.dart';
import '../models/sport_model.dart';

/// Handles sports listing and creation via Edge Functions.
class SportService {
  final HttpService _httpService = HttpService();
  final AuthService _authService = AuthService();

  // ─── List all sports ──────────────────────────────────────────────────────
  Future<List<Sport>> getSports() async {
    final response = await _httpService.get(ApiConstants.sportsList);

    if (response['success'] == true && response['sports'] != null) {
      return (response['sports'] as List)
          .map((s) => Sport.fromJson(s))
          .toList();
    }
    // Fallback: some implementations return a plain list
    if (response is List) {
      return response.map((s) => Sport.fromJson(s)).toList();
    }
    return [];
  }

  // ─── Create sport (admin only) ───────────────────────────────────────────
  Future<Sport> createSport(
    String name, {
    String? iconUrl,
    String? description,
  }) async {
    final token = _authService.getSavedToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _httpService.post(
      ApiConstants.sportsCreate,
      token: token,
      body: {
        'name': name,
        if (iconUrl != null) 'icon_url': iconUrl,
        if (description != null) 'description': description,
      },
    );

    if (response['success'] == true && response['sport'] != null) {
      return Sport.fromJson(response['sport']);
    }
    throw Exception(response['error'] ?? 'Failed to create sport');
  }
}
