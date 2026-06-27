import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../bloc/likers/bloc.dart';

/// Opens the likers bottom sheet — the users who liked [postId], paged.
Future<void> showLikersSheet(
  BuildContext context, {
  required String postId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BlocProvider<LikersBloc>(
      create: (_) => getIt<LikersBloc>()..add(LoadLikers(postId)),
      child: const _LikersSheet(),
    ),
  );
}

class _LikersSheet extends StatelessWidget {
  const _LikersSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.postLikersTitle,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.line),
          Expanded(
            child: BlocBuilder<LikersBloc, LikersState>(
              builder: (context, state) {
                return switch (state.status) {
                  LikersStatus.loading => const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  LikersStatus.failure => _CenteredMessage(
                      l10n.postLikersLoadError,
                    ),
                  LikersStatus.success when state.likers.isEmpty =>
                    _CenteredMessage(l10n.postLikersEmpty),
                  LikersStatus.success => NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        if (n.metrics.pixels >=
                            n.metrics.maxScrollExtent - 300) {
                          context.read<LikersBloc>().add(const LoadMoreLikers());
                        }
                        return false;
                      },
                      child: ListView.separated(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount:
                            state.likers.length + (state.isLoadingMore ? 1 : 0),
                        separatorBuilder: (_, _) => const Divider(
                          height: 1,
                          color: AppColors.line2,
                          indent: 70,
                        ),
                        itemBuilder: (context, i) {
                          if (i >= state.likers.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.mute,
                                  ),
                                ),
                              ),
                            );
                          }
                          final user = state.likers[i];
                          final initial = user.username.isNotEmpty
                              ? user.username.characters.first.toUpperCase()
                              : '?';
                          return ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            leading: CircleAvatar(
                              radius: 21,
                              backgroundColor: AppColors.accentSoft,
                              backgroundImage: user.avatarUrl != null
                                  ? NetworkImage(user.avatarUrl!)
                                  : null,
                              child: user.avatarUrl == null
                                  ? Text(
                                      initial,
                                      style: const TextStyle(
                                        color: AppColors.accentHot,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    )
                                  : null,
                            ),
                            title: Text(
                              '@${user.username}',
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              context.push(
                                '/users/${user.username}',
                                extra: user.id,
                              );
                            },
                          );
                        },
                      ),
                    ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  final String text;
  const _CenteredMessage(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.mute,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
