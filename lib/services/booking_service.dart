import 'http_service.dart';
import 'auth_service.dart';
import '../models/booking_model.dart';
import '../utils/api_constants.dart';

/// Handles all booking operations using Supabase Edge Functions.
class BookingService {
  final HttpService _httpService = HttpService();
  final AuthService _authService = AuthService();

  String get _token {
    final t = _authService.getSavedToken();
    if (t == null) throw Exception('Not authenticated');
    return t;
  }

  // ─── Create booking ───────────────────────────────────────────────────────
  /// POST /functions/v1/bookings-create
  Future<Map<String, dynamic>> createBooking({
    required String turfId,
    required String slotId,
    required String bookingDate,
    String? notes,
  }) async {
    final response = await _httpService.post(
      ApiConstants.bookingsCreate,
      token: _token,
      body: {
        'turf_id': turfId,
        'slot_id': slotId,
        'booking_date': bookingDate,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );

    if (response['success'] == true) return response;
    throw Exception(response['error'] ?? 'Booking creation failed');
  }

  // ─── List my bookings ─────────────────────────────────────────────────────
  /// GET /functions/v1/bookings-list?status=<optional>
  Future<List<Booking>> getMyBookings({String? status}) async {
    final params = <String, String>{};
    if (status != null) params['status'] = status;

    final uri = Uri.parse(ApiConstants.bookingsList)
        .replace(queryParameters: params.isEmpty ? null : params);

    final response = await _httpService.get(uri.toString(), token: _token);

    if (response['success'] == true && response['bookings'] != null) {
      return (response['bookings'] as List)
          .map((b) => Booking.fromJson(b))
          .toList();
    }
    return [];
  }

  // ─── Get booking details ──────────────────────────────────────────────────
  /// GET /functions/v1/bookings-get-details?booking_id=<id>
  Future<Booking> getBookingDetails(String bookingId) async {
    final url =
        '${ApiConstants.bookingsGetDetails}?booking_id=$bookingId';
    final response = await _httpService.get(url, token: _token);

    if (response['success'] == true && response['booking'] != null) {
      return Booking.fromJson(response['booking']);
    }
    throw Exception(response['error'] ?? 'Booking not found');
  }

  // ─── Cancel booking ───────────────────────────────────────────────────────
  Future<Map<String, dynamic>> cancelBooking(String bookingId) async {
    final response = await _httpService.post(
      ApiConstants.bookingsCancel,
      token: _token,
      body: {'booking_id': bookingId},
    );
    if (response['success'] == true) return response;
    throw Exception(response['error'] ?? 'Cancellation failed');
  }

  // ─── Admin: Approve booking ───────────────────────────────────────────────
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

  // ─── Admin: Reject booking ────────────────────────────────────────────────
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

  // ─── Get turf bookings (owner) ────────────────────────────────────────────
  /// Fetches bookings but filters by turf_id client-side since the
  /// bookings-list function returns bookings for the authenticated user.
  /// For owner functionality we use the same endpoint with an owner token.
  Future<List<Booking>> getTurfBookings(String turfId) async {
    // Fetch all and filter by turf_id
    final all = await getMyBookings();
    return all.where((b) => b.turfId == turfId).toList();
  }
}
