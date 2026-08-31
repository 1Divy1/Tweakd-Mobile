import 'package:dartz/dartz.dart';

import '../../../../core/error/base_failures.dart';
import '../entities/notification.dart';
import '../entities/push_device.dart';

/// Notifications data contract. Implementations map data-layer exceptions to
/// [Failure]s and never leak SDK/HTTP exceptions.
abstract class NotificationsRepository {
  /// One cursor page of notifications (newest first). Echo [cursor] back from
  /// the previous page's `next_cursor`.
  Future<Either<Failure, NotificationPageEntity>> getNotifications({
    String? cursor,
    int size,
  });

  /// The viewer's unread notification count — drives the feed top-bar badge.
  Future<Either<Failure, int>> getUnreadCount();

  /// Marks a single notification read.
  Future<Either<Failure, void>> markRead(String id);

  /// Marks every notification read; resolves with the number updated.
  Future<Either<Failure, int>> markAllRead();

  /// Registers this installation for push notifications.
  Future<Either<Failure, void>> registerDevice(PushDeviceEntity device);

  /// Unregisters a push token. Call before signing out, while the JWT is
  /// still valid.
  Future<Either<Failure, void>> unregisterDevice(String token);
}
