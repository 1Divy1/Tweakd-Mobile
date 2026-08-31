import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/messages/presentation/bloc/unread/cubit.dart';
import '../../features/notifications/domain/entities/notification.dart';
import '../../features/notifications/presentation/bloc/unread/cubit.dart';
import '../di/injection.dart';
import 'push_notification_service.dart';

/// Keeps the top-bar unread badges live while the app is in the foreground.
///
/// Must sit *inside* the root `MultiBlocProvider`: both unread cubits are
/// registered as factories, so `getIt` would hand back a fresh instance rather
/// than the one the feed is reading — the only way to reach the right one is
/// through the widget tree.
///
/// A push carrying an authoritative `unread_count` is applied directly; the
/// rest fall back to a refetch. Refetches are debounced, so a burst of
/// messages costs one request rather than one each.
class PushMessageListener extends StatefulWidget {
  final Widget child;

  const PushMessageListener({super.key, required this.child});

  @override
  State<PushMessageListener> createState() => _PushMessageListenerState();
}

class _PushMessageListenerState extends State<PushMessageListener> {
  StreamSubscription<void>? _sub;
  Timer? _debounce;

  /// Long enough to swallow a burst, short enough that the badge still feels
  /// instant to someone watching the screen when the push lands.
  static const _debounceWindow = Duration(milliseconds: 600);

  bool _notificationsDirty = false;
  bool _dmsDirty = false;

  @override
  void initState() {
    super.initState();
    _sub = getIt<PushNotificationService>().received.listen((message) {
      final type = NotificationType.fromWire(message.type);
      if (type.isDm) {
        _dmsDirty = true;
      } else {
        _notificationsDirty = true;
      }
      _debounce?.cancel();
      _debounce = Timer(_debounceWindow, _flush);
    });
  }

  void _flush() {
    if (!mounted) return;
    if (_notificationsDirty) {
      _notificationsDirty = false;
      context.read<NotificationsUnreadCubit>().refresh();
    }
    if (_dmsDirty) {
      _dmsDirty = false;
      context.read<DmUnreadCubit>().refresh();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
