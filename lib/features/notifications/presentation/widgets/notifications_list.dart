import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/notification.dart';
import '../bloc/notifications/bloc.dart';
import '../bloc/notifications/event.dart';
import '../bloc/notifications/state.dart';
import 'notification_tile.dart';

/// The loaded notifications list: pull-to-refresh over the rows with cursor
/// pagination near the bottom and dividers between rows.
class NotificationsList extends StatelessWidget {
  final NotificationsLoaded state;
  final void Function(BuildContext, NotificationEntity) onTap;

  const NotificationsList({super.key, required this.state, required this.onTap});

  Future<void> _refresh(BuildContext context) async {
    final completer = Completer<void>();
    context.read<NotificationsBloc>().add(RefreshNotifications(completer));
    await completer.future;
  }

  bool _onScroll(BuildContext context, ScrollNotification notification) {
    if (notification.metrics.extentAfter < 300) {
      context.read<NotificationsBloc>().add(const LoadMoreNotifications());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final items = state.items;

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: () => _refresh(context),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) => _onScroll(context, notification),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: items.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= items.length) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              );
            }
            return Column(
              children: [
                NotificationTile(
                  notification: items[index],
                  onTap: () => onTap(context, items[index]),
                ),
                if (index != items.length - 1)
                  Padding(
                    padding: EdgeInsets.only(left: 76, right: 20),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.line,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
