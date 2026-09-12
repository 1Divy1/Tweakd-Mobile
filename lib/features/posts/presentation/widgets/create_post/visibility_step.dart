import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import 'create_post_fields.dart';

/// The set of per-counter visibility toggles for a post. When a counter is
/// hidden, others can still like / comment / share — only the number is hidden.
class PostVisibility {
  final bool showLikes;
  final bool showComments;
  final bool showShares;
  final bool showSaved;

  const PostVisibility({
    this.showLikes = true,
    this.showComments = true,
    this.showShares = true,
    this.showSaved = true,
  });

  PostVisibility copyWith({
    bool? showLikes,
    bool? showComments,
    bool? showShares,
    bool? showSaved,
  }) {
    return PostVisibility(
      showLikes: showLikes ?? this.showLikes,
      showComments: showComments ?? this.showComments,
      showShares: showShares ?? this.showShares,
      showSaved: showSaved ?? this.showSaved,
    );
  }
}

/// Step 4 — choose which engagement counters are publicly visible.
class VisibilityStep extends StatelessWidget {
  final PostVisibility visibility;
  final ValueChanged<PostVisibility> onChanged;

  const VisibilityStep({
    super.key,
    required this.visibility,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostStepHeader(
          title: l10n.postVisibilityTitle,
          subtitle: l10n.postVisibilitySubtitle,
        ),
        const SizedBox(height: 24),
        PostFieldLabel(l10n.postVisibilityLabel),
        const SizedBox(height: 8),
        PostSurface(
          child: Column(
            children: [
              _ToggleRow(
                icon: Icons.favorite_rounded,
                title: l10n.postVisibilityLikesTitle,
                description: l10n.postVisibilityLikesDesc,
                value: visibility.showLikes,
                onChanged: (v) =>
                    onChanged(visibility.copyWith(showLikes: v)),
              ),
              Divider(height: 1, color: AppColors.line2),
              _ToggleRow(
                icon: Icons.mode_comment_rounded,
                title: l10n.postVisibilityCommentsTitle,
                description: l10n.postVisibilityCommentsDesc,
                value: visibility.showComments,
                onChanged: (v) =>
                    onChanged(visibility.copyWith(showComments: v)),
              ),
              Divider(height: 1, color: AppColors.line2),
              _ToggleRow(
                icon: Icons.ios_share_rounded,
                title: l10n.postVisibilitySharesTitle,
                description: l10n.postVisibilitySharesDesc,
                value: visibility.showShares,
                onChanged: (v) =>
                    onChanged(visibility.copyWith(showShares: v)),
              ),
              Divider(height: 1, color: AppColors.line2),
              _ToggleRow(
                icon: Icons.bookmark_rounded,
                title: l10n.postVisibilitySavedTitle,
                description: l10n.postVisibilitySavedDesc,
                value: visibility.showSaved,
                onChanged: (v) =>
                    onChanged(visibility.copyWith(showSaved: v)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: value ? AppColors.accentSoft : AppColors.bg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              size: 19,
              color: value ? AppColors.accent : AppColors.muteSoft,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.mute,
                    fontSize: 12.5,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.accent,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.muteSoft,
            trackOutlineColor:
                const WidgetStatePropertyAll(Colors.transparent),
          ),
        ],
      ),
    );
  }
}

