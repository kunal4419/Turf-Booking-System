import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/owner_service.dart';
import '../services/turf_service.dart';
import '../controllers/auth_controller.dart';
import '../models/turf_model.dart';
import '../models/booking_model.dart';
import '../models/slot_model.dart';

class OwnerController extends GetxController {
  final OwnerService _ownerService = OwnerService();
  final TurfService _turfService = TurfService();
  final AuthController _authController = Get.find<AuthController>();

  // Bottom navbar tab navigation
  var ownerTabIndex = 0.obs;

  var isLoading = false.obs;
  var isProcessing = false.obs;
  var errorMessage = ''.obs;

  // Dashboard Stats
  var totalTurfs = 0.obs;
  var totalBookings = 0.obs;
  var pendingBookingsCount = 0.obs;
  var approvedBookingsCount = 0.obs;
  var totalRevenue = 0.0.obs;

  // My Turfs Data
  var myTurfs = <Turf>[].obs;
  var turfStats = <String, Map<String, dynamic>>{}.obs; // turfId -> {bookingsCount, revenue}

  // Booking Requests Data
  var allBookings = <Booking>[].obs;
  var filteredBookings = <Booking>[].obs;
  var selectedStatusFilter = 'All'.obs;

  // Slot Pricing Data
  var selectedTurfId = Rx<String?>(null);
  var selectedDate = Rx<DateTime>(DateTime.now());
  var slotsPricing = <Map<String, dynamic>>[].obs; // {slot_id, display_label, price, is_custom}

  // ─── Direct Booking State ──────────────────────────────────────────────────
  var directTurfId = Rx<String?>(null);
  var directDate = Rx<DateTime>(DateTime.now());
  var directSlots = RxList<dynamic>(); // Slot objects loaded via TurfService
  var customers = RxList<Map<String, dynamic>>();
  var selectedCustomer = Rx<Map<String, dynamic>?>(null);
  var walkinCustomerName = ''.obs;
  var isDirectLoading = false.obs;
  var directSelectedDateIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadOwnerData();
  }

  void changeTab(int index) {
    ownerTabIndex.value = index;
    if (index == 0) {
      loadDashboardData();
    } else if (index == 1) {
      // Direct Booking tab
      if (directTurfId.value == null && myTurfs.isNotEmpty) {
        directTurfId.value = myTurfs.first.id;
      }
      if (customers.isEmpty) loadCustomers();
      if (directTurfId.value != null) {
        loadDirectBookingSlots(directTurfId.value!, directDate.value);
      }
    } else if (index == 2) {
      loadBookings();
    } else if (index == 3) {
      loadOwnerTurfs();
    }
  }

  Future<void> loadOwnerData() async {
    final user = _authController.user.value;
    if (user == null) return;

    isLoading.value = true;
    errorMessage.value = '';
    try {
      await loadOwnerTurfs();
      if (myTurfs.isNotEmpty) {
        selectedTurfId.value = myTurfs.first.id;
      }
      await loadDashboardData();
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadOwnerTurfs() async {
    final user = _authController.user.value;
    if (user == null) return;

    try {
      myTurfs.value = await _turfService.getTurfs(ownerId: user.id);
      for (var turf in myTurfs) {
        turfStats[turf.id] = {
          'bookingsCount': 0,
          'revenue': 0.0,
        };
      }
    } catch (e) {
      print("Error loading owner turfs: $e");
    }
  }

  Future<void> loadDashboardData() async {
    final user = _authController.user.value;
    if (user == null) return;

    try {
      final stats = await _ownerService.getDashboardStats();
      totalTurfs.value = (stats['total_turfs'] as num?)?.toInt() ?? 0;
      totalBookings.value = (stats['total_bookings'] as num?)?.toInt() ?? 0;
      pendingBookingsCount.value = (stats['pending_bookings'] as num?)?.toInt() ?? 0;
      approvedBookingsCount.value = (stats['approved_bookings'] as num?)?.toInt() ?? 0;
      totalRevenue.value = (stats['total_revenue'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      print("Error loading dashboard data: $e");
    }
  }

  Future<void> loadBookings() async {
    isLoading.value = true;
    try {
      final bookingsData = await _ownerService.getBookings();
      allBookings.value = bookingsData.map((b) => Booking.fromJson(b)).toList();
      applyBookingsFilter();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load bookings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void applyBookingsFilter() {
    if (selectedStatusFilter.value == 'All') {
      filteredBookings.value = allBookings;
    } else {
      filteredBookings.value = allBookings
          .where((b) => b.status.toLowerCase() == selectedStatusFilter.value.toLowerCase())
          .toList();
    }
  }

  void setStatusFilter(String filter) {
    selectedStatusFilter.value = filter;
    applyBookingsFilter();
  }

  Future<void> approveBooking(String bookingId) async {
    isProcessing.value = true;
    try {
      await _ownerService.approveBooking(bookingId);
      final idx = allBookings.indexWhere((b) => b.bookingId == bookingId);
      if (idx != -1) {
        final b = allBookings[idx];
        allBookings[idx] = Booking(
          id: b.id,
          bookingId: b.bookingId,
          customerId: b.customerId,
          turfId: b.turfId,
          turfName: b.turfName,
          turfImage: b.turfImage,
          slotId: b.slotId,
          slotDisplay: b.slotDisplay,
          bookingDate: b.bookingDate,
          status: 'Approved',
          price: b.price,
          notes: b.notes,
          createdAt: b.createdAt,
          approvedAt: DateTime.now(),
          customerName: b.customerName,
          turfLocation: b.turfLocation,
        );
      }
      applyBookingsFilter();
      pendingBookingsCount.value = (pendingBookingsCount.value - 1).clamp(0, 99999);
      approvedBookingsCount.value = approvedBookingsCount.value + 1;
      Get.snackbar('Success', 'Booking approved successfully',
          backgroundColor: Colors.green[100], colorText: Colors.black);
    } catch (e) {
      Get.snackbar('Error', 'Approval failed: $e');
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> rejectBooking(String bookingId, {String? reason}) async {
    isProcessing.value = true;
    try {
      await _ownerService.rejectBooking(bookingId: bookingId, reason: reason);
      final idx = allBookings.indexWhere((b) => b.bookingId == bookingId);
      if (idx != -1) {
        final b = allBookings[idx];
        allBookings[idx] = Booking(
          id: b.id,
          bookingId: b.bookingId,
          customerId: b.customerId,
          turfId: b.turfId,
          turfName: b.turfName,
          turfImage: b.turfImage,
          slotId: b.slotId,
          slotDisplay: b.slotDisplay,
          bookingDate: b.bookingDate,
          status: 'Rejected',
          price: b.price,
          notes: b.notes,
          createdAt: b.createdAt,
          rejectedAt: DateTime.now(),
          rejectionReason: reason,
          customerName: b.customerName,
          turfLocation: b.turfLocation,
        );
      }
      applyBookingsFilter();
      pendingBookingsCount.value = (pendingBookingsCount.value - 1).clamp(0, 99999);
      Get.snackbar('Success', 'Booking rejected successfully',
          backgroundColor: Colors.orange[100], colorText: Colors.black);
    } catch (e) {
      Get.snackbar('Error', 'Rejection failed: $e');
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> loadPricingSlots() async {
    if (selectedTurfId.value == null) return;
    isLoading.value = true;
    try {
      final dateStr = _formatDate(selectedDate.value);
      final slotsData = await _ownerService.getSlotPricing(selectedTurfId.value!, dateStr);
      slotsPricing.value = List<Map<String, dynamic>>.from(slotsData);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load slot pricing: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateLocalSlotPrice(String slotId, double price) {
    final idx = slotsPricing.indexWhere((sp) => sp['slot_id'] == slotId);
    if (idx != -1) {
      slotsPricing[idx] = {
        ...slotsPricing[idx],
        'price': price,
        'is_custom': true,
        'is_reset': false,
      };
      slotsPricing.refresh();
    }
  }

  void resetLocalSlotToDefault(String slotId) {
    final idx = slotsPricing.indexWhere((sp) => sp['slot_id'] == slotId);
    if (idx != -1 && selectedTurfId.value != null) {
      final selectedTurf = myTurfs.firstWhere((t) => t.id == selectedTurfId.value);
      slotsPricing[idx] = {
        ...slotsPricing[idx],
        'price': selectedTurf.pricePerSlot,
        'is_custom': false,
        'is_reset': true,
      };
      slotsPricing.refresh();
    }
  }

  Future<void> saveSlotPricing() async {
    if (selectedTurfId.value == null) return;
    isLoading.value = true;
    try {
      final dateStr = _formatDate(selectedDate.value);
      final pricesToSave = slotsPricing.map((sp) => {
        'slot_id': sp['slot_id'],
        'price': sp['price'],
        'is_reset': sp['is_reset'] ?? false,
      }).toList();

      await _ownerService.updateSlotPricing(selectedTurfId.value!, dateStr, pricesToSave);
      Get.snackbar('Success', 'Pricing saved successfully for $dateStr',
          backgroundColor: Colors.green[100], colorText: Colors.black);
      loadPricingSlots();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save pricing: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateOwnerTurf({
    required String turfId,
    required String name,
    required String sportId,
    required String location,
    required double pricePerSlot,
    String? description,
    String? rules,
    List<String>? imageUrls,
    required List<String> selectedFacilities,
    List<String>? originalFacilities,
  }) async {
    isProcessing.value = true;
    try {
      final user = _authController.user.value;
      if (user == null) throw Exception("User session not found");

      final turfData = {
        'name': name,
        'sport_id': sportId,
        'location': location,
        'price_per_slot': pricePerSlot,
        'owner_id': user.id,
        'description': description,
        'rules': rules,
        'image_urls': imageUrls ?? [],
      };

      await _turfService.updateTurf(turfId, turfData);

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

      await loadOwnerTurfs();
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update turf: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red[100]);
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  // ─── Direct Booking Methods ────────────────────────────────────────────────

  Future<void> loadDirectBookingSlots(String turfId, DateTime date) async {
    isDirectLoading.value = true;
    try {
      final dateStr = _formatDate(date);
      directSlots.value = await _turfService.getAvailability(turfId, dateStr);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load slots: ${_clean(e)}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isDirectLoading.value = false;
    }
  }

  Future<void> loadCustomers() async {
    try {
      customers.value = await _ownerService.getCustomers();
    } catch (e) {
      // Non-critical — customer list might be empty
    }
  }

  Future<bool> createDirectBooking({
    required String slotId,
    required String slotDisplay,
    required double price,
    String? customerId,
    String? customerName,
    String? notes,
  }) async {
    if (directTurfId.value == null) {
      Get.snackbar('Error', 'Please select a turf', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    isDirectLoading.value = true;
    try {
      final dateStr = _formatDate(directDate.value);
      await _ownerService.createDirectBooking(
        turfId: directTurfId.value!,
        slotId: slotId,
        bookingDate: dateStr,
        customerId: customerId,
        customerName: customerName,
        notes: notes,
      );
      // Refresh slots so the just-booked slot becomes red immediately
      await loadDirectBookingSlots(directTurfId.value!, directDate.value);
      // Reset selection
      selectedCustomer.value = null;
      walkinCustomerName.value = '';
      final displayName = customerId != null
          ? (selectedCustomer.value?['name'] ?? 'Customer')
          : (customerName ?? 'Walk-in');
      Get.snackbar(
        'Booking Confirmed ✅',
        'Slot $slotDisplay booked for $displayName',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: const Color(0xFFFFFFFF),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return true;
    } catch (e) {
      Get.snackbar('Booking Failed', _clean(e),
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isDirectLoading.value = false;
    }
  }

  // ─── Turf Slots Management State ──────────────────────────────────────────
  var turfSlotsList = <Map<String, dynamic>>[].obs;
  var isSlotsLoading = false.obs;

  // ─── Slot Blocking State ──────────────────────────────────────────────────
  var blockSelectedSlotIds = <String>[].obs;
  var blockReason = Rx<String?>(null);
  var blockCustomReason = ''.obs;
  var blockBlockedSlots = RxList<Map<String, dynamic>>();
  var blockAllSlots = RxList<Slot>();
  var isBlockLoading = false.obs;

  Future<void> loadBlockSlotsData() async {
    if (selectedTurfId.value == null) return;
    isBlockLoading.value = true;
    try {
      final dateStr = _formatDate(selectedDate.value);
      // Load all slots with availability
      blockAllSlots.value = await _turfService.getAvailability(selectedTurfId.value!, dateStr);
      // Load blocked slots list
      blockBlockedSlots.value = await _ownerService.getBlockedSlots(
        turfId: selectedTurfId.value,
        date: dateStr,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to load block slot data: ${_clean(e)}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isBlockLoading.value = false;
    }
  }

  void toggleBlockSlot(String slotId) {
    if (blockSelectedSlotIds.contains(slotId)) {
      blockSelectedSlotIds.remove(slotId);
    } else {
      blockSelectedSlotIds.add(slotId);
    }
    blockSelectedSlotIds.refresh();
  }

  Future<void> blockSlots() async {
    if (selectedTurfId.value == null) {
      Get.snackbar('Required', 'Please select a turf',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (blockSelectedSlotIds.isEmpty) {
      Get.snackbar('Required', 'Please select at least one slot',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (blockReason.value == null) {
      Get.snackbar('Required', 'Please select a block reason',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isProcessing.value = true;
    try {
      final dateStr = _formatDate(selectedDate.value);
      final reason = blockReason.value ?? 'Other';
      final customReasonVal = blockCustomReason.value.trim();

      await _ownerService.blockSlots(
        turfId: selectedTurfId.value!,
        slotIds: blockSelectedSlotIds.toList(),
        blockedDate: dateStr,
        reason: reason,
        customReason: customReasonVal.isNotEmpty ? customReasonVal : null,
      );

      Get.snackbar('Blocked', '${blockSelectedSlotIds.length} slot(s) blocked successfully',
          backgroundColor: Colors.green[100], colorText: Colors.black, snackPosition: SnackPosition.BOTTOM);
      
      clearBlockForm();
      await loadBlockSlotsData();
    } catch (e) {
      Get.snackbar('Error', 'Failed to block slots: ${_clean(e)}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> unblockSlot(String blockedSlotId) async {
    isProcessing.value = true;
    try {
      await _ownerService.unblockSlot(blockedSlotId);
      Get.snackbar('Success', 'Slot unblocked successfully',
          backgroundColor: Colors.green[100], colorText: Colors.black, snackPosition: SnackPosition.BOTTOM);
      await loadBlockSlotsData();
    } catch (e) {
      Get.snackbar('Error', 'Failed to unblock slot: ${_clean(e)}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isProcessing.value = false;
    }
  }

  void clearBlockForm() {
    blockSelectedSlotIds.clear();
    blockReason.value = null;
    blockCustomReason.value = '';
  }

  Future<void> loadTurfSlots(String turfId) async {
    isSlotsLoading.value = true;
    try {
      final slotsData = await _ownerService.getTurfSlots(turfId);
      turfSlotsList.value = List<Map<String, dynamic>>.from(slotsData);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load turf slots: ${_clean(e)}');
    } finally {
      isSlotsLoading.value = false;
    }
  }

  void toggleLocalSlot(String slotId) {
    final idx = turfSlotsList.indexWhere((s) => s['slot_id'] == slotId);
    if (idx != -1) {
      final current = turfSlotsList[idx];
      turfSlotsList[idx] = {
        ...current,
        'is_enabled': !(current['is_enabled'] as bool),
      };
      turfSlotsList.refresh();
    }
  }

  Future<void> saveTurfSlots(String turfId) async {
    isSlotsLoading.value = true;
    try {
      final slotsToSave = turfSlotsList.map((s) => {
        'slot_id': s['slot_id'],
        'is_enabled': s['is_enabled'],
      }).toList();

      await _ownerService.updateTurfSlots(turfId, slotsToSave);
      Get.snackbar('Success', 'Slot configurations saved successfully',
          backgroundColor: Colors.green[100], colorText: Colors.black);
      await loadTurfSlots(turfId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save configurations: ${_clean(e)}');
    } finally {
      isSlotsLoading.value = false;
    }
  }

  String _clean(Object e) => e.toString().replaceAll('Exception: ', '');

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
