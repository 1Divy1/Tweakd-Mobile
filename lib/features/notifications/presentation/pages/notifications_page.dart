import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/notification.dart';
import '../bloc/notifications/bloc.dart';
import '../bloc/notifications/event.dart';
import '../bloc/notifications/state.dart';
import '../utils/notifications_error_mapper.dart';
import '../widgets/notifications_error_view.dart';
import '../widgets/notifications_list.dart';
import '../widgets/notifications_refreshable_empty.dart';
import '../widgets/notifications_top_bar.dart';

/// The notifications inbox: a cursor-paginated list with pull-to-refresh,
/// infinite scroll, empty/error states and a "mark all read" header action.
/// Tapping a row optimistically marks it read and navigates to its target.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  void _openTarget(BuildContext context, NotificationEntity notification) {
    if (!notification.read) {
      context
          .read<NotificationsBloc>()
          .add(MarkNotificationReadEvent(notification.id));
    }
    // Same resolver the push notification taps use, so a notification opens
    // the same place whether it was tapped here or on the lock screen.
    final route = notification.targetRoute;
    if (route != null) context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            BlocBuilder<NotificationsBloc, NotificationsState>(
              buildWhen: (prev, curr) =>
                  _canMarkAllRead(prev) != _canMarkAllRead(curr),
              builder: (context, state) => NotificationsTopBar(
                onBack: () => context.pop(),
                canMarkAllRead: _canMarkAllRead(state),
                onMarkAllRead: () => context
                    .read<NotificationsBloc>()
                    .add(const MarkAllNotificationsReadEvent()),
              ),
            ),
            Expanded(
              child: BlocBuilder<NotificationsBloc, NotificationsState>(
                builder: (context, state) {
                  return switch (state) {
                    NotificationsInitial() ||
                    NotificationsLoading() =>
                      Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    NotificationsError(:final code) => NotificationsErrorView(
                        message: notificationsErrorMessage(
                          AppLocalizations.of(context)!,
                          code,
                        ),
                        onRetry: () => context
                            .read<NotificationsBloc>()
                            .add(const LoadNotifications()),
                      ),
                    NotificationsLoaded() => state.items.isEmpty
                        ? const NotificationsRefreshableEmpty()
                        : NotificationsList(state: state, onTap: _openTarget),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static bool _canMarkAllRead(NotificationsState state) =>
      state is NotificationsLoaded && state.hasUnread;
}
