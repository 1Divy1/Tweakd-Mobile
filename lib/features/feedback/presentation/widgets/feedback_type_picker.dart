import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/feedback_type.dart';
import '../bloc/feedback/bloc.dart';
import '../bloc/feedback/event.dart';
import '../utils/feedback_type_visuals.dart';
import 'feedback_picker_sheet.dart';

/// Opens the feedback-type picker. Tapping a row selects it on [bloc] and closes
/// the sheet. [bloc] is forwarded via [BlocProvider.value] because the modal
/// route sits outside the page's widget subtree.
Future<void> showFeedbackTypePicker(
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
        title: l10n.feedbackTypePickerTitle,
        children: [
          for (final type in state.types)
            _TypeRow(
              type: type,
              selected: type.id == state.selectedType?.id,
              l10n: l10n,
            ),
        ],
      ),
    ),
  );
}

class _TypeRow extends StatelessWidget {
  final FeedbackTypeEntity type;
  final bool selected;
  final AppLocalizations l10n;

  const _TypeRow({
    required this.type,
    required this.selected,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final visual = feedbackTypeVisual(l10n, type.id);
    return InkWell(
      onTap: () {
        context.read<FeedbackBloc>().add(SelectFeedbackType(type.id));
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(visual.icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    type.label,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (visual.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      visual.description!,
                      style: TextStyle(
                        color: AppColors.mute,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
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
