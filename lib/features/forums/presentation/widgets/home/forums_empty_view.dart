import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/forum_suggestion.dart';
import '../shared/forum_section_label.dart';

/// Empty-paddock home: the explainer, popular-hub suggestions (brands and
/// models) that open their hub on tap, and the start-first-thread CTA.
class ForumsEmptyView extends StatelessWidget {
  final List<ForumSuggestionEntity> suggestions;
  final ValueChanged<ForumSuggestionEntity> onOpen;
  final VoidCallback onStartThread;

  const ForumsEmptyView({
    super.key,
    required this.suggestions,
    required this.onOpen,
    required this.onStartThread,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _ExplainerCard(l10n: l10n),
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 24),
            ForumSectionLabel(label: l10n.forumsPopularHubs),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final suggestion in suggestions)
                  _HubChip(
                    suggestion: suggestion,
                    onTap: () => onOpen(suggestion),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          _StartThreadCard(l10n: l10n, onStartThread: onStartThread),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ExplainerCard extends StatelessWidget {
  final AppLocalizations l10n;

  const _ExplainerCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.bgSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: const Icon(Icons.push_pin, color: AppColors.accent, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.forumsEmptyTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.forumsEmptyBody,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.mute,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _HubChip extends StatelessWidget {
  final ForumSuggestionEntity suggestion;
  final VoidCallback onTap;

  const _HubChip({required this.suggestion, required this.onTap});

  IconData get _icon => switch (suggestion.type) {
        ForumSuggestionType.brand => Icons.directions_car_filled_outlined,
        ForumSuggestionType.model => Icons.garage_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 9, 14, 9),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 14, color: AppColors.mute),
            const SizedBox(width: 6),
            Text(
              suggestion.displayName,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded,
                size: 16, color: AppColors.mute),
          ],
        ),
      ),
    );
  }
}

class _StartThreadCard extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onStartThread;

  const _StartThreadCard({required this.l10n, required this.onStartThread});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.forumsCtaTitle,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.forumsCtaBody,
            style: const TextStyle(
              color: AppColors.mute,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onStartThread,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                l10n.forumsStartFirstThread,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
