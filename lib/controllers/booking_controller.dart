import 'package:get/get.dart';
import '../services/booking_service.dart';
import '../models/booking_model.dart';
import '../models/slot_model.dart';
import '../core/routes/app_routes.dart';

/// Manages bookings: listing, creation, cancellation, and form state.
class BookingController extends GetxController {
  final BookingService _bookingService = BookingService();

  // ─── Lists ─────────────────────────────────────────────────────────────────
  var myBookings = RxList<Booking>();
  var upcomingBookings = RxList<Booking>();
  var pastBookings = RxList<Booking>();
  var selectedBooking = Rx<Booking?>(null);
  var isLoading = false.obs;

  // ─── Booking form state ────────────────────────────────────────────────────
  var selectedDate = Rx<DateTime?>(null);
  var selectedSlot = Rx<Slot?>(null);
  var selectedTurfId = ''.obs;
  var bookingNotes = ''.obs;
  var bookingPrice = 0.0.obs;

  // ─── Last created booking result (for success screen) ─────────────────────
  var lastBookingId = ''.obs;
  var lastBookingStatus = ''.obs;

  // ─── Fetch my bookings ─────────────────────────────────────────────────────
  Future<void> getMyBookings({String? status}) async {
    isLoading.value = true;
    try {
      myBookings.value =
          await _bookingService.getMyBookings(status: status);
      _filterBookings();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load bookings: ${_clean(e)}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void _filterBookings() {
    // 1. Sort all bookings for "All" tab: Pending -> Approved -> Rejected -> Cancelled -> Completed
    final statusOrder = {
      'Pending': 0,
      'Approved': 1,
      'Rejected': 2,
      'Cancelled': 3,
      'Completed': 4,
    };

    myBookings.sort((a, b) {
      final orderA = statusOrder[a.status] ?? 99;
      final orderB = statusOrder[b.status] ?? 99;
      if (orderA != orderB) {
        return orderA.compareTo(orderB);
      }
      // If same status, sort by date descending (newest bookings first)
      try {
        final dateA = DateTime.parse(a.bookingDate);
        final dateB = DateTime.parse(b.bookingDate);
        return dateB.compareTo(dateA);
      } catch (_) {
        return b.createdAt.compareTo(a.createdAt);
      }
    });

    // 2. Filter approved upcoming bookings for "Upcoming" tab (date >= today)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    upcomingBookings.value = myBookings
        .where((b) {
          if (b.status != 'Approved') return false;
          try {
            final d = DateTime.parse(b.bookingDate);
            return !d.isBefore(today);
          } catch (_) {
            return false;
          }
        })
        .toList();

    // Sort upcoming approved bookings by date ascending (closest booking first)
    upcomingBookings.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.bookingDate);
        final dateB = DateTime.parse(b.bookingDate);
        return dateA.compareTo(dateB);
      } catch (_) {
        return 0;
      }
    });

    // Keep pastBookings updated in case it's used elsewhere
    pastBookings.value = myBookings
        .where((b) {
          try {
            final d = DateTime.parse(b.bookingDate);
            return d.isBefore(today);
          } catch (_) {
            return false;
          }
        })
        .toList();
  }

  // ─── Create booking ────────────────────────────────────────────────────────
  Future<void> createBooking() async {
    if (selectedDate.value == null || selectedSlot.value == null) {
      Get.snackbar('Error', 'Please select date and slot',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (selectedTurfId.value.isEmpty) {
      Get.snackbar('Error', 'No turf selected',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      final dateStr = _formatDate(selectedDate.value!);
      final response = await _bookingService.createBooking(
        turfId: selectedTurfId.value,
        slotId: selectedSlot.value!.id,
        bookingDate: dateStr,
        notes: bookingNotes.value.isEmpty ? null : bookingNotes.value,
      );

      final bookingData = response['booking'] ?? {};
      lastBookingId.value = bookingData['booking_id'] ?? '';
      lastBookingStatus.value = bookingData['status'] ?? 'Pending';

      clearBookingForm();
      getMyBookings(); // Refresh list in background
      Get.offAllNamed(AppRoutes.bookingSuccess);
    } catch (e) {
      Get.snackbar('Booking Failed', _clean(e),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Cancel booking ────────────────────────────────────────────────────────
  Future<void> cancelBooking(String bookingId) async {
    isLoading.value = true;
    try {
      await _bookingService.cancelBooking(bookingId);
      // Update local list
      final idx = myBookings.indexWhere((b) => b.id == bookingId);
      if (idx != -1) {
        // Refresh from server to get updated status
        await getMyBookings();
      }
      Get.snackbar('Cancelled', 'Booking cancelled successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Cancellation failed: ${_clean(e)}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Form helpers ──────────────────────────────────────────────────────────
  void setSelectedDate(DateTime date) => selectedDate.value = date;

  void setSelectedSlot(Slot slot) {
    selectedSlot.value = slot;
    bookingPrice.value = slot.price;
  }

  void setSelectedTurf(String turfId, double price) {
    selectedTurfId.value = turfId;
    bookingPrice.value = price;
  }

  void clearBookingForm() {
    selectedDate.value = null;
    selectedSlot.value = null;
    selectedTurfId.value = '';
    bookingNotes.value = '';
    bookingPrice.value = 0.0;
  }

  // ─── Private helpers ───────────────────────────────────────────────────────
  String _clean(Object e) => e.toString().replaceAll('Exception: ', '');

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
