import 'package:injectable/injectable.dart';

import '../../../../core/network/abstract_http.dart';
import '../models/notification_models.dart';
import '../models/push_device_model.dart';

/// Notifications REST contract (base `/api/v1`, snake_case, JWT via the
/// interceptor — call sites never set Authorization).
abstract class NotificationsDataSource {
  Future<NotificationPageModel> getNotifications({String? cursor, int size});
  Future<int> getUnreadCount();
  Future<void> markRead(String id);

  /// Marks all read; returns the number of notifications updated.
  Future<int> markAllRead();

  /// Registers this installation's FCM token. Idempotent — the backend upserts
  /// on the token and reassigns it to the caller.
  Future<void> registerDevice(PushDeviceModel device);

  /// Removes a registration so the device stops receiving pushes for the
  /// caller. Must be sent while the JWT is still valid, i.e. before sign-out.
  ///
  /// The token travels in the body, never the path: a path segment is written
  /// verbatim into access logs and any proxy in front of the backend, and an
  /// FCM token is a push credential for that phone.
  Future<void> unregisterDevice(String token);
}

@LazySingleton(as: NotificationsDataSource)
class NotificationsApiDataSource implements NotificationsDataSource {
  final AbstractHTTP http;

  NotificationsApiDataSource(this.http);

  @override
  Future<NotificationPageModel> getNotifications({
    String? cursor,
    int size = 20,
  }) async {
    final data = await http.get(
      '/notifications',
      queryParameters: {
        'cursor': ?cursor,
        'size': size,
      },
    );
    return NotificationPageModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<int> getUnreadCount() async {
    final data = await http.get('/notifications/unread-count');
    return (data as Map<String, dynamic>)['unread'] as int? ?? 0;
  }

  @override
  Future<void> markRead(String id) => http.post('/notifications/$id/read');

  @override
  Future<int> markAllRead() async {
    final data = await http.post('/notifications/read-all');
    return (data as Map<String, dynamic>)['updated'] as int? ?? 0;
  }

  @override
  Future<void> registerDevice(PushDeviceModel device) =>
      http.post('/notifications/devices', body: device.toJson());

  @override
  Future<void> unregisterDevice(String token) =>
      http.delete('/notifications/devices', body: {'token': token});
}
