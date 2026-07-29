import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/notifications/bloc.dart';
import '../bloc/notifications/event.dart';
import 'notifications_empty_view.dart';

/// Empty state that still supports pull-to-refresh (so a user who lands on an
/// empty list can re-check without leaving the page).
class NotificationsRefreshableEmpty extends StatelessWidget {
  const NotificationsRefreshableEmpty({super.key});

  Future<void> _refresh(BuildContext context) async {
    final completer = Completer<void>();
    context.read<NotificationsBloc>().add(RefreshNotifications(completer));
    await completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: () => _refresh(context),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          NotificationsEmptyView(),
        ],
      ),
    );
  }
}
