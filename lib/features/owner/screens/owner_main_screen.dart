import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/owner_controller.dart';
import 'owner_dashboard_screen.dart';
import 'direct_booking_screen.dart';
import 'turf_bookings_screen.dart';
import 'my_turfs_screen.dart';

import '../../../controllers/notification_controller.dart';

class OwnerMainScreen extends StatefulWidget {
  const OwnerMainScreen({super.key});

  @override
  State<OwnerMainScreen> createState() => _OwnerMainScreenState();
}

class _OwnerMainScreenState extends State<OwnerMainScreen> {
  final List<Widget> _screens = const [
    OwnerDashboardScreen(),
    DirectBookingScreen(),
    TurfBookingsScreen(),
    MyTurfsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Get.put(OwnerController());
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OwnerController>();

    return Obx(() => Scaffold(
          body: _screens[controller.ownerTabIndex.value],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.ownerTabIndex.value,
            onTap: (index) {
              controller.changeTab(index);
            },
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
              const BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Direct Book'),
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
              const BottomNavigationBarItem(icon: Icon(Icons.stadium), label: 'My Turfs'),
            ],
          ),
        ));
  }
}

