import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

/// Reputation / followers / following, sitting under the display name. The two
/// follow counts open the followers-following page on the matching tab;
/// reputation is a read-out, not a destination — the breakdown and history
/// behind it (`/api/v1/reputation`) have no screen in the app yet.
class ProfileStatsRow extends StatelessWidget {
  final int followers;
  final int following;

  /// Community points. Always a number — `0` is what a new account genuinely
  /// scores, not a missing value.
  final int reputation;

  final String username;
  final bool isOwnProfile;

  const ProfileStatsRow({
    super.key,
    required this.username,
    required this.followers,
    required this.following,
    required this.isOwnProfile,
    required this.reputation,
  });

  /// Past this the labels stop growing. Three of them share one line beside an
  /// 84pt avatar, and a word like "reputation" scaled without limit leaves
  /// nothing but an ellipsis in each column.
  static const maxTextScale = 1.5;

  /// Roughly the width the row wants before its labels start truncating.
  /// [ProfileHeader] compares this against the space left beside the avatar and
  /// drops the row to its own full-width line when it doesn't fit.
  static double minWidthFor(BuildContext context, {required int statCount}) {
    final scale = math.min(
      MediaQuery.textScalerOf(context).scale(1),
      maxTextScale,
    );
    // ~58pt per column at the default scale — about what the longest label
    // ("reputation") measures at 13pt — plus a small gap between them. This is
    // a floor, not a target: the row spreads into whatever it is actually
    // given. Raise it and the counters move under the avatar on more phones;
    // lower it and they stay on the name's line but sit closer together.
    return statCount * 58 * scale + (statCount - 1) * 8;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: maxTextScale,
      child: Row(
        // Each counter is only as wide as its own label, and the row spreads
        // them edge to edge: the first one starts exactly where the display
        // name above it does, the last one ends at the margin. Equal-width
        // columns would centre the first label in its third and push it right
        // of the name.
        //
        // Flexible, not Expanded, so a counter keeps its intrinsic width but
        // still ellipsizes rather than overflowing when the row is squeezed.
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: _Stat(value: reputation, label: l10n.profileStatReputation),
          ),
          Flexible(
            child: _Stat(
              value: followers,
              label: l10n.profileStatFollowers,
              onTap: () => _openFollowList(context, followers: true),
            ),
          ),
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
          style: const TextStyle(
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
          style: const TextStyle(
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
