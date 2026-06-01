import 'dart:async';
import 'package:get/get.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';
import 'auth_controller.dart';

/// Manages notifications with auto-refresh every 30 seconds.
class NotificationController extends GetxController {
  final NotificationService _notificationService = NotificationService();

  var notifications = RxList<AppNotification>();
  var isLoading = false.obs;
  var unreadCount = 0.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    
    final authController = Get.find<AuthController>();
    
    // Fetch notifications if already logged in at startup
    if (authController.isLoggedIn.value) {
      getNotifications();
    }

    // React to authentication changes
    ever(authController.isLoggedIn, (bool loggedIn) {
      if (loggedIn) {
        getNotifications();
      } else {
        notifications.clear();
        unreadCount.value = 0;
      }
    });

    // Auto-refresh every 30 seconds
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (authController.isLoggedIn.value) {
        getNotifications();
      }
    });

    ever(notifications, (_) => _updateUnreadCount());
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  // ─── Fetch notifications ──────────────────────────────────────────────────
  Future<void> getNotifications() async {
    isLoading.value = true;
    try {
      notifications.value =
          await _notificationService.getNotifications();
      _updateUnreadCount();
    } catch (_) {
      // Silent fail — notifications are non-critical
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Mark as read ─────────────────────────────────────────────────────────
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      final idx = notifications.indexWhere((n) => n.id == notificationId);
      if (idx != -1) {
        final n = notifications[idx];
        notifications[idx] = AppNotification(
          id: n.id,
          userId: n.userId,
          title: n.title,
          message: n.message,
          type: n.type,
          isRead: true,
          createdAt: n.createdAt,
          readAt: DateTime.now(),
        );
        _updateUnreadCount();
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not mark notification as read',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ─── Mark all as read ─────────────────────────────────────────────────────
  Future<void> markAllAsRead() async {
    final unread = notifications.where((n) => !n.isRead).toList();
    for (final n in unread) {
      await markAsRead(n.id);
    }
  }

  // ─── Delete notification ──────────────────────────────────────────────────
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();
    } catch (e) {
      Get.snackbar('Error', 'Could not delete notification',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }
}
