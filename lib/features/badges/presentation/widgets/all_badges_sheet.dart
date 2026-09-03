import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/badge.dart';
import '../../domain/entities/user_badge.dart';
import '../bloc/bloc.dart';
import '../bloc/event.dart';
import '../bloc/state.dart';
import '../pages/badge_detail_page.dart';
import 'badge_art.dart';

/// Opens the badge sheet for the profile being viewed: everything unlocked
/// first, then — on your own profile only — what's still locked.
///
/// The earned half is handed in: it arrived with the profile payload. The
/// locked half is fetched here, the first time the sheet is opened, because
/// `GET /badges/me/locked` is the one badge call the profile doesn't cover and
/// most visits never need it. There is deliberately no public locked list, so a
/// visitor's sheet is the earned half alone.
Future<void> showAllBadgesSheet(
  BuildContext context, {
  required List<UserBadgeEntity> earned,
  required bool isOwner,
}) {
  // Only your own profile provides a BadgesBloc — reading it on someone else's
  // would throw.
  final bloc = isOwner ? context.read<BadgesBloc>() : null;
  if (bloc != null &&
      (bloc.state is BadgesInitial || bloc.state is BadgesError)) {
    bloc.add(const LoadLockedBadges());
  }

  final sheet = _AllBadgesSheet(earned: earned, isOwner: isOwner);
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => bloc == null
        ? sheet
        : BlocProvider<BadgesBloc>.value(value: bloc, child: sheet),
  );
}

class _AllBadgesSheet extends StatelessWidget {
  final List<UserBadgeEntity> earned;
  final bool isOwner;

  const _AllBadgesSheet({required this.earned, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    if (!isOwner) return _Body(earned: earned, isOwner: false);
    return BlocBuilder<BadgesBloc, BadgesState>(
      builder: (context, state) => _Body(
        earned: earned,
        isOwner: true,
        locked: state is BadgesLoaded ? state.locked : const [],
        loadingLocked: state is BadgesLoading,
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final List<UserBadgeEntity> earned;
  final bool isOwner;
  final List<BadgeEntity> locked;
  final bool loadingLocked;

  const _Body({
    required this.earned,
    required this.isOwner,
    this.locked = const [],
    this.loadingLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // The total is only knowable once the locked list has landed, and never on
    // someone else's profile — so the count says what it can.
    final subtitle = locked.isEmpty
        ? l10n.profileBadgesSheetUnlocked(earned.length)
        : l10n.profileBadgesSheetSubtitle(
            earned.length,
            earned.length + locked.length,
          );

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.profileBadgesSheetTitle,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.mute,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (earned.isEmpty && locked.isEmpty && !loadingLocked)
              _EmptyBody(isOwner: isOwner)
            else
              _BadgeList(
                earned: earned,
                locked: locked,
                loadingLocked: loadingLocked,
              ),
          ],
        ),
      ),
    );
  }
}

class _BadgeList extends StatelessWidget {
  final List<UserBadgeEntity> earned;
  final List<BadgeEntity> locked;
  final bool loadingLocked;

  const _BadgeList({
    required this.earned,
    required this.locked,
    required this.loadingLocked,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      for (final entry in earned) _BadgeRow(badge: entry.badge, earned: true),
      for (final badge in locked) _BadgeRow(badge: badge, earned: false),
    ];

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.55,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        // One trailing row while the locked half is still in flight, so the
        // sheet doesn't look finished when it isn't.
        itemCount: rows.length + (loadingLocked ? 1 : 0),
        separatorBuilder: (_, _) =>
            const Divider(height: 1, color: AppColors.line),
        itemBuilder: (context, i) => i < rows.length
            ? rows[i]
            : const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.muteSoft,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _BadgeRow extends StatelessWidget {
  final BadgeEntity badge;
  final bool earned;

  const _BadgeRow({required this.badge, required this.earned});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Close the sheet, then open the badge on its own screen — capture the
        // router first, as the row's context is torn down by the pop.
        final router = GoRouter.of(context);
        Navigator.of(context).pop();
        router.push(
          '/badge',
          extra: BadgeDetailArgs(badge: badge, locked: !earned),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 46,
              height: 46,
              child: Center(
                child: BadgeArt(badge: badge, size: 40, locked: !earned),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    badge.title,
                    style: TextStyle(
                      color: earned ? AppColors.ink : AppColors.mute,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  // Nullable in the contract — the row is the title alone when
                  // the backend has no "how to unlock" copy for it.
                  if (badge.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      badge.description!,
                      style: const TextStyle(
                        color: AppColors.mute,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!earned) ...[
              const SizedBox(width: 10),
              Text(
                l10n.profileBadgesLocked,
                style: const TextStyle(
                  color: AppColors.muteSoft,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  final bool isOwner;

  const _EmptyBody({required this.isOwner});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
      child: Text(
        isOwner ? l10n.profileBadgesEmptyOwner : l10n.profileBadgesEmptyVisitor,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.mute,
          fontSize: 14,
          height: 1.4,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
