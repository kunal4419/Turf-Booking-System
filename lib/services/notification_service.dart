import 'http_service.dart';
import 'auth_service.dart';
import '../models/notification_model.dart';
import '../utils/api_constants.dart';

/// Handles notification retrieval and management via Edge Functions.
class NotificationService {
  final HttpService _httpService = HttpService();
  final AuthService _authService = AuthService();

  String get _token {
    final t = _authService.getSavedToken();
    if (t == null) throw Exception('Not authenticated');
    return t;
  }

  // ─── Get notifications ────────────────────────────────────────────────────
  Future<List<AppNotification>> getNotifications() async {
    final response =
        await _httpService.get(ApiConstants.notificationsList, token: _token);

    if (response['success'] == true && response['notifications'] != null) {
      return (response['notifications'] as List)
          .map((n) => AppNotification.fromJson(n))
          .toList();
    }
    return [];
  }

  // ─── Mark as read ─────────────────────────────────────────────────────────
  Future<void> markAsRead(String notificationId) async {
    final response = await _httpService.post(
      ApiConstants.notificationsMarkRead,
      token: _token,
      body: {'notification_id': notificationId},
    );
    if (response['success'] != true) {
      throw Exception(response['error'] ?? 'Failed to mark notification as read');
    }
  }

  // ─── Delete notification ──────────────────────────────────────────────────
  Future<void> deleteNotification(String notificationId) async {
    final response = await _httpService.delete(
      ApiConstants.notificationsDelete,
      token: _token,
      body: {'notification_id': notificationId},
    );
    if (response['success'] != true) {
      throw Exception(response['error'] ?? 'Failed to delete notification');
    }
  }
}
