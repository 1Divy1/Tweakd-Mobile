import 'package:tweakd/features/map_events/presentation/widgets/my_events/my_events_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/shared/widgets/app_bottom_nav.dart';
import '../../../../badges/presentation/widgets/badge_strip.dart';
import '../../../../garage/presentation/bloc/bloc.dart';
import '../../../../garage/presentation/bloc/event.dart';
import '../../../../garage/presentation/bloc/state.dart';
import '../../../../posts/presentation/bloc/profile_posts/bloc.dart';
import '../../../../posts/presentation/bloc/profile_posts/event.dart';
import '../../../../posts/presentation/bloc/profile_posts/state.dart';
import '../../../../tags/presentation/bloc/tags/bloc.dart';
import '../../../../tags/presentation/bloc/tags/event.dart';
import '../../../../tags/presentation/bloc/tags/state.dart';
import '../../../../tags/presentation/widgets/tags_section.dart';
import '../../../domain/entities/profile.dart';
import '../../bloc/bloc.dart';
import '../../bloc/event.dart';
import '../../bloc/state.dart';
import '../shared/garage_section.dart';
import '../shared/posts_section.dart';
import '../shared/profile_content_frame.dart';
import '../shared/profile_header.dart';
import '../shared/profile_section_tabs.dart';
import '../shared/profile_tabs_sliver_header.dart';
import '../shared/profile_top_bar.dart';
import 'create_button.dart';
import 'edit_profile_button.dart';
import 'share_profile_button.dart';
import 'settings_button.dart';

class MyProfileDataView extends StatefulWidget {
  final ProfileEntity profile;

  const MyProfileDataView({super.key, required this.profile});

  @override
  State<MyProfileDataView> createState() => _MyProfileDataViewState();
}

class _MyProfileDataViewState extends State<MyProfileDataView> {
  ProfileSection _section = ProfileSection.garage;

  Future<void> _openEditProfile(BuildContext context) async {
    final bloc = context.read<ProfileBloc>();
    await context.push('/profile/edit', extra: widget.profile);
    // The repository cache is already refreshed by a successful edit; force a
    // remote fetch anyway so the profile always reflects the latest on return.
    bloc.add(const FetchUserProfileData(fetchFromRemote: true));
  }

  Future<void> _refresh() async {
    // Force a remote fetch — the default (fetchFromRemote: false) returns the
    // repository's cached profile, so the request never leaves the device and
    // counts stay stale.
    context.read<ProfileBloc>().add(
      const FetchUserProfileData(fetchFromRemote: true),
    );
    // Refresh every section too, so pull-to-refresh behaves like a fresh app
    // open.
    context.read<GarageBloc>().add(const LoadMyGarage());
    context.read<ProfilePostsBloc>().add(const LoadMyPosts());
    // Earned badges ride along with the profile fetch above — the badges
    // feature has no call of its own to repeat here.
    // Tags load lazily, so only refresh them once the tab has actually been
    // opened — otherwise pull-to-refresh would trigger the very fetch the lazy
    // load is avoiding.
    final tagsBloc = context.read<TagsBloc>();
    if (tagsBloc.state is! TagsInitial) {
      tagsBloc.add(const RefreshTags());
    }
    // Keep the refresh spinner up until the fetches settle.
    await Future.wait([
      context.read<ProfileBloc>().stream.firstWhere(
        (s) => s is ProfileLoaded || s is ProfileError,
      ),
      context.read<GarageBloc>().stream.firstWhere(
        (s) => s is GarageLoaded || s is GarageError,
      ),
      context.read<ProfilePostsBloc>().stream.firstWhere(
        (s) => s is ProfilePostsLoaded || s is ProfilePostsError,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    return ProfileContentFrame(
      child: Column(
        children: [
          ProfileTopBar(
            title: '@${profile.username}',
            showBackButton: false,
            isHandle: true,
            // Nothing to go back to on your own profile, so the leading slot
            // carries the create action and the handle sits centred between
            // the two pills instead of floating on its own.
            leading: const CreateButton(),
            trailing: SettingsButton(onTap: () => context.push('/settings')),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.accent,
              backgroundColor: AppColors.surface,
              strokeWidth: 2.5,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        ProfileHeader(profile: profile, isOwnProfile: true),
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: EditProfileButton(
                                  onTap: () => _openEditProfile(context),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(child: ShareProfileButton()),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        BadgeStrip(badges: profile.badges),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: ProfileTabsSliverHeader(
                      active: _section,
                      onChanged: (s) => setState(() => _section = s),
                      height: ProfileTabsSliverHeader.heightFor(context),
                      // Your own profile is the only place events can live:
                      // `/map-events/mine` is scoped to the caller.
                      showEvents: true,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 22, bottom: 24),
                      child: switch (_section) {
                        ProfileSection.garage => const GarageSection(
                          isOwner: true,
                        ),
                        ProfileSection.posts => const PostsSection(
                          isOwner: true,
                        ),
                        ProfileSection.tags => TagsSection(
                          isOwner: true,
                          username: profile.username,
                        ),
                        ProfileSection.events => const MyEventsSection(),
                      },
                    ),
                  ),
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
