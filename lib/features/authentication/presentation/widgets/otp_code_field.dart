import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// The emailed-code input. One wide, centred, monospaced-feeling field rather
/// than a fixed row of boxes: it pastes cleanly from the email and behaves
/// predictably with autofill and with the one-time-code keyboard suggestion.
///
/// **No length is assumed anywhere.** Supabase's `{{ .Token }}` length is a
/// project setting that can change without a client release, so the field
/// accepts any number of digits and lets Supabase be the judge of whether the
/// code is right. That rules out the failure where the dashboard is switched to
/// longer codes and the app silently refuses to accept them.
class OtpCodeField extends StatelessWidget {
  final TextEditingController controller;

  /// Fires when the user presses "done" on the keyboard. There is no
  /// submit-on-Nth-digit here — without a known length, the only reliable
  /// signal that the code is fully typed is the user saying so.
  final ValueChanged<String>? onSubmitted;

  const OtpCodeField({
    super.key,
    required this.controller,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.oneTimeCode],
      style: TextStyle(
        color: AppColors.ink,
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: 12,
      ),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: _border,
        enabledBorder: _border,
        focusedBorder: _border,
      ),
    );
  }
}

final OutlineInputBorder _border = OutlineInputBorder(
  borderRadius: BorderRadius.circular(12),
  borderSide: BorderSide.none,
);
