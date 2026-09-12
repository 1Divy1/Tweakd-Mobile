import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A borderless rounded shape: no visible outline, but the rounded radius is
/// still used to clip the field's filled background (set on the global input
/// theme) so it reads as a distinct rounded surface without a stroke.
final OutlineInputBorder _border = OutlineInputBorder(
  borderRadius: BorderRadius.circular(12),
  borderSide: BorderSide.none,
);

/// A labeled input used across the auth pages: an uppercase field label above a
/// rounded text field with a leading icon. When [isPassword] is true the field
/// is obscured and gets a show/hide toggle.
class AuthTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final String hint;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;

  /// Lets the platform password manager offer to fill/save the value. Pass
  /// [AutofillHints.newPassword] on signup and reset forms so keychains store
  /// the new password instead of overwriting it with the old one.
  final List<String>? autofillHints;

  /// Hard cap on input length. Used to stay inside the limits Supabase itself
  /// enforces (255 for emails, 72 for passwords) rather than being bounced by
  /// the server after a round trip. The counter is hidden.
  final int? maxLength;

  final ValueChanged<String>? onSubmitted;

  const AuthTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.maxLength,
    this.onSubmitted,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscured = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autocorrect: !widget.isPassword,
          enableSuggestions: !widget.isPassword,
          autofillHints: widget.autofillHints,
          maxLength: widget.maxLength,
          onSubmitted: widget.onSubmitted,
          style: TextStyle(color: AppColors.ink, fontSize: 15),
          decoration: InputDecoration(
            hintText: widget.hint,
            counterText: '',
            // This field isn't wrapped in a bordered Container, so it carries its
            // own rounded outline (the global input theme draws no border).
            border: _border,
            enabledBorder: _border,
            focusedBorder: _border,
            prefixIcon: Icon(widget.icon, color: AppColors.mute, size: 20),
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () => setState(() => _obscured = !_obscured),
                    icon: Icon(
                      _obscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.mute,
                      size: 20,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
