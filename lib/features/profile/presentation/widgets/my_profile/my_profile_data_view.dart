import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/shared/widgets/app_bottom_nav.dart';
import '../../../domain/entities/profile.dart';
import '../../bloc/bloc.dart';
import '../../bloc/event.dart';
import '../../bloc/state.dart';
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
                // TODO: Implement settings flow
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // Force a remote fetch — the default (fetchFromRemote: false)
                // returns the repository's cached profile, so the request
                // never leaves the device and counts stay stale.
                context
                    .read<ProfileBloc>()
                    .add(const FetchUserProfileData(fetchFromRemote: true));
                // Keep the refresh spinner up until the fetch settles.
                await context.read<ProfileBloc>().stream.firstWhere(
                      (s) => s is ProfileLoaded || s is ProfileError,
                    );
              },
              color: AppColors.accent,
              backgroundColor: AppColors.surface,
              strokeWidth: 2.5,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                    username: profile.username,
                    followers: profile.followersCount,
                    following: profile.followingCount,
                    isOwnProfile: true,
                  ),
                  const SizedBox(height: 22),
                  const GarageSection(isOwner: true),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          ),
          const AppBottomNav(activeTab: AppBottomNavTab.profile),
        ],
      ),
    );
  }
}
