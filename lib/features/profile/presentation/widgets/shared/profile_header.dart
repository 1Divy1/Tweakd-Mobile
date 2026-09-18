import 'package:flutter/material.dart';

import '../../../domain/entities/profile.dart';
import 'profile_avatar.dart';
import 'profile_bio.dart';
import 'profile_identity.dart';
import 'profile_stats_row.dart';

/// The block above the profile actions: avatar on the left, display name and
/// the follower/following counters beside it, bio underneath at
/// full width.
///
/// Shared by both profiles — only [isOwnProfile] differs, and it only decides
/// which tab the counts open.
class ProfileHeader extends StatelessWidget {
  final ProfileEntity profile;
  final bool isOwnProfile;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.isOwnProfile,
  });

  /// How big the profile picture is. **This is the knob** — change this one
  /// number and everything else follows: the name and counters take whatever
  /// width is left beside it, and the counters spread across that width.
  ///
  /// The only thing it competes with is [ProfileStatsRow.minWidthFor]. Once
  /// the avatar leaves the counters less room than that, they stop sharing the
  /// line and move to their own full-width row underneath (see below) — so if
  /// a bigger avatar makes them jump down on a phone you care about, that
  /// estimate is what to lower, not this.
  static const avatarSize = 100.0;

  static const _avatarGap = 18.0;

  @override
  Widget build(BuildContext context) {
    final stats = ProfileStatsRow(
      username: profile.username,
      followers: profile.followersCount,
      following: profile.followingCount,
      isOwnProfile: isOwnProfile,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // The counters beside the avatar need room. On a small phone — or
          // at a large text size — they don't get it, so the row drops to its
          // own full-width line under the avatar instead of ellipsizing every
          // label.
          final besideAvatar = constraints.maxWidth - avatarSize - _avatarGap;
          final wanted = ProfileStatsRow.minWidthFor(context, statCount: 2);
          final statsFitBesideAvatar = besideAvatar >= wanted;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ProfileAvatar(
                    avatarUrl: profile.avatarUrl,
                    isVerified: profile.isVerified,
                    size: avatarSize,
                  ),
                  const SizedBox(width: _avatarGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ProfileIdentity(name: profile.name),
                        if (statsFitBesideAvatar) ...[
                          const SizedBox(height: 10),
                          stats,
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (!statsFitBesideAvatar) ...[const SizedBox(height: 16), stats],
              if (profile.bio.isNotEmpty) ...[
                const SizedBox(height: 16),
                ProfileBio(bio: profile.bio),
              ],
            ],
          );
        },
      ),
    );
  }
}
