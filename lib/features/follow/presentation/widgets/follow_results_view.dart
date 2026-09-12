import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/follow_list_user.dart';
import '../bloc/bloc.dart';
import '../bloc/event.dart';
import 'follow_user_card.dart';

class FollowResultsView extends StatelessWidget {
  final List<FollowListUserEntity> users;
  final bool showFollowers;
  final bool isOwnProfile;
  final String query;

  const FollowResultsView({
    super.key,
    required this.users,
    required this.showFollowers,
    required this.isOwnProfile,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return _NoResults(query: query, showFollowers: showFollowers);
    }

    final l10n = AppLocalizations.of(context)!;
    final label =
        showFollowers ? l10n.profileStatFollowers : l10n.profileStatFollowing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ResultsHeader(count: users.length, label: label, query: query),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: users.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final user = users[index];
              return FollowUserCard(
                user: user,
                query: query,
                isFollowing: user.isFollowing,
                showRemoveButton: showFollowers && isOwnProfile,
                onTap: () =>
                    context.push('/users/${user.username}', extra: user.id),
                onFollowTap: () => context.read<FollowBloc>().add(
                  ToggleFollowInList(user.username),
                ),
                onRemoveFollowerTap: () => context.read<FollowBloc>().add(
                  RemoveFollowerFromList(user.username),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  final int count;
  final String label;
  final String query;

  const _ResultsHeader({
    required this.count,
    required this.label,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
      child: Row(
        children: [
          Text(
            '$count $label',
            style: TextStyle(
              color: AppColors.muteSoft,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          if (query.isNotEmpty) ...[
            const Spacer(),
            Text(
              AppLocalizations.of(context)!.followResultsForQuery(query),
              style: TextStyle(
                color: AppColors.muteSoft,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;
  final bool showFollowers;

  const _NoResults({required this.query, required this.showFollowers});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final message = query.isNotEmpty
        ? l10n.followNoResultsQuery(query)
        : showFollowers
        ? l10n.followNoFollowers
        : l10n.followNoFollowing;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.group_outlined,
              size: 36,
              color: AppColors.muteSoft,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mute,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
