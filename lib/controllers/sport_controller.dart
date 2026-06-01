import 'package:get/get.dart';
import '../services/sport_service.dart';
import '../models/sport_model.dart';

class SportController extends GetxController {
  final SportService _sportService = SportService();

  var sports = RxList<Sport>();
  var isLoading = false.obs;

  // Observables
  var selectedSportId = Rx<String?>(null);
  var selectedSportName = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    getSports();
  }

  // Fetches all sports from API endpoint
  Future<void> getSports() async {
    isLoading.value = true;
    try {
      sports.value = await _sportService.getSports();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load sports: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Select sport by ID and optional Name
  void selectSport(String id, [String? name]) {
    selectedSportId.value = id;
    selectedSportName.value = name ?? getSportName(id);
  }

  // Get sport name by ID from cached list
  String getSportName(String id) {
    final sport = sports.firstWhereOrNull((s) => s.id == id);
    return sport?.name ?? 'Unknown';
  }

  // Create sport endpoint integration
  Future<Sport?> createSport(String name, {String? iconUrl, String? description}) async {
    isLoading.value = true;
    try {
      final newSport = await _sportService.createSport(name, iconUrl: iconUrl, description: description);
      sports.add(newSport);
      selectSport(newSport.id, newSport.name);
      Get.snackbar('Success', 'Sport "${newSport.name}" created successfully');
      return newSport;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create sport: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  void clearSelection() {
    selectedSportId.value = null;
    selectedSportName.value = null;
  }
}
