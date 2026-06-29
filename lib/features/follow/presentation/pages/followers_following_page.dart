import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/shared/widgets/search_error_view.dart';
import '../../domain/entities/follow_list_user.dart';
import '../../../../core/shared/widgets/search_input.dart';
import '../../../../core/shared/widgets/search_loading_view.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../profile/presentation/widgets/shared/profile_top_bar.dart';
import '../bloc/bloc.dart';
import '../bloc/event.dart';
import '../bloc/state.dart';
import '../utils/follow_error_mapper.dart';
import '../widgets/follow_results_view.dart';
import '../widgets/follow_tab_switcher.dart';

class FollowersFollowingPage extends StatefulWidget {
  final String username;
  final int followersCount;
  final int followingCount;
  final bool showFollowers;
  final bool isOwnProfile;

  const FollowersFollowingPage({
    super.key,
    required this.username,
    this.followersCount = 0,
    this.followingCount = 0,
    this.showFollowers = true,
    this.isOwnProfile = false,
  });

  @override
  State<FollowersFollowingPage> createState() => _FollowersFollowingPageState();
}

class _FollowersFollowingPageState extends State<FollowersFollowingPage> {
  late bool _showFollowers;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _showFollowers = widget.showFollowers;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged(bool showFollowers) {
    setState(() {
      _showFollowers = showFollowers;
      _searchController.clear();
      _searchQuery = '';
    });
    final bloc = context.read<FollowBloc>();
    if (showFollowers) {
      bloc.add(LoadFollowers(widget.username));
    } else {
      bloc.add(LoadFollowing(widget.username));
    }
  }

  void _onSearchChanged(String value) => setState(() => _searchQuery = value);

  void _onSearchCleared() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            ProfileTopBar(title: '@${widget.username}'),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Column(
                children: [
                  FollowTabSwitcher(
                    showFollowers: _showFollowers,
                    followersCount: widget.followersCount,
                    followingCount: widget.followingCount,
                    onTabChanged: _onTabChanged,
                  ),
                  const SizedBox(height: 12),
                  SearchInput(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    onClear: _onSearchCleared,
                    autofocus: false,
                    hintText: _showFollowers
                        ? l10n.followSearchFollowersHint
                        : l10n.followSearchFollowingHint,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: BlocBuilder<FollowBloc, FollowState>(
                  builder: (context, state) {
                    if (_showFollowers) {
                      if (state is FollowersLoading) return const SearchLoadingView();
                      if (state is FollowersLoaded) {
                        return FollowResultsView(
                          users: _filtered(state.followers),
                          showFollowers: true,
                          isOwnProfile: widget.isOwnProfile,
                          query: _searchQuery,
                        );
                      }
                    } else {
                      if (state is FollowingLoading) return const SearchLoadingView();
                      if (state is FollowingLoaded) {
                        return FollowResultsView(
                          users: _filtered(state.following),
                          showFollowers: false,
                          isOwnProfile: widget.isOwnProfile,
                          query: _searchQuery,
                        );
                      }
                    }
                    if (state is FollowError) {
                      return SearchErrorView(
                        message: followErrorMessage(l10n, state.code),
                      );
                    }
                    return const SearchLoadingView();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FollowListUserEntity> _filtered(List<FollowListUserEntity> users) {
    if (_searchQuery.isEmpty) return users;
    final q = _searchQuery.toLowerCase();
    return users.where((u) => u.username.toLowerCase().contains(q)).toList();
  }
}
