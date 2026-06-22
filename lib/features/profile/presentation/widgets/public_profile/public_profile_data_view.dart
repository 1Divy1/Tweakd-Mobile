import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../garage/presentation/bloc/bloc.dart';
import '../../../../garage/presentation/bloc/event.dart';
import '../../../../garage/presentation/bloc/state.dart';
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
import 'follow_button.dart';

class PublicProfileDataView extends StatelessWidget {
  final ProfileEntity profile;

  const PublicProfileDataView({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.bg,
      child: Column(
        children: [
          ProfileTopBar(title: AppLocalizations.of(context)!.profileTitle),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context
                    .read<ProfileBloc>()
                    .add(FetchProfileByUsername(profile.username));
                // Refresh every section too (garage today, feed/reels later),
                // so pull-to-refresh behaves like a fresh app open.
                context
                    .read<GarageBloc>()
                    .add(LoadGarageByUsername(profile.username));
                // Keep the refresh spinner up until both fetches settle.
                await Future.wait([
                  context.read<ProfileBloc>().stream.firstWhere(
                        (s) => s is ProfileLoaded || s is ProfileError,
                      ),
                  context.read<GarageBloc>().stream.firstWhere(
                        (s) => s is GarageLoaded || s is GarageError,
                      ),
                ]);
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
                    isOwnProfile: false,
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FollowButton(username: profile.username),
                  ),
                  const SizedBox(height: 22),
                  const GarageSection(isOwner: false),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }
}
