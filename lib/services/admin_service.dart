import 'http_service.dart';
import 'auth_service.dart';
import '../utils/api_constants.dart';

/// Admin-specific API calls: dashboard stats, pending bookings, slot blocking.
class AdminService {
  final HttpService _httpService = HttpService();
  final AuthService _authService = AuthService();

  String get _token {
    final t = _authService.getSavedToken();
    if (t == null) throw Exception('Not authenticated');
    return t;
  }

  // ─── Dashboard stats ──────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getDashboardStats() async {
    final response =
        await _httpService.get(ApiConstants.adminDashboard, token: _token);
    if (response['success'] == true) {
      return Map<String, dynamic>.from(response['stats'] ?? {});
    }
    throw Exception(response['error'] ?? 'Failed to load dashboard');
  }

  // ─── Pending bookings ─────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getPendingBookings() async {
    final response = await _httpService.get(
      ApiConstants.adminPendingBookings,
      token: _token,
    );
    if (response['success'] == true && response['bookings'] != null) {
      return List<Map<String, dynamic>>.from(response['bookings']);
    }
    return [];
  }

  // ─── Approve booking ──────────────────────────────────────────────────────
  Future<void> approveBooking(String bookingId) async {
    final response = await _httpService.post(
      ApiConstants.bookingsApprove,
      token: _token,
      body: {'booking_id': bookingId},
    );
    if (response['success'] != true) {
      throw Exception(response['error'] ?? 'Approval failed');
    }
  }

  // ─── Reject booking ───────────────────────────────────────────────────────
  Future<void> rejectBooking({
    required String bookingId,
    String? reason,
  }) async {
    final response = await _httpService.post(
      ApiConstants.bookingsReject,
      token: _token,
      body: {
        'booking_id': bookingId,
        'reason': reason ?? 'Rejected by admin',
      },
    );
    if (response['success'] != true) {
      throw Exception(response['error'] ?? 'Rejection failed');
    }
  }

  // ─── Block slots (Bulk) ───────────────────────────────────────────────────
  Future<void> blockSlots({
    required String turfId,
    required List<String> slotIds,
    required String blockedDate,
    required String reason,
    String? customReason,
  }) async {
    final response = await _httpService.post(
      ApiConstants.adminBlockSlot,
      token: _token,
      body: {
        'turf_id': turfId,
        'slot_ids': slotIds,
        'blocked_date': blockedDate,
        'reason': reason,
        if (customReason != null && customReason.isNotEmpty)
          'custom_reason': customReason,
      },
    );
    if (response['success'] != true) {
      throw Exception(response['error'] ?? 'Failed to block slots');
    }
  }

  // ─── Unblock a slot ───────────────────────────────────────────────────────
  Future<void> unblockSlot(String blockedSlotId) async {
    final response = await _httpService.delete(
      ApiConstants.adminUnblockSlot,
      token: _token,
      body: {'blocked_slot_id': blockedSlotId},
    );
    if (response['success'] != true) {
      throw Exception(response['error'] ?? 'Failed to unblock slot');
    }
  }

  // ─── Get blocked slots ────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getBlockedSlots({
    String? turfId,
    String? date,
  }) async {
    final params = <String, String>{};
    if (turfId != null) params['turf_id'] = turfId;
    if (date != null) params['date'] = date;

    final uri = Uri.parse(ApiConstants.adminGetBlockedSlots)
        .replace(queryParameters: params.isEmpty ? null : params);

    final response =
        await _httpService.get(uri.toString(), token: _token);

    if (response['success'] == true && response['blocked_slots'] != null) {
      return List<Map<String, dynamic>>.from(response['blocked_slots']);
    }
    return [];
  }
}
