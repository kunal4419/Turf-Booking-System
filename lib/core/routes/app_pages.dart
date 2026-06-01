import 'package:get/get.dart';
import 'app_routes.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/turfs/screens/turf_details_screen.dart';
import '../../features/bookings/screens/slot_selection_screen.dart';
import '../../features/bookings/screens/booking_confirmation_screen.dart';

import '../../features/bookings/screens/booking_success_screen.dart';
import '../../features/bookings/screens/my_bookings_screen.dart';
import '../../features/bookings/screens/booking_detail_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';

import '../../features/admin/screens/admin_main_screen.dart';
import '../../features/admin/screens/add_edit_turf_screen.dart';

import '../../features/owner/screens/pricing_management_screen.dart';
import '../../features/owner/screens/owner_main_screen.dart';
import '../../features/owner/screens/owner_edit_turf_screen.dart';
import '../../features/owner/screens/manage_slots_screen.dart';
import '../../features/owner/screens/owner_block_slots_screen.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => SplashScreen()),
    GetPage(name: AppRoutes.login, page: () => LoginScreen()),
    GetPage(name: AppRoutes.signup, page: () => SignupScreen()),
    GetPage(name: AppRoutes.home, page: () => HomeScreen()),
    GetPage(name: AppRoutes.turfDetails, page: () => TurfDetailsScreen()),
    GetPage(name: AppRoutes.slotSelection, page: () => SlotSelectionScreen()),
    GetPage(name: AppRoutes.bookingConfirmation, page: () => BookingConfirmationScreen()),
    GetPage(name: AppRoutes.bookingSuccess, page: () => BookingSuccessScreen()),
    GetPage(name: AppRoutes.notifications, page: () => NotificationsScreen()),
    GetPage(name: AppRoutes.myBookings, page: () => MyBookingsScreen()),
    GetPage(name: AppRoutes.bookingDetail, page: () => const BookingDetailScreen()),
    
    // Admin Routes
    GetPage(name: AppRoutes.adminMain, page: () => const AdminMainScreen()),
    GetPage(name: AppRoutes.adminAddTurf, page: () => const AddEditTurfScreen()),

    // Owner Routes
    GetPage(name: AppRoutes.ownerMain, page: () => const OwnerMainScreen()),
    GetPage(name: AppRoutes.ownerPricing, page: () => const PricingManagementScreen()),
    GetPage(name: AppRoutes.ownerEditTurf, page: () => const OwnerEditTurfScreen()),
    GetPage(name: AppRoutes.ownerManageSlots, page: () => const ManageSlotsScreen()),
    GetPage(name: AppRoutes.ownerBlockSlots, page: () => const OwnerBlockSlotsScreen()),
  ];
}
