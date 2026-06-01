import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/notification_controller.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationController = Get.find<NotificationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        automaticallyImplyLeading: true,
        actions: [
          Obx(() {
            final hasUnread = notificationController.unreadCount.value > 0;
            if (!hasUnread) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark all as read',
              onPressed: () => notificationController.markAllAsRead(),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (notificationController.isLoading.value && notificationController.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (notificationController.notifications.isEmpty) {
          return const Center(child: Text('No notifications yet.'));
        }

        return ListView.separated(
          itemCount: notificationController.notifications.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final notification = notificationController.notifications[index];
            
            IconData icon;
            Color iconColor;
            
            if (notification.type.contains('approved')) {
              icon = Icons.check_circle;
              iconColor = Colors.green;
            } else if (notification.type.contains('rejected')) {
              icon = Icons.cancel;
              iconColor = Colors.red;
            } else {
              icon = Icons.notifications_active;
              iconColor = Colors.blue;
            }

            return _buildNotificationItem(
              icon: icon,
              iconColor: iconColor,
              title: notification.title,
              subtitle: notification.message,
              time: DateFormat.yMMMd().add_jm().format(notification.createdAt),
              isRead: notification.isRead,
              onTap: () {
                if (!notification.isRead) {
                  notificationController.markAsRead(notification.id);
                }
              },
            );
          },
        );
      }),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required bool isRead,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        color: isRead ? Colors.transparent : Colors.blue.withValues(alpha: 0.04),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
