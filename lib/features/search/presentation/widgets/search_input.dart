import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SearchInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const SearchInput({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: true,
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
          hintText: 'Search by username',
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
