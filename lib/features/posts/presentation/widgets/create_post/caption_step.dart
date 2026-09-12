import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import 'create_post_fields.dart';

/// Maximum length of a post's description.
const postMaxCaptionLength = 2200;

/// Step 2 — the post's free-text description. Hashtag suggestions are a future
/// feature; only the description box is shown here.
class CaptionStep extends StatelessWidget {
  final TextEditingController controller;

  const CaptionStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostStepHeader(
          title: l10n.postCaptionTitle,
          subtitle: l10n.postCaptionSubtitle,
        ),
        const SizedBox(height: 24),
        PostFieldLabel(l10n.postCaptionLabel),
        const SizedBox(height: 8),
        // Rebuilds the live character counter as the user types.
        AnimatedBuilder(
          animation: controller,
          builder: (context, _) => _DescriptionBox(
            controller: controller,
            hint: l10n.postCaptionHint,
            counter: l10n.postCaptionCounter(
              controller.text.characters.length,
              postMaxCaptionLength,
            ),
          ),
        ),
      ],
    );
  }
}

class _DescriptionBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String counter;

  const _DescriptionBox({
    required this.controller,
    required this.hint,
    required this.counter,
  });

  @override
  Widget build(BuildContext context) {
    return PostSurface(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: controller,
            minLines: 5,
            maxLines: 8,
            maxLength: postMaxCaptionLength,
            cursorColor: AppColors.accent,
            buildCounter: (_,
                    {required currentLength,
                    required isFocused,
                    maxLength}) =>
                null,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              isDense: true,
              // Opts out of the theme's square fill, which would otherwise
              // square off the surface's rounded corners.
              filled: false,
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.muteSoft,
                fontSize: 16,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            counter,
            style: TextStyle(
              color: AppColors.muteSoft,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
