import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_bottom_nav.dart';
import '../../../domain/entities/profile.dart';
import '../shared/garage_section.dart';
import '../shared/profile_avatar.dart';
import '../shared/profile_bio.dart';
import '../shared/profile_identity.dart';
import '../shared/profile_stats_row.dart';
import '../shared/profile_top_bar.dart';
import 'settings_button.dart';

class MyProfileDataView extends StatelessWidget {
  final ProfileEntity profile;

  const MyProfileDataView({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.bg,
      child: Column(
        children: [
          ProfileTopBar(
            title: 'PROFILE',
            showBackButton: false,
            trailing: SettingsButton(
              onTap: () {
                // Settings flow to be implemented later.
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  ProfileAvatar(
                    avatarUrl: profile.avatarUrl,
                    isVerified: profile.isVerified,
                  ),
                  const SizedBox(height: 14),
                  ProfileIdentity(
                    name: profile.name,
                    username: profile.username,
                  ),
                  if (profile.bio.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ProfileBio(bio: profile.bio),
                  ],
                  const SizedBox(height: 18),
                  ProfileStatsRow(
                    followers: profile.followersCount,
                    following: profile.followingCount,
                  ),
                  const SizedBox(height: 22),
                  const GarageSection(isOwner: true),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          const AppBottomNav(activeTab: AppBottomNavTab.profile),
        ],
      ),
    );
  }
}
