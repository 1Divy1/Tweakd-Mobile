import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/feedback/bloc.dart';
import '../bloc/feedback/event.dart';
import 'feedback_picker_sheet.dart';

/// Opens the related-feature picker. Includes a "None" row to clear the
/// (optional) selection. Tapping a row updates [bloc] and closes the sheet.
Future<void> showFeedbackFeaturePicker(
  BuildContext context,
  FeedbackBloc bloc,
) {
  final l10n = AppLocalizations.of(context)!;
  final state = bloc.state;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BlocProvider<FeedbackBloc>.value(
      value: bloc,
      child: FeedbackPickerSheet(
        title: l10n.feedbackFeaturePickerTitle,
        children: [
          _FeatureRow(
            label: l10n.feedbackFeatureNone,
            selected: state.selectedFeature == null,
            muted: true,
            onTap: (context) =>
                context.read<FeedbackBloc>().add(const SelectFeedbackFeature(null)),
          ),
          for (final feature in state.features)
            _FeatureRow(
              label: feature.name,
              selected: feature.id == state.selectedFeature?.id,
              onTap: (context) => context
                  .read<FeedbackBloc>()
                  .add(SelectFeedbackFeature(feature.id)),
            ),
        ],
      ),
    ),
  );
}

class _FeatureRow extends StatelessWidget {
  final String label;
  final bool selected;
  final bool muted;
  final void Function(BuildContext) onTap;

  const _FeatureRow({
    required this.label,
    required this.selected,
    required this.onTap,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap(context);
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: muted ? AppColors.mute : AppColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_rounded, color: AppColors.accent, size: 22),
          ],
        ),
      ),
    );
  }
}
