import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../bloc/compose/bloc.dart';
import '../../bloc/compose/event.dart';
import '../../bloc/compose/state.dart';
import '../../utils/feedback_feed_error_mapper.dart';
import '../../utils/feedback_feed_visuals.dart';

/// The compose body: the intro copy, the category chips, the message field and
/// the post button.
///
/// The text lives in a [TextEditingController] and is mirrored into the bloc on
/// every edit, so the counter and the button's enabled state stay in step
/// without the field losing its cursor.
class FeedbackComposeForm extends StatefulWidget {
  final ComposeFeedbackState state;

  const FeedbackComposeForm({super.key, required this.state});

  @override
  State<FeedbackComposeForm> createState() => _FeedbackComposeFormState();
}

class _FeedbackComposeFormState extends State<FeedbackComposeForm> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.message)
      ..addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() {
    context.read<ComposeFeedbackBloc>().add(
          FeedbackMessageChanged(_controller.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = widget.state;
    final isSubmitting = state.status == ComposeFeedbackStatus.submitting;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            children: [
              _Eyebrow(label: l10n.feedbackFeedComposeEyebrow),
              const SizedBox(height: 10),
              Text(
                l10n.feedbackFeedComposeTitle,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.feedbackFeedComposeSubtitle,
                style: TextStyle(
                  color: AppColors.mute,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              _SectionLabel(label: l10n.feedbackFeedCategoryLabel),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final type in state.types)
                    _CategoryChip(
                      label: type.label,
                      dotColor: feedbackTypeColors(type.id).dot,
                      selected: state.selectedTypeId == type.id,
                      onTap: isSubmitting
                          ? null
                          : () => context
                              .read<ComposeFeedbackBloc>()
                              .add(SelectFeedbackType(type.id)),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              _SectionLabel(label: l10n.feedbackFeedMessageLabel),
              const SizedBox(height: 10),
              _MessageField(
                controller: _controller,
                enabled: !isSubmitting,
                hint: l10n.feedbackFeedMessageHint,
              ),
              if (state.submitError != null) ...[
                const SizedBox(height: 14),
                Text(
                  feedbackFeedErrorMessage(l10n, state.submitError!),
                  style: TextStyle(
                    color: AppColors.accentHot,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
        _PostButton(
          label: l10n.feedbackFeedPostAction,
          isEnabled: state.canSubmit,
          isSubmitting: isSubmitting,
          onTap: () => context
              .read<ComposeFeedbackBloc>()
              .add(const SubmitFeedbackMessage()),
        ),
      ],
    );
  }
}

class _Eyebrow extends StatelessWidget {
  final String label;

  const _Eyebrow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 2, color: AppColors.accent),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: AppColors.accent,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: AppColors.ink2,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }
}

/// A category choice: a coloured dot plus the backend's label. Selected chips
/// take an ink border so the choice reads without relying on colour alone.
class _CategoryChip extends StatelessWidget {
  final String label;
  final Color dotColor;
  final bool selected;
  final VoidCallback? onTap;

  const _CategoryChip({
    required this.label,
    required this.dotColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.ink : AppColors.line,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.ink : AppColors.ink2,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The message textarea with a "n / 500" counter in its bottom-right corner.
class _MessageField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final String hint;

  const _MessageField({
    required this.controller,
    required this.enabled,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: controller,
            enabled: enabled,
            maxLines: 6,
            minLines: 6,
            // Hard cap at the backend's limit, so an over-long message can't be
            // typed and then rejected server-side.
            maxLength: kFeedbackMessageMaxLength,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.muteSoft,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              // Suppress the built-in counter; a custom one sits below.
              counterText: '',
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) => Text(
              '${value.text.length} / $kFeedbackMessageMaxLength',
              style: TextStyle(
                color: AppColors.muteSoft,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The full-width submit button, pinned above the keyboard/home indicator.
class _PostButton extends StatelessWidget {
  final String label;
  final bool isEnabled;
  final bool isSubmitting;
  final VoidCallback onTap;

  const _PostButton({
    required this.label,
    required this.isEnabled,
    required this.isSubmitting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = isEnabled && !isSubmitting;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: GestureDetector(
        onTap: isActive ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 56,
          decoration: BoxDecoration(
            color: isActive ? AppColors.ink : AppColors.muteSoft,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
