import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

/// Followers / following, sitting under the display name. Each count opens the
/// followers-following page on the matching tab.
///
/// Reputation used to sit first in this row. It is paused (see
/// `REPUTATION_PROGRESS.md`): hidden from the UI while `ProfileEntity` still
/// carries `reputationScore`, so bringing it back is a UI-only change.
class ProfileStatsRow extends StatelessWidget {
  final int followers;
  final int following;

  final String username;
  final bool isOwnProfile;

  const ProfileStatsRow({
    super.key,
    required this.username,
    required this.followers,
    required this.following,
    required this.isOwnProfile,
  });

  /// Past this the labels stop growing. They share one line beside the
  /// avatar, and a word like "followers" scaled without limit leaves nothing
  /// but an ellipsis in each column.
  static const maxTextScale = 1.5;

  /// Space between two counters. The row is left-aligned under the name, so
  /// this — not the row's width — is what separates them.
  static const _gap = 28.0;

  /// Roughly the width the row wants before its labels start truncating.
  /// [ProfileHeader] compares this against the space left beside the avatar and
  /// drops the row to its own full-width line when it doesn't fit.
  static double minWidthFor(BuildContext context, {required int statCount}) {
    final scale = math.min(
      MediaQuery.textScalerOf(context).scale(1),
      maxTextScale,
    );
    // ~58pt per column at the default scale — about what the longest label
    // ("followers") measures at 13pt — plus the gap between them. Raise it
    // and the counters move under the avatar on more phones; lower it and
    // they stay on the name's line but risk ellipsizing their labels.
    return statCount * 58 * scale + (statCount - 1) * _gap;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: maxTextScale,
      child: Row(
        // Left-aligned with a fixed gap, so the first counter starts exactly
        // where the display name above it does. Spreading two counters edge to
        // edge would strand the second one at the far margin.
        //
        // Flexible, not Expanded, so a counter keeps its intrinsic width but
        // still ellipsizes rather than overflowing when the row is squeezed.
        children: [
          Flexible(
            child: _Stat(
              value: followers,
              label: l10n.profileStatFollowers,
              onTap: () => _openFollowList(context, followers: true),
            ),
          ),
          const SizedBox(width: _gap),
          Flexible(
            child: _Stat(
              value: following,
              label: l10n.profileStatFollowing,
              onTap: () => _openFollowList(context, followers: false),
            ),
          ),
        ],
      ),
    );
  }

  void _openFollowList(BuildContext context, {required bool followers}) {
    context.push(
      followers ? '/followers' : '/following',
      extra: {
        'username': username,
        'followersCount': this.followers,
        'followingCount': following,
        'isOwnProfile': isOwnProfile,
      },
    );
  }
}

class _Stat extends StatelessWidget {
  final int value;
  final String label;
  final VoidCallback? onTap;

  const _Stat({required this.value, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Sized to its widest line — the label — with the count centred over it.
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatCount(value),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.mute,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
    if (onTap == null) return column;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: column,
    );
  }

  String _formatCount(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
