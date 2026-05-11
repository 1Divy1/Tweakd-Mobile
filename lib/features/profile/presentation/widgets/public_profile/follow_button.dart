import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../follow/presentation/bloc/bloc.dart';
import '../../../../follow/presentation/bloc/event.dart';
import '../../../../follow/presentation/bloc/state.dart';

class FollowButton extends StatelessWidget {
  final String username;

  const FollowButton({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FollowStatusBloc, FollowStatusState>(
      listenWhen: (_, current) => current is FollowStatusError,
      listener: (context, state) {
        if (state is FollowStatusError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is FollowStatusLoading || state is FollowStatusInitial) {
          return const _FollowButtonShell(
            label: 'FOLLOW',
            icon: Icons.add,
            backgroundColor: AppColors.accent,
            isLoading: true,
          );
        }

        if (state is FollowStatusLoaded) {
          return _buildLoaded(context, state);
        }

        // Error with no previous status — show disabled follow button.
        return const _FollowButtonShell(
          label: 'FOLLOW',
          icon: Icons.add,
          backgroundColor: AppColors.accent,
          enabled: false,
        );
      },
    );
  }

  Widget _buildLoaded(BuildContext context, FollowStatusLoaded state) {
    final status = state.followStatus;

    if (status.isFollowing) {
      return _FollowButtonShell(
        label: 'UNFOLLOW',
        icon: Icons.person_remove_outlined,
        backgroundColor: AppColors.surface,
        textColor: AppColors.ink,
        iconColor: AppColors.ink,
        borderColor: AppColors.line,
        isLoading: state.isUpdating,
        onPressed: () =>
            context.read<FollowStatusBloc>().add(ToggleFollow(username)),
      );
    }

    if (status.isPending) {
      return _FollowButtonShell(
        label: 'REQUESTED',
        icon: Icons.schedule,
        backgroundColor: AppColors.surface,
        textColor: AppColors.mute,
        iconColor: AppColors.mute,
        borderColor: AppColors.line,
        isLoading: state.isUpdating,
        onPressed: () =>
            context.read<FollowStatusBloc>().add(ToggleFollow(username)),
      );
    }

    return _FollowButtonShell(
      label: 'FOLLOW',
      icon: Icons.add,
      backgroundColor: AppColors.accent,
      isLoading: state.isUpdating,
      onPressed: () =>
          context.read<FollowStatusBloc>().add(ToggleFollow(username)),
    );
  }
}

class _FollowButtonShell extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final Color? borderColor;
  final bool isLoading;
  final bool enabled;
  final VoidCallback? onPressed;

  const _FollowButtonShell({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
    this.borderColor,
    this.isLoading = false,
    this.enabled = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: (enabled && !isLoading) ? onPressed : null,
        icon: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: iconColor,
                ),
              )
            : Icon(icon, color: iconColor, size: 20),
        label: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: borderColor != null
                ? BorderSide(color: borderColor!)
                : BorderSide.none,
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
