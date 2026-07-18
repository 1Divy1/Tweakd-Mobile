import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Full-width accent CTA for saving profile edits. Disabled (muted) when there
/// is nothing to save, and shows a spinner while the save is in flight.
class EditProfileSaveButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;

  const EditProfileSaveButton({
    super.key,
    required this.label,
    required this.enabled,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = enabled && !isLoading;
    return GestureDetector(
      onTap: active ? onTap : null,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: active ? AppColors.accent : AppColors.line,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : AppColors.muteSoft,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
      ),
    );
  }
}
