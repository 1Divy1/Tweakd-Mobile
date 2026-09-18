import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/bloc/unread_count_cubit.dart';
import '../../../../core/shared/widgets/app_pill_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../messages/presentation/bloc/unread/cubit.dart';
import '../../../notifications/presentation/bloc/unread/cubit.dart';
import '../../../../core/shared/layout/app_layout.dart';

/// The feed's top bar: the "Tweakd." wordmark on the left and the
/// notifications / direct-messages pill buttons on the right. Both carry an
/// unread badge and refresh their count when the feed mounts and on returning
/// from their destination.
class FeedTopBar extends StatelessWidget {
  const FeedTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(20, 12, 16, 8) + AppLayout.inset(context),
      child: Row(
        children: [
          // Brand wordmark — "Tweakd" with an accent full stop.
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
              children: [
                TextSpan(text: 'Twea'),
                TextSpan(
                  text: 'k',
                  style: TextStyle(color: AppColors.accent),
                ),
                TextSpan(text: 'd'),
                TextSpan(
                  text: '.',
                  style: TextStyle(color: AppColors.accent),
                ),
              ],
            ),
          ),
          const Spacer(),
          const _UnreadPillButton<NotificationsUnreadCubit>(
            icon: Icons.notifications_none_rounded,
            route: '/notifications',
          ),
          const SizedBox(width: 10),
          const _UnreadPillButton<DmUnreadCubit>(
            icon: Icons.send_rounded,
            route: '/messages',
            iconRotation: -45,
            iconOffset: Offset(1, -1),
          ),
        ],
      ),
    );
  }
}

/// A pill button backed by an [UnreadCountCubit] badge. Refreshes the count
/// when the feed mounts and again on returning from [route] (where reads
/// clear it server-side) — so any unread surface gets refresh-on-return for
/// free.
class _UnreadPillButton<C extends UnreadCountCubit> extends StatefulWidget {
  final IconData icon;
  final String route;
  final double iconRotation;
  final Offset iconOffset;

  const _UnreadPillButton({
    required this.icon,
    required this.route,
    this.iconRotation = 0,
    this.iconOffset = Offset.zero,
  });

  @override
  State<_UnreadPillButton<C>> createState() => _UnreadPillButtonState<C>();
}

class _UnreadPillButtonState<C extends UnreadCountCubit>
    extends State<_UnreadPillButton<C>> {
  @override
  void initState() {
    super.initState();
    context.read<C>().refresh();
  }

  Future<void> _open() async {
    await context.push(widget.route);
    if (mounted) context.read<C>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return _PillButton(
      icon: widget.icon,
      iconRotation: widget.iconRotation,
      iconOffset: widget.iconOffset,
      onTap: _open,
      badge: BlocBuilder<C, int>(
        builder: (context, count) =>
            count > 0 ? _UnreadBadge(count: count) : const SizedBox.shrink(),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Widget? badge;
  final double iconRotation;
  final Offset iconOffset;

  const _PillButton({
    required this.icon,
    required this.onTap,
    this.badge,
    this.iconRotation = 0,
    this.iconOffset = Offset.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AppPillButton(
          icon: icon,
          onTap: onTap,
          iconRotation: iconRotation,
          iconOffset: iconOffset,
        ),
        if (badge != null) Positioned(top: -5, right: -5, child: badge!),
      ],
    );
  }
}

/// Small accent count chip on an unread pill. Caps at "99+".
class _UnreadBadge extends StatelessWidget {
  final int count;

  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    return Container(
      constraints: const BoxConstraints(minWidth: 18),
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.bg, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}
