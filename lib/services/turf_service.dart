import 'http_service.dart';
import 'auth_service.dart';
import '../utils/api_constants.dart';
import '../models/turf_model.dart';
import '../models/slot_model.dart';

/// Handles all turf-related API calls using Supabase Edge Functions.
class TurfService {
  final HttpService _httpService = HttpService();
  final AuthService _authService = AuthService();

  String? get _token => _authService.getSavedToken();

  // ─── List turfs ───────────────────────────────────────────────────────────
  /// Calls /functions/v1/turfs-list with optional filters.
  Future<List<Turf>> getTurfs({
    String? sportId,
    String? location,
    String? ownerId, // For owner-specific listing (not yet a dedicated endpoint)
    int limit = 50,
    int offset = 0,
  }) async {
    final params = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (sportId != null) params['sport_id'] = sportId;
    if (location != null) params['location'] = location;

    final uri =
        Uri.parse(ApiConstants.turfsList).replace(queryParameters: params);
    final response = await _httpService.get(uri.toString());

    if (response['success'] == true && response['turfs'] != null) {
      final turfs = (response['turfs'] as List)
          .map((t) => Turf.fromJson(t))
          .toList();

      // Client-side filter for owner (no dedicated endpoint needed yet)
      if (ownerId != null) {
        return turfs.where((t) => t.ownerId == ownerId).toList();
      }
      return turfs;
    }
    return [];
  }

  // ─── Get turf by ID ───────────────────────────────────────────────────────
  /// Calls /functions/v1/turfs-get-by-id?turf_id=<id>
  /// Returns turf with facilities list included.
  Future<Turf> getTurfDetails(String turfId) async {
    final url = '${ApiConstants.turfsGetById}?turf_id=$turfId';
    final response = await _httpService.get(url);

    if (response['success'] == true && response['turf'] != null) {
      return Turf.fromJson(response['turf']);
    }
    throw Exception(response['error'] ?? 'Turf not found');
  }

  // ─── Get slot availability ────────────────────────────────────────────────
  /// Calls /functions/v1/turfs-availability?turf_id=<id>&date=<YYYY-MM-DD>
  Future<List<Slot>> getAvailability(String turfId, String date) async {
    final url =
        '${ApiConstants.turfsAvailability}?turf_id=$turfId&date=$date';
    final response = await _httpService.get(url);

    if (response['success'] == true && response['slots'] != null) {
      return (response['slots'] as List)
          .map((s) => Slot.fromJson(s))
          .toList();
    }
    return [];
  }

  // ─── Create turf ─────────────────────────────────────────────────────────
  Future<Turf> createTurf(Map<String, dynamic> turfData) async {
    if (_token == null) throw Exception('Not authenticated');

    final response = await _httpService.post(
      ApiConstants.turfsCreate,
      token: _token,
      body: turfData,
    );

    if (response['success'] == true && response['turf'] != null) {
      return Turf.fromJson(response['turf']);
    }
    throw Exception(response['error'] ?? 'Failed to create turf');
  }

  // ─── Update turf ──────────────────────────────────────────────────────────
  Future<Turf> updateTurf(String turfId, Map<String, dynamic> turfData) async {
    if (_token == null) throw Exception('Not authenticated');

    final response = await _httpService.post(
      ApiConstants.turfsUpdate,
      token: _token,
      body: {'turf_id': turfId, ...turfData},
    );

    if (response['success'] == true && response['turf'] != null) {
      return Turf.fromJson(response['turf']);
    }
    throw Exception(response['error'] ?? 'Failed to update turf');
  }

  // ─── Delete turf ──────────────────────────────────────────────────────────
  Future<void> deleteTurf(String turfId) async {
    if (_token == null) throw Exception('Not authenticated');

    final response = await _httpService.delete(
      ApiConstants.turfsDelete,
      token: _token,
      body: {'turf_id': turfId},
    );

    if (response['success'] != true) {
      throw Exception(response['error'] ?? 'Failed to delete turf');
    }
  }

  // ─── Add facility ─────────────────────────────────────────────────────────
  Future<void> addFacility(String turfId, String facilityName) async {
    if (_token == null) throw Exception('Not authenticated');

    await _httpService.post(
      ApiConstants.turfFacilitiesAdd,
      token: _token,
      body: {'turf_id': turfId, 'facility_name': facilityName},
    );
  }

  // ─── Delete facility ──────────────────────────────────────────────────────
  Future<void> deleteFacility(String turfId, String facilityName) async {
    if (_token == null) throw Exception('Not authenticated');

    await _httpService.delete(
      ApiConstants.turfFacilitiesDelete,
      token: _token,
      body: {'turf_id': turfId, 'facility_name': facilityName},
    );
  }
}
