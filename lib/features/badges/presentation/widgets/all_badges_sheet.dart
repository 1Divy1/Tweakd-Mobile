import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/badge.dart';
import '../../domain/entities/user_badge.dart';
import '../pages/badge_detail_page.dart';
import 'badge_art.dart';

/// Opens the badge sheet for the profile being viewed: every badge that
/// profile has earned, newest unlock first.
///
/// Nothing is fetched here — the list arrived with the profile payload. Locked
/// badges are deliberately not shown anywhere in the app, so the sheet is only
/// worth opening when the strip couldn't fit the whole collection.
Future<void> showAllBadgesSheet(
  BuildContext context, {
  required List<UserBadgeEntity> earned,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _AllBadgesSheet(earned: earned),
  );
}

class _AllBadgesSheet extends StatelessWidget {
  final List<UserBadgeEntity> earned;

  const _AllBadgesSheet({required this.earned});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
              l10n.profileBadgesSheetUnlocked(earned.length),
              style: const TextStyle(
                color: AppColors.mute,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (earned.isEmpty) const _EmptyBody() else _BadgeList(earned: earned),
          ],
        ),
      ),
    );
  }
}

class _BadgeList extends StatelessWidget {
  final List<UserBadgeEntity> earned;

  const _BadgeList({required this.earned});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.55,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: earned.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, color: AppColors.line),
        itemBuilder: (context, i) => _BadgeRow(badge: earned[i].badge),
      ),
    );
  }
}

class _BadgeRow extends StatelessWidget {
  final BadgeEntity badge;

  const _BadgeRow({required this.badge});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Close the sheet, then open the badge on its own screen — capture the
        // router first, as the row's context is torn down by the pop.
        final router = GoRouter.of(context);
        Navigator.of(context).pop();
        router.push('/badge', extra: BadgeDetailArgs(badge: badge));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 46,
              height: 46,
              child: Center(child: BadgeArt(badge: badge, size: 40)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    badge.title,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  // Nullable in the contract — the row is the title alone when
                  // the backend has no copy for it.
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
          ],
        ),
      ),
    );
  }
}

/// Unreachable from the strip, which hides itself when nothing is earned, but
/// the sheet is a public entry point and shouldn't open onto a blank panel.
class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
      child: Text(
        AppLocalizations.of(context)!.profileBadgesEmptyVisitor,
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
