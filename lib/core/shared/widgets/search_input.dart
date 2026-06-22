import 'package:flutter/material.dart';

import 'package:car_social_media_app/l10n/app_localizations.dart';

import '../../theme/app_colors.dart';

class SearchInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool autofocus;

  /// Falls back to the localized "Search by username" hint when null.
  final String? hintText;

  const SearchInput({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.autofocus = true,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedHint =
        hintText ?? AppLocalizations.of(context)!.searchInputHint;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: autofocus,
        textInputAction: TextInputAction.search,
        style: const TextStyle(color: AppColors.ink, fontSize: 15),
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.ink,
            size: 20,
          ),
          hintText: resolvedHint,
          hintStyle: const TextStyle(
            color: AppColors.muteSoft,
            fontSize: 15,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: onClear,
                icon: const Icon(
                  Icons.cancel,
                  color: AppColors.muteSoft,
                  size: 18,
                ),
                splashRadius: 18,
              );
            },
          ),
        ),
      ),
    );
  }
}
