import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/admin_controller.dart';
import 'admin_dashboard_screen.dart';
import 'turf_management_screen.dart';
import 'booking_requests_screen.dart';
import 'block_slots_screen.dart';

import '../../../controllers/notification_controller.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  final List<Widget> _screens = const [
    AdminDashboardScreen(),
    TurfManagementScreen(),
    BookingRequestsScreen(),
    BlockSlotsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Get.put(AdminController());
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    return Obx(() => Scaffold(
          body: _screens[controller.adminTabIndex.value],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.adminTabIndex.value,
            onTap: (index) {
              controller.changeTab(index);
            },
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
              const BottomNavigationBarItem(icon: Icon(Icons.stadium), label: 'Turfs'),
              BottomNavigationBarItem(
                icon: Obx(() {
                  final notificationController = Get.find<NotificationController>();
                  final unreadCount = notificationController.unreadCount.value;
                  return Badge(
                    isLabelVisible: unreadCount > 0,
                    label: Text('$unreadCount'),
                    child: const Icon(Icons.receipt_long),
                  );
                }),
                label: 'Requests',
              ),
              const BottomNavigationBarItem(icon: Icon(Icons.block), label: 'Block Slots'),
            ],
          ),
        ));
  }
}
