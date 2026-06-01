import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized API endpoint constants.
/// All edge functions are accessed via /functions/v1/<slug>
class ApiConstants {
  // ─── Base ───────────────────────────────────────────────────────────────────
  static String get baseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://your-project.supabase.co';

  static String get anonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? 'your-anon-key-here';

  static String get functionsBase => '$baseUrl/functions/v1';

  // ─── Auth ────────────────────────────────────────────────────────────────────
  static String get authLogin => '$functionsBase/auth-login';
  static String get authSignup => '$functionsBase/auth-signup';
  static String get authLogout => '$functionsBase/auth-logout';

  // ─── User ────────────────────────────────────────────────────────────────────
  static String get userGetCurrent => '$functionsBase/user-get-current';
  static String get userGetById => '$functionsBase/user-get-by-id';
  static String get userUpdateProfile => '$functionsBase/user-update-profile';
  static String get usersList => '$functionsBase/users-list';

  // ─── Sports ──────────────────────────────────────────────────────────────────
  static String get sportsList => '$functionsBase/sports-list';
  static String get sportsCreate => '$functionsBase/sports-create';

  // ─── Turfs ───────────────────────────────────────────────────────────────────
  static String get turfsList => '$functionsBase/turfs-list';
  static String get turfsGetById => '$functionsBase/turfs-get-by-id';
  static String get turfsCreate => '$functionsBase/turfs-create';
  static String get turfsUpdate => '$functionsBase/turfs-update';
  static String get turfsDelete => '$functionsBase/turfs-delete';
  static String get turfsAvailability => '$functionsBase/turfs-availability';

  // ─── Turf Facilities ─────────────────────────────────────────────────────────
  static String get turfFacilitiesList => '$functionsBase/turf-facilities-list';
  static String get turfFacilitiesAdd => '$functionsBase/turf-facilities-add';
  static String get turfFacilitiesDelete =>
      '$functionsBase/turf-facilities-delete';

  // ─── Slots ───────────────────────────────────────────────────────────────────
  static String get slotsList => '$functionsBase/slots-list';

  // ─── Bookings ────────────────────────────────────────────────────────────────
  static String get bookingsList => '$functionsBase/bookings-list';
  static String get bookingsCreate => '$functionsBase/bookings-create';
  static String get bookingsGetById => '$functionsBase/bookings-get-by-id';
  static String get bookingsGetDetails => '$functionsBase/bookings-get-details';
  static String get bookingsUpdateStatus =>
      '$functionsBase/bookings-update-status';
  static String get bookingsApprove => '$functionsBase/bookings-approve';
  static String get bookingsReject => '$functionsBase/bookings-reject';
  static String get bookingsCancel => '$functionsBase/bookings-cancel';
  static String get bookingsDelete => '$functionsBase/bookings-delete';

  // ─── Notifications ───────────────────────────────────────────────────────────
  static String get notificationsList => '$functionsBase/notifications-list';
  static String get notificationsMarkRead =>
      '$functionsBase/notifications-mark-read';
  static String get notificationsDelete => '$functionsBase/notifications-delete';

  // ─── Admin ───────────────────────────────────────────────────────────────────
  static String get adminDashboard => '$functionsBase/admin-dashboard';
  static String get adminPendingBookings =>
      '$functionsBase/admin-pending-bookings';
  static String get adminBlockSlot => '$functionsBase/admin-block-slot';
  static String get adminUnblockSlot => '$functionsBase/admin-unblock-slot';
  static String get adminGetBlockedSlots =>
      '$functionsBase/admin-get-blocked-slots';

  // ─── Owner ───────────────────────────────────────────────────────────────────
  static String get ownerDashboard => '$functionsBase/owner-dashboard';
  static String get ownerBookingsList => '$functionsBase/owner-bookings-list';
  static String get ownerSlotPricingList =>
      '$functionsBase/owner-slot-pricing-list';
  static String get ownerSlotPricingUpdate =>
      '$functionsBase/owner-slot-pricing-update';
  static String get ownerDirectBooking =>
      '$functionsBase/owner-direct-booking';
  static String get ownerTurfSlotsList =>
      '$functionsBase/owner-turf-slots-list';
  static String get ownerTurfSlotsUpdate =>
      '$functionsBase/owner-turf-slots-update';
}
