import 'dart:ui';

import 'package:get/get.dart';
import '../services/admin_service.dart';
import '../services/turf_service.dart';
import '../services/user_service.dart';
import '../models/turf_model.dart';
import '../models/slot_model.dart';
import '../models/user_model.dart';
import '../models/booking_model.dart';

/// GetX controller for all admin-related operations.
///
/// Consumed by:
///   - AdminDashboardScreen  → getDashboardStats(), getTodaysBookings()
///   - TurfManagementScreen  → getAllTurfs(), deleteTurf()
///   - BookingRequestsScreen → getPendingBookings(), approveBooking(), rejectBooking()
///   - BlockSlotsScreen      → getSlots(), getAllTurfs(), getBlockedSlots(),
///                             blockSlots(), unblockSlot(), toggleSlot()
class AdminController extends GetxController {
  final AdminService _adminService = AdminService();
  final TurfService _turfService = TurfService();
  final UserService _userService = UserService();

  // ─── Tab navigation ────────────────────────────────────────────────────────
  var adminTabIndex = 0.obs;

  void changeTab(int index) {
    adminTabIndex.value = index;
    if (index == 0) loadDashboardData();
    if (index == 1) getAllTurfs();
    if (index == 2) getPendingBookings();
    if (index == 3) {
      getSlots();
      getAllTurfs();
    }
  }

  // ─── Loading states ────────────────────────────────────────────────────────
  var isLoading = false.obs;
  var isProcessing = false.obs; // approve / reject
  var isBlocking = false.obs;   // block-slot
  var errorMessage = ''.obs;

  // ─── Dashboard data ────────────────────────────────────────────────────────
  var totalBookings = 0.obs;
  var pendingBookings = 0.obs;
  var todayBookings = 0.obs;
  var totalRevenue = 0.0.obs;
  var totalTurfs = 0.obs;
  var totalCustomers = 0.obs;
  var todaysBookingsList = RxList<dynamic>();

  // ─── Turfs ─────────────────────────────────────────────────────────────────
  var turfs = RxList<Turf>();
  var turfOwners = RxList<User>();
  var isLoadingOwners = false.obs;

  // ─── Pending requests ──────────────────────────────────────────────────────
  var pendingRequests = RxList<Map<String, dynamic>>();

  // ─── Slot blocking ─────────────────────────────────────────────────────────
  var allSlots = RxList<Slot>();
  var blockedSlots = RxList<Map<String, dynamic>>();
  var selectedSlotIds = <String>[].obs;
  var selectedOwnerId = Rx<String?>(null);
  var selectedTurfId = Rx<String?>(null);
  var selectedDate = Rx<DateTime?>(null);
  var selectedReason = Rx<String?>(null);
  var customReason = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Dashboard
  // ─────────────────────────────────────────────────────────────────────────

  /// Convenience method called on every admin tab change.
  Future<void> loadDashboardData() async {
    await Future.wait([
      getDashboardStats(),
      getTodaysBookings(),
    ]);
  }

  Future<void> getDashboardStats() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final stats = await _adminService.getDashboardStats();
      totalBookings.value = (stats['total_bookings'] as num?)?.toInt() ?? 0;
      pendingBookings.value = (stats['pending_bookings'] as num?)?.toInt() ?? 0;
      todayBookings.value = (stats['today_bookings'] as num?)?.toInt() ?? 0;
      totalRevenue.value = (stats['total_revenue'] as num?)?.toDouble() ?? 0.0;
      totalTurfs.value = (stats['total_turfs'] as num?)?.toInt() ?? 0;
      totalCustomers.value = (stats['total_customers'] as num?)?.toInt() ?? 0;
    } catch (e) {
      errorMessage.value = _clean(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getTodaysBookings() async {
    try {
      final pending = await _adminService.getPendingBookings();
      final today = _todayStr();
      todaysBookingsList.value = pending
          .where((b) => b['booking_date'] == today)
          .map((b) => Booking.fromJson(b))
          .toList();
    } catch (_) {
      todaysBookingsList.value = [];
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Turfs
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> getAllTurfs() async {
    isLoading.value = true;
    try {
      turfs.value = await _turfService.getTurfs(limit: 100);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load turfs: ${_clean(e)}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTurf(String turfId) async {
    try {
      await _turfService.deleteTurf(turfId);
      turfs.removeWhere((t) => t.id == turfId);
      Get.snackbar('Deleted', 'Turf deleted successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Delete failed: ${_clean(e)}',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> getTurfOwners() async {
    isLoadingOwners.value = true;
    try {
      turfOwners.value = await _userService.listUsers(role: 'turf_owner');
    } catch (e) {
      Get.snackbar('Error', 'Failed to load turf owners: ${_clean(e)}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingOwners.value = false;
    }
  }

  Future<bool> createTurf({
    required String name,
    required String sportId,
    required String location,
    required double pricePerSlot,
    required String ownerId,
    String? description,
    String? rules,
    List<String>? imageUrls,
    required List<String> selectedFacilities,
  }) async {
    isProcessing.value = true;
    try {
      final turfData = {
        'name': name,
        'sport_id': sportId,
        'location': location,
        'price_per_slot': pricePerSlot,
        'owner_id': ownerId,
        'description': description,
        'rules': rules,
        'image_urls': imageUrls ?? [],
      };
      final newTurf = await _turfService.createTurf(turfData);
      
      // Add facilities
      for (final facility in selectedFacilities) {
        await _turfService.addFacility(newTurf.id, facility);
      }
      
      // Fetch detailed turf to populate facilities in controller list
      final detailed = await _turfService.getTurfDetails(newTurf.id);
      turfs.insert(0, detailed);
      
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create turf: ${_clean(e)}',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  Future<bool> updateTurf({
    required String turfId,
    required String name,
    required String sportId,
    required String location,
    required double pricePerSlot,
    required String ownerId,
    String? description,
    String? rules,
    List<String>? imageUrls,
    bool? isActive,
    required List<String> selectedFacilities,
    List<String>? originalFacilities,
  }) async {
    isProcessing.value = true;
    try {
      final turfData = {
        'name': name,
        'sport_id': sportId,
        'location': location,
        'price_per_slot': pricePerSlot,
        'owner_id': ownerId,
        'description': description,
        'rules': rules,
        'image_urls': imageUrls ?? [],
        if (isActive != null) 'is_active': isActive,
      };
      final updated = await _turfService.updateTurf(turfId, turfData);
      
      // Sync facilities
      final orig = originalFacilities ?? [];
      for (final f in selectedFacilities) {
        if (!orig.contains(f)) {
          await _turfService.addFacility(turfId, f);
        }
      }
      for (final f in orig) {
        if (!selectedFacilities.contains(f)) {
          await _turfService.deleteFacility(turfId, f);
        }
      }

      // Fetch detailed turf to populate list in controller
      final detailed = await _turfService.getTurfDetails(turfId);
      final idx = turfs.indexWhere((t) => t.id == turfId);
      if (idx != -1) {
        turfs[idx] = detailed;
      }

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update turf: ${_clean(e)}',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Pending Bookings (admin)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> getPendingBookings() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      pendingRequests.value = await _adminService.getPendingBookings();
    } catch (e) {
      errorMessage.value = _clean(e);
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveBooking(String bookingId) async {
    isProcessing.value = true;
    try {
      await _adminService.approveBooking(bookingId);
      final idx = pendingRequests.indexWhere((b) => b['booking_id'] == bookingId);
      if (idx != -1) {
        final updated = Map<String, dynamic>.from(pendingRequests[idx]);
        updated['status'] = 'Approved';
        pendingRequests[idx] = updated;
      }
      pendingBookings.value = (pendingBookings.value - 1).clamp(0, 999999);
      Get.snackbar('Approved ✓', 'Booking approved',
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Approve failed: ${_clean(e)}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> rejectBooking({
    required String bookingId,
    String? reason,
  }) async {
    isProcessing.value = true;
    try {
      await _adminService.rejectBooking(
        bookingId: bookingId,
        reason: reason,
      );
      final idx = pendingRequests.indexWhere((b) => b['booking_id'] == bookingId);
      if (idx != -1) {
        final updated = Map<String, dynamic>.from(pendingRequests[idx]);
        updated['status'] = 'Rejected';
        pendingRequests[idx] = updated;
      }
      pendingBookings.value = (pendingBookings.value - 1).clamp(0, 999999);
      Get.snackbar('Rejected', 'Booking rejected',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Reject failed: ${_clean(e)}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isProcessing.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Slot Blocking
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> getSlots() async {
    try {
      if (turfs.isEmpty) await getAllTurfs();

      if (turfs.isNotEmpty) {
        final turfId = selectedTurfId.value ?? turfs.first.id;
        final date = _todayStr();
        allSlots.value = await _turfService.getAvailability(turfId, date);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load slots: ${_clean(e)}',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> getBlockedSlots() async {
    try {
      final turfId = selectedTurfId.value;
      final dateStr =
          selectedDate.value != null ? _formatDate(selectedDate.value!) : null;

      blockedSlots.value = await _adminService.getBlockedSlots(
        turfId: turfId,
        date: dateStr,
      );

      // Refresh availability grid too
      if (turfId != null && selectedDate.value != null) {
        allSlots.value = await _turfService.getAvailability(
          turfId,
          _formatDate(selectedDate.value!),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load blocked slots: ${_clean(e)}',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void toggleSlot(String slotId) {
    if (selectedSlotIds.contains(slotId)) {
      selectedSlotIds.remove(slotId);
    } else {
      selectedSlotIds.add(slotId);
    }
    selectedSlotIds.refresh();
  }

  Future<void> blockSlots() async {
    if (selectedTurfId.value == null) {
      Get.snackbar('Required', 'Please select a turf',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (selectedDate.value == null) {
      Get.snackbar('Required', 'Please select a date',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (selectedSlotIds.isEmpty) {
      Get.snackbar('Required', 'Please select at least one slot',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isBlocking.value = true;
    try {
      final dateStr = _formatDate(selectedDate.value!);
      final reason = selectedReason.value ?? 'Other';
      final customReasonVal = customReason.value.trim();

      await _adminService.blockSlots(
        turfId: selectedTurfId.value!,
        slotIds: selectedSlotIds.toList(),
        blockedDate: dateStr,
        reason: reason,
        customReason: customReasonVal.isNotEmpty ? customReasonVal : null,
      );

      Get.snackbar('Blocked', '${selectedSlotIds.length} slot(s) blocked',
          snackPosition: SnackPosition.BOTTOM);
      clearBlockForm();
      await getBlockedSlots();
    } catch (e) {
      Get.snackbar('Error', 'Block failed: ${_clean(e)}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isBlocking.value = false;
    }
  }

  Future<void> unblockSlot(String blockedSlotId) async {
    try {
      await _adminService.unblockSlot(blockedSlotId);
      blockedSlots.removeWhere((b) => b['id'] == blockedSlotId);
      Get.snackbar('Unblocked', 'Slot unblocked',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Unblock failed: ${_clean(e)}',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void clearBlockForm() {
    selectedSlotIds.clear();
    selectedReason.value = null;
    customReason.value = '';
  }

  // ─── Private helpers ───────────────────────────────────────────────────────
  String _clean(Object e) => e.toString().replaceAll('Exception: ', '');

  String _todayStr() => _formatDate(DateTime.now());

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
