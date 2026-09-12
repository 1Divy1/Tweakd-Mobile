import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// A labelled text field with a live character counter, styled to match the
/// onboarding identity fields. Used for both the name and (multiline) bio.
class EditProfileField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLength;
  final int minLines;
  final int maxLines;
  final TextInputAction textInputAction;

  const EditProfileField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.maxLength,
    this.minLines = 1,
    this.maxLines = 1,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.ink2,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowAlpha(6),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: controller,
            minLines: minLines,
            maxLines: maxLines,
            maxLength: maxLength,
            textInputAction: textInputAction,
            textCapitalization: TextCapitalization.sentences,
            cursorColor: AppColors.accent,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
            // Hide the built-in counter; this widget renders its own below.
            buildCounter: (_,
                    {required int currentLength,
                    int? maxLength,
                    required bool isFocused}) =>
                null,
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.muteSoft,
                fontSize: 15,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${controller.text.characters.length} / $maxLength',
              style: TextStyle(
                color: AppColors.muteSoft,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
