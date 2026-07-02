import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/feedback/bloc.dart';
import '../bloc/feedback/event.dart';
import '../bloc/feedback/state.dart';
import '../utils/feedback_error_mapper.dart';
import '../utils/feedback_type_visuals.dart';
import 'feedback_dropdown_field.dart';
import 'feedback_feature_picker.dart';
import 'feedback_section_label.dart';
import 'feedback_type_picker.dart';

/// Hard cap on the main feedback body, surfaced by the character counter.
const int kFeedbackContentMaxLength = 600;

/// The editable feedback form (type + feature pickers, the body, and — for bug
/// reports — reproduction steps), with a pinned submit button. Stateful so the
/// two free-text fields can live in [TextEditingController]s instead of being
/// pushed through the bloc on every keystroke.
class FeedbackForm extends StatefulWidget {
  final FeedbackState state;

  const FeedbackForm({super.key, required this.state});

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final _contentController = TextEditingController();
  final _reproductionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Rebuild on body edits so the counter and the submit button's enabled
    // state stay in sync.
    _contentController.addListener(_onContentChanged);
  }

  void _onContentChanged() => setState(() {});

  @override
  void dispose() {
    _contentController.removeListener(_onContentChanged);
    _contentController.dispose();
    _reproductionController.dispose();
    super.dispose();
  }

  void _submit() {
    final state = widget.state;
    context.read<FeedbackBloc>().add(SubmitFeedbackPressed(
          content: _contentController.text,
          reproductionSteps:
              state.isBug ? _reproductionController.text : null,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = widget.state;
    final bloc = context.read<FeedbackBloc>();
    final selectedType = state.selectedType;
    final selectedFeature = state.selectedFeature;
    final typeVisual = selectedType == null
        ? null
        : feedbackTypeVisual(l10n, selectedType.id);

    final canSubmit = !state.isSubmitting &&
        selectedType != null &&
        _contentController.text.trim().isNotEmpty;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '— ${l10n.feedbackEyebrow}',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.feedbackHeadline,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.feedbackSubtitle,
                  style: const TextStyle(
                    color: AppColors.mute,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Feedback type (required) ──────────────────────────────
                FeedbackSectionLabel(label: l10n.feedbackTypeLabel),
                const SizedBox(height: 10),
                FeedbackDropdownField(
                  leadingIcon: typeVisual?.icon,
                  title: selectedType?.label ?? l10n.feedbackTypeHint,
                  subtitle: typeVisual?.description,
                  isPlaceholder: selectedType == null,
                  enabled: !state.isSubmitting,
                  onTap: () => showFeedbackTypePicker(context, bloc),
                ),
                const SizedBox(height: 20),

                // ── Related feature (optional) ────────────────────────────
                FeedbackSectionLabel(
                  label: l10n.feedbackFeatureLabel,
                  optional: true,
                ),
                const SizedBox(height: 10),
                FeedbackDropdownField(
                  title: selectedFeature?.name ?? l10n.feedbackFeatureHint,
                  isPlaceholder: selectedFeature == null,
                  enabled: !state.isSubmitting,
                  onTap: () => showFeedbackFeaturePicker(context, bloc),
                ),
                const SizedBox(height: 20),

                // ── Body (required); label changes for bug reports ────────
                FeedbackSectionLabel(
                  label: state.isBug
                      ? l10n.feedbackContentLabelBug
                      : l10n.feedbackContentLabel,
                ),
                const SizedBox(height: 10),
                _FeedbackTextArea(
                  controller: _contentController,
                  hint: l10n.feedbackContentHint,
                  minLines: 4,
                  maxLength: kFeedbackContentMaxLength,
                  enabled: !state.isSubmitting,
                ),

                // ── Reproduction steps (bug reports only) ─────────────────
                if (state.isBug) ...[
                  const SizedBox(height: 20),
                  FeedbackSectionLabel(label: l10n.feedbackReproductionLabel),
                  const SizedBox(height: 10),
                  _FeedbackTextArea(
                    controller: _reproductionController,
                    hint: l10n.feedbackReproductionHint,
                    minLines: 3,
                    enabled: !state.isSubmitting,
                  ),
                ],
              ],
            ),
          ),
        ),

        // ── Error + pinned submit button ────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.errorCode != null) ...[
                Text(
                  feedbackErrorMessage(l10n, state.errorCode!),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.accentHot,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              _SubmitButton(
                label: l10n.feedbackSubmit,
                enabled: canSubmit,
                submitting: state.isSubmitting,
                onTap: _submit,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A bordered multi-line text area. When [maxLength] is set, a "n / max" counter
/// is shown bottom-right (the default Material counter is suppressed).
class _FeedbackTextArea extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int minLines;
  final int? maxLength;
  final bool enabled;

  const _FeedbackTextArea({
    required this.controller,
    required this.hint,
    required this.minLines,
    this.maxLength,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: controller,
            enabled: enabled,
            minLines: minLines,
            maxLines: null,
            maxLength: maxLength,
            cursorColor: AppColors.accent,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.muteSoft,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
              // Suppress the built-in counter; a custom one is rendered below.
              counterText: '',
            ),
          ),
          if (maxLength != null) ...[
            const SizedBox(height: 6),
            Text(
              '${controller.text.length} / $maxLength',
              style: const TextStyle(
                color: AppColors.muteSoft,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool submitting;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.label,
    required this.enabled,
    required this.submitting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          disabledBackgroundColor: AppColors.line,
          foregroundColor: Colors.white,
          disabledForegroundColor: AppColors.muteSoft,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: submitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
      ),
    );
  }
}
