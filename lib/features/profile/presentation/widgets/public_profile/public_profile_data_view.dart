import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../report/domain/entities/report_target.dart';
import '../../../../report/presentation/widgets/report_reason_sheet.dart';
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
import 'follow_button.dart';
import 'message_button.dart';
import 'profile_options_sheet.dart';

class PublicProfileDataView extends StatefulWidget {
  final ProfileEntity profile;

  const PublicProfileDataView({super.key, required this.profile});

  @override
  State<PublicProfileDataView> createState() => _PublicProfileDataViewState();
}

class _PublicProfileDataViewState extends State<PublicProfileDataView> {
  ProfileSection _section = ProfileSection.garage;

  Future<void> _refresh() async {
    final username = widget.profile.username;
    context.read<ProfileBloc>().add(FetchProfileByUsername(username));
    // Refresh every section too, so pull-to-refresh behaves like a fresh app
    // open.
    context.read<GarageBloc>().add(LoadGarageByUsername(username));
    context.read<ProfilePostsBloc>().add(LoadPostsByUsername(username));
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
            alignTitleStart: true,
            isHandle: true,
            trailing: _ProfileMenuButton(username: profile.username),
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
                        ProfileHeader(profile: profile, isOwnProfile: false),
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: FollowButton(username: profile.username),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: MessageButton(profile: profile)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        BadgeStrip(badges: profile.badges, isOwner: false),
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
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 22, bottom: 24),
                      child: switch (_section) {
                        ProfileSection.garage => const GarageSection(
                          isOwner: false,
                        ),
                        ProfileSection.posts => const PostsSection(
                          isOwner: false,
                        ),
                        ProfileSection.tags => TagsSection(
                          isOwner: false,
                          username: profile.username,
                        ),
                        // Unreachable: the Events tab isn't offered here
                        // (`showEvents` defaults to false) because
                        // `/map-events/mine` only ever describes the caller.
                        ProfileSection.events => const SizedBox.shrink(),
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The public profile "⋯" button. Opens the account options sheet; on a
/// successful "Report account" it redirects to the feed and clears the back
/// stack so the viewer can't navigate back to the reported profile.
class _ProfileMenuButton extends StatelessWidget {
  final String username;

  const _ProfileMenuButton({required this.username});

  Future<void> _openMenu(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final action = await showProfileOptionsSheet(context);
    if (action != ProfileMenuAction.report || !context.mounted) return;

    final reported = await showReportSheet(
      context,
      target: ProfileReportTarget(username),
      title: l10n.profileReportAccount,
    );
    if (reported && context.mounted) context.go('/feed');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openMenu(context),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 44,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.more_horiz, color: AppColors.ink, size: 20),
      ),
    );
  }
}
