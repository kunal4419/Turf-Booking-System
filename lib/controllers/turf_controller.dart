import 'package:get/get.dart';
import '../services/turf_service.dart';
import '../models/turf_model.dart';
import '../models/slot_model.dart';

/// Manages turf listing, turf details, slot availability, and search filtering.
class TurfController extends GetxController {
  final TurfService _turfService = TurfService();

  var turfs = RxList<Turf>();
  var filteredTurfs = RxList<Turf>();
  var selectedTurf = Rx<Turf?>(null);
  var isLoading = false.obs;
  var searchQuery = ''.obs;
  var selectedSlots = RxList<Slot>(); // Availability for selected date

  // ─── Fetch turf list ───────────────────────────────────────────────────────
  Future<void> getTurfs({String? sportId, String? location}) async {
    isLoading.value = true;
    try {
      turfs.value = await _turfService.getTurfs(
        sportId: sportId,
        location: location,
      );
      filteredTurfs.value = turfs.toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load turfs: ${_clean(e)}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Load & set selected turf ──────────────────────────────────────────────
  Future<void> selectTurf(String turfId) async {
    isLoading.value = true;
    try {
      selectedTurf.value = await _turfService.getTurfDetails(turfId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load turf details: ${_clean(e)}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Slot availability ────────────────────────────────────────────────────
  Future<void> getSlotAvailability(String turfId, String date) async {
    isLoading.value = true;
    try {
      selectedSlots.value = await _turfService.getAvailability(turfId, date);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load availability: ${_clean(e)}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Client-side search ───────────────────────────────────────────────────
  void searchTurfs(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredTurfs.value = turfs.toList();
    } else {
      final q = query.toLowerCase();
      filteredTurfs.value = turfs
          .where((t) =>
              t.name.toLowerCase().contains(q) ||
              t.location.toLowerCase().contains(q) ||
              t.sportName.toLowerCase().contains(q))
          .toList();
    }
  }

  String _clean(Object e) => e.toString().replaceAll('Exception: ', '');
}
