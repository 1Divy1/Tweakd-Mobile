import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';

/// Everything the bottom nav's centre create button can start.
enum CreateAction { post, thread, event, modification }

extension CreateActionRoute on CreateAction {
  /// The composer each action opens.
  String get route => switch (this) {
    CreateAction.post => '/posts/create',
    CreateAction.thread => '/forums/new',
    CreateAction.event => '/map-events/create',
    CreateAction.modification => '/garage/modifications/add',
  };
}

/// The chooser behind the create button. A chooser rather than a jump straight
/// into the post composer: there are several things to make, and every row
/// says what it is for, so a new member learns what the app holds by opening
/// it once.
///
/// No title and no close button: the rows explain themselves, and a sheet is
/// dismissed by tapping outside it or swiping it down.
///
/// Resolves to the tapped [CreateAction], or `null` if dismissed.
Future<CreateAction?> showCreateSheet(BuildContext context) {
  return showModalBottomSheet<CreateAction>(
    context: context,
    // Lets the sheet grow past half the screen at large text sizes; the
    // content scrolls if it still doesn't fit.
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.bg,
    constraints: const BoxConstraints(maxWidth: 560),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const _CreateSheet(),
  );
}

class _CreateOption {
  final CreateAction action;
  final IconData icon;
  final String title;
  final String subtitle;

  const _CreateOption(this.action, this.icon, this.title, this.subtitle);
}

class _CreateSheet extends StatelessWidget {
  const _CreateSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = [
      _CreateOption(
        CreateAction.post,
        CupertinoIcons.photo_on_rectangle,
        l10n.createPostTitle,
        l10n.createPostSubtitle,
      ),
      _CreateOption(
        CreateAction.thread,
        CupertinoIcons.bubble_left_bubble_right,
        l10n.createThreadTitle,
        l10n.createThreadSubtitle,
      ),
      _CreateOption(
        CreateAction.event,
        CupertinoIcons.calendar_badge_plus,
        l10n.createEventTitle,
        l10n.createEventSubtitle,
      ),
      _CreateOption(
        CreateAction.modification,
        CupertinoIcons.wrench,
        l10n.createModTitle,
        l10n.createModSubtitle,
      ),
    ];

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // One grouped card, iOS-settings style: rows share a surface and
            // are split by hairlines inset past the icon tile.
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Material(
                color: AppColors.surface,
                child: Column(
                  children: [
                    for (var i = 0; i < options.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          thickness: 1,
                          indent: 72,
                          color: AppColors.line2,
                        ),
                      _CreateRow(option: options[i]),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateRow extends StatelessWidget {
  final _CreateOption option;

  const _CreateRow({required this.option});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).pop(option.action);
      },
      // A highlight, not a ripple — the way an iOS table row answers a tap.
      splashFactory: NoSplash.splashFactory,
      highlightColor: AppColors.line2,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 68),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(option.icon, size: 22, color: AppColors.ink),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.mute,
                        fontSize: 13,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                CupertinoIcons.chevron_forward,
                size: 16,
                color: AppColors.muteSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
