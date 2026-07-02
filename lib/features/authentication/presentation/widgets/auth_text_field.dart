import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// The rounded outline this field draws on its own (the global input theme no
/// longer supplies a default border).
final OutlineInputBorder _border = OutlineInputBorder(
  borderRadius: BorderRadius.circular(12),
  borderSide: const BorderSide(color: AppColors.line),
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

  const AuthTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
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
          style: const TextStyle(
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
          style: const TextStyle(color: AppColors.ink, fontSize: 15),
          decoration: InputDecoration(
            hintText: widget.hint,
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
