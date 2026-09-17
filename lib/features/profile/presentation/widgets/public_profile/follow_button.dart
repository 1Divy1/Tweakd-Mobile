import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../follow/presentation/bloc/bloc.dart';
import '../../../../follow/presentation/bloc/event.dart';
import '../../../../follow/presentation/bloc/state.dart';
import '../../../../follow/presentation/utils/follow_error_mapper.dart';
import '../../../../follow/presentation/widgets/follow_confirm_sheet.dart';

/// The follow CTA on a public profile. It names the current relationship
/// ("Following", "Requested") rather than the action that would undo it, and
/// unfollowing goes through a confirmation sheet.
class FollowButton extends StatelessWidget {
  final String username;
  final String? avatarUrl;

  const FollowButton({super.key, required this.username, this.avatarUrl});

  Future<void> _confirmUnfollow(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<FollowBloc>();
    final confirmed = await showFollowConfirmSheet(
      context,
      username: username,
      avatarUrl: avatarUrl,
      title: l10n.followUnfollowConfirmTitle(username),
      body: l10n.followUnfollowConfirmBody,
      confirmLabel: l10n.followActionUnfollow,
    );
    if (confirmed) bloc.add(ToggleFollow(username));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FollowBloc, FollowState>(
      listenWhen: (_, current) => current is FollowError,
      listener: (context, state) {
        if (state is FollowError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                followErrorMessage(AppLocalizations.of(context)!, state.code),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        if (state is FollowStatusLoading || state is FollowStatusInitial) {
          return _FollowButtonShell(
            label: l10n.followActionFollow,
            icon: Icons.add,
            backgroundColor: AppColors.accent,
            isLoading: true,
          );
        }

        if (state is FollowStatusLoaded) {
          return _buildLoaded(context, state);
        }

        // Error with no previous status — show disabled follow button.
        return _FollowButtonShell(
          label: l10n.followActionFollow,
          icon: Icons.add,
          backgroundColor: AppColors.accent,
          enabled: false,
        );
      },
    );
  }

  Widget _buildLoaded(BuildContext context, FollowStatusLoaded state) {
    final l10n = AppLocalizations.of(context)!;
    final status = state.followStatus;

    if (status.isFollowing) {
      return _FollowButtonShell(
        label: l10n.followActionFollowing,
        icon: Icons.check_rounded,
        backgroundColor: AppColors.surface,
        textColor: AppColors.ink,
        iconColor: AppColors.ink,
        isLoading: state.isUpdating,
        onPressed: () => _confirmUnfollow(context),
      );
    }

    if (status.isPending) {
      // Withdrawing a request that was never accepted costs nothing, so it
      // stays a single tap.
      return _FollowButtonShell(
        label: l10n.followActionRequested,
        icon: Icons.schedule,
        backgroundColor: AppColors.surface,
        textColor: AppColors.mute,
        iconColor: AppColors.mute,
        isLoading: state.isUpdating,
        onPressed: () => context.read<FollowBloc>().add(ToggleFollow(username)),
      );
    }

    return _FollowButtonShell(
      label: l10n.followActionFollow,
      icon: Icons.add,
      backgroundColor: AppColors.accent,
      isLoading: state.isUpdating,
      onPressed: () => context.read<FollowBloc>().add(ToggleFollow(username)),
    );
  }
}

/// Styled to pair with [ProfileActionButton] in the same row: same minimum
/// height, radius, padding and label type. The label stays on one line and
/// ellipsizes; the height grows with the text scale instead of clipping.
class _FollowButtonShell extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final bool isLoading;
  final bool enabled;
  final VoidCallback? onPressed;

  const _FollowButtonShell({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
    this.isLoading = false,
    this.enabled = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
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
            : Icon(icon, color: iconColor, size: 19),
        // No Flexible here: ElevatedButton.icon already wraps the label in one.
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.6),
          minimumSize: const Size.fromHeight(50),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
