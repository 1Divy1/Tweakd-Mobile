import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Opens a bottom sheet listing [options] with a search box at the top, and
/// resolves to the picked option (or null when dismissed).
///
/// The whole catalog is already in memory, so filtering happens here rather
/// than through the composer bloc — the list only exists while the sheet is up.
Future<T?> showForumReferencePickerSheet<T>(
  BuildContext context, {
  required String title,
  required String searchHint,
  required String noMatchesLabel,
  required List<T> options,
  required String Function(T option) labelOf,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ReferencePickerSheet<T>(
      title: title,
      searchHint: searchHint,
      noMatchesLabel: noMatchesLabel,
      options: options,
      labelOf: labelOf,
    ),
  );
}

class _ReferencePickerSheet<T> extends StatefulWidget {
  final String title;
  final String searchHint;
  final String noMatchesLabel;
  final List<T> options;
  final String Function(T option) labelOf;

  const _ReferencePickerSheet({
    required this.title,
    required this.searchHint,
    required this.noMatchesLabel,
    required this.options,
    required this.labelOf,
  });

  @override
  State<_ReferencePickerSheet<T>> createState() =>
      _ReferencePickerSheetState<T>();
}

class _ReferencePickerSheetState<T> extends State<_ReferencePickerSheet<T>> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<T> get _filtered {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.options;
    return widget.options
        .where((o) => widget.labelOf(o).toLowerCase().contains(query))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Leave the sheet short of full height, and give way to the keyboard so the
    // search box stays visible while typing.
    final available =
        media.size.height - media.viewInsets.bottom - media.padding.top - 16;
    final maxHeight = math.max(
      220.0,
      math.min(media.size.height * 0.78, available),
    );
    final results = _filtered;

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SheetSearchField(
                controller: _searchController,
                hint: widget.searchHint,
                onChanged: (q) => setState(() => _query = q),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.line),
            Flexible(
              child: results.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        widget.noMatchesLabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.mute,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 12),
                      itemCount: results.length,
                      separatorBuilder: (_, _) => const Divider(
                        height: 1,
                        color: AppColors.line2,
                        indent: 20,
                        endIndent: 20,
                      ),
                      itemBuilder: (_, i) => ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        title: Text(
                          widget.labelOf(results[i]),
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onTap: () => Navigator.of(context).pop(results[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const _SheetSearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: AppColors.mute),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              cursorColor: AppColors.accent,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                filled: false,
                hintText: hint,
                hintStyle: const TextStyle(
                  color: AppColors.muteSoft,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
