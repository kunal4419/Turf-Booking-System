import 'package:get/get.dart';
import '../services/local_storage_service.dart';
import '../services/http_service.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/turf_service.dart';
import '../services/sport_service.dart';
import '../services/booking_service.dart';
import '../services/notification_service.dart';
import '../services/admin_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/sport_controller.dart';
import '../controllers/turf_controller.dart';
import '../controllers/booking_controller.dart';
import '../controllers/notification_controller.dart';

/// Registers all GetX dependencies that must be available app-wide.
/// AdminController is lazily put per-screen (AdminMainScreen).
class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // ── Services (register as permanent singletons) ──────────────────────────
    Get.put<LocalStorageService>(LocalStorageService(), permanent: true);
    Get.put<HttpService>(HttpService(), permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<UserService>(UserService(), permanent: true);
    Get.put<SportService>(SportService(), permanent: true);
    Get.put<TurfService>(TurfService(), permanent: true);
    Get.put<BookingService>(BookingService(), permanent: true);
    Get.put<NotificationService>(NotificationService(), permanent: true);
    Get.put<AdminService>(AdminService(), permanent: true);

    // ── Controllers ──────────────────────────────────────────────────────────
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<SportController>(SportController(), permanent: true);
    Get.put<TurfController>(TurfController(), permanent: true);
    Get.put<BookingController>(BookingController(), permanent: true);
    Get.put<NotificationController>(NotificationController(), permanent: true);
    // Note: AdminController is put in AdminMainScreen.initState() so it
    // only initialises when the admin section is actually opened.
  }
}
