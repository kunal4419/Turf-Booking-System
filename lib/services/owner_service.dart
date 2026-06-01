import 'http_service.dart';
import 'auth_service.dart';
import '../utils/api_constants.dart';

/// Service for all owner-related API endpoints.
class OwnerService {
  final HttpService _httpService = HttpService();
  final AuthService _authService = AuthService();

  String get _token {
    final t = _authService.getSavedToken();
    if (t == null) throw Exception('Not authenticated');
    return t;
  }

  // Fetch Owner Dashboard stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _httpService.get(ApiConstants.ownerDashboard, token: _token);
    if (response['success'] == true) {
      return Map<String, dynamic>.from(response['stats'] ?? {});
    }
    throw Exception(response['error'] ?? 'Failed to load dashboard stats');
  }

  // Fetch Booking requests for owner's turfs
  Future<List<Map<String, dynamic>>> getBookings({String? status}) async {
    final params = <String, String>{};
    if (status != null && status != 'All') params['status'] = status;

    final uri = Uri.parse(ApiConstants.ownerBookingsList)
        .replace(queryParameters: params.isEmpty ? null : params);

    final response = await _httpService.get(uri.toString(), token: _token);
    if (response['success'] == true && response['bookings'] != null) {
      return List<Map<String, dynamic>>.from(response['bookings']);
    }
    return [];
  }

  // Fetch Slot specific prices for pricing management
  Future<List<Map<String, dynamic>>> getSlotPricing(String turfId, String date) async {
    final uri = Uri.parse(ApiConstants.ownerSlotPricingList)
        .replace(queryParameters: {'turf_id': turfId, 'date': date});

    final response = await _httpService.get(uri.toString(), token: _token);
    if (response['success'] == true && response['slots'] != null) {
      return List<Map<String, dynamic>>.from(response['slots']);
    }
    return [];
  }

  // Update Slot specific pricing
  Future<void> updateSlotPricing(String turfId, String date, List<Map<String, dynamic>> slotPrices) async {
    final response = await _httpService.post(
      ApiConstants.ownerSlotPricingUpdate,
      token: _token,
      body: {
        'turf_id': turfId,
        'date': date,
        'slot_prices': slotPrices,
      },
    );
    if (response['success'] != true) {
      throw Exception(response['error'] ?? 'Failed to update slot pricing');
    }
  }

  // Approve a booking (owner uses standard approve API)
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

  // Reject a booking (owner uses standard reject API)
  Future<void> rejectBooking({required String bookingId, String? reason}) async {
    final response = await _httpService.post(
      ApiConstants.bookingsReject,
      token: _token,
      body: {
        'booking_id': bookingId,
        'reason': reason ?? 'Rejected by owner',
      },
    );
    if (response['success'] != true) {
      throw Exception(response['error'] ?? 'Rejection failed');
    }
  }

  // Create a direct booking on behalf of a customer (auto-approved)
  Future<Map<String, dynamic>> createDirectBooking({
    required String turfId,
    required String slotId,
    required String bookingDate,
    String? customerId,
    String? customerName,
    String? notes,
  }) async {
    final response = await _httpService.post(
      ApiConstants.ownerDirectBooking,
      token: _token,
      body: {
        'turf_id': turfId,
        'slot_id': slotId,
        'booking_date': bookingDate,
        if (customerId != null) 'customer_id': customerId,
        if (customerName != null) 'customer_name': customerName,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    if (response['success'] == true) return response;
    throw Exception(response['error'] ?? 'Direct booking failed');
  }

  // Fetch all registered customers (role = customer)
  Future<List<Map<String, dynamic>>> getCustomers() async {
    final uri = Uri.parse(ApiConstants.usersList)
        .replace(queryParameters: {'role': 'customer'});
    final response = await _httpService.get(uri.toString(), token: _token);
    if (response['success'] == true && response['users'] != null) {
      return List<Map<String, dynamic>>.from(response['users']);
    }
    return [];
  }

  // Fetch Turf Slots configuration
  Future<List<Map<String, dynamic>>> getTurfSlots(String turfId) async {
    final uri = Uri.parse(ApiConstants.ownerTurfSlotsList)
        .replace(queryParameters: {'turf_id': turfId});

    final response = await _httpService.get(uri.toString(), token: _token);
    if (response['success'] == true && response['slots'] != null) {
      return List<Map<String, dynamic>>.from(response['slots']);
    }
    return [];
  }

  // Update Turf Slots configuration
  Future<void> updateTurfSlots(String turfId, List<Map<String, dynamic>> slots) async {
    final response = await _httpService.post(
      ApiConstants.ownerTurfSlotsUpdate,
      token: _token,
      body: {
        'turf_id': turfId,
        'slots': slots,
      },
    );
    if (response['success'] != true) {
      throw Exception(response['error'] ?? 'Failed to save slot configurations');
    }
  }

  // ─── Block Slots ──────────────────────────────────────────────────────────
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

  // ─── Unblock a Slot ────────────────────────────────────────────────────────
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

  // ─── Get Blocked Slots ─────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getBlockedSlots({
    String? turfId,
    String? date,
  }) async {
    final params = <String, String>{};
    if (turfId != null) params['turf_id'] = turfId;
    if (date != null) params['date'] = date;

    final uri = Uri.parse(ApiConstants.adminGetBlockedSlots)
        .replace(queryParameters: params.isEmpty ? null : params);

    final response = await _httpService.get(uri.toString(), token: _token);
    if (response['success'] == true && response['blocked_slots'] != null) {
      return List<Map<String, dynamic>>.from(response['blocked_slots']);
    }
    return [];
  }
}
