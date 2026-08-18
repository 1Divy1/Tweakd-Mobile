import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Filters [items] to those whose label contains [query], ranked so labels
/// that *start with* the query (e.g. "315" for "3") come before labels that
/// merely contain it elsewhere (e.g. "130"). Each group keeps the incoming
/// order otherwise, so results still read alphabetically/numerically within
/// a rank.
List<T> _searchRanked<T>(
  List<T> items,
  String Function(T) labelOf,
  String query,
) {
  if (query.isEmpty) return items;
  final startsWith = <T>[];
  final contains = <T>[];
  for (final item in items) {
    final label = labelOf(item).toLowerCase();
    if (label.startsWith(query)) {
      startsWith.add(item);
    } else if (label.contains(query)) {
      contains.add(item);
    }
  }
  return [...startsWith, ...contains];
}

/// A tappable field that opens a picker. Shows a placeholder until a value is
/// chosen, an optional leading widget, and a chevron affordance.
class OnboardingSelectorTile extends StatelessWidget {
  final String placeholder;
  final String? value;
  final bool loading;
  final bool enabled;
  final Widget? leading;
  final VoidCallback? onTap;

  const OnboardingSelectorTile({
    super.key,
    required this.placeholder,
    this.value,
    this.loading = false,
    this.enabled = true,
    this.leading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = !enabled || onTap == null;
    return Opacity(
      opacity: disabled && !loading ? 0.55 : 1,
      child: GestureDetector(
        onTap: loading ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(6),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.mute,
                        ),
                      )
                    : Text(
                        value ?? placeholder,
                        style: TextStyle(
                          color:
                              value != null ? AppColors.ink : AppColors.muteSoft,
                          fontSize: 16,
                          fontWeight:
                              value != null ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
              ),
              const Icon(Icons.expand_more_rounded,
                  color: AppColors.mute, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

/// Single-select bottom-sheet picker. When [searchable] is set, a search box
/// filters rows by label — useful for long lists like brands and cities.
void showOnboardingPicker<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required String Function(T) labelOf,
  required ValueChanged<T> onSelected,
  Widget Function(T)? leadingOf,
  bool searchable = false,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _OnboardingPickerSheet<T>(
      title: title,
      items: items,
      labelOf: labelOf,
      onSelected: onSelected,
      leadingOf: leadingOf,
      searchable: searchable,
    ),
  );
}

class _OnboardingPickerSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelected;
  final Widget Function(T)? leadingOf;
  final bool searchable;

  const _OnboardingPickerSheet({
    required this.title,
    required this.items,
    required this.labelOf,
    required this.onSelected,
    required this.leadingOf,
    required this.searchable,
  });

  @override
  State<_OnboardingPickerSheet<T>> createState() =>
      _OnboardingPickerSheetState<T>();
}

class _OnboardingPickerSheetState<T> extends State<_OnboardingPickerSheet<T>> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final filtered = _searchRanked(widget.items, widget.labelOf, query);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          const _SheetGrabber(),
          _SheetTitle(widget.title),
          if (widget.searchable) ...[
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _PickerSearchField(
                controller: _searchCtrl,
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.line),
          Expanded(
            child: filtered.isEmpty
                ? const _NoMatches()
                : ListView.separated(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      color: AppColors.line2,
                      indent: 24,
                      endIndent: 24,
                    ),
                    itemBuilder: (ctx, i) => ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      leading: widget.leadingOf?.call(filtered[i]),
                      title: Text(
                        widget.labelOf(filtered[i]),
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        widget.onSelected(filtered[i]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Multi-select bottom-sheet picker. Selected rows show an accent check; the
/// caller receives the full new selection each time it changes.
void showOnboardingMultiPicker<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required String Function(T) labelOf,
  required bool Function(T) isSelected,
  required ValueChanged<T> onToggle,
  bool searchable = false,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _OnboardingMultiPickerSheet<T>(
      title: title,
      items: items,
      labelOf: labelOf,
      isSelected: isSelected,
      onToggle: onToggle,
      searchable: searchable,
    ),
  );
}

class _OnboardingMultiPickerSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) labelOf;
  final bool Function(T) isSelected;
  final ValueChanged<T> onToggle;
  final bool searchable;

  const _OnboardingMultiPickerSheet({
    required this.title,
    required this.items,
    required this.labelOf,
    required this.isSelected,
    required this.onToggle,
    required this.searchable,
  });

  @override
  State<_OnboardingMultiPickerSheet<T>> createState() =>
      _OnboardingMultiPickerSheetState<T>();
}

class _OnboardingMultiPickerSheetState<T>
    extends State<_OnboardingMultiPickerSheet<T>> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final filtered = _searchRanked(widget.items, widget.labelOf, query);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          const _SheetGrabber(),
          _SheetTitle(widget.title),
          if (widget.searchable) ...[
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _PickerSearchField(
                controller: _searchCtrl,
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.line),
          Expanded(
            child: filtered.isEmpty
                ? const _NoMatches()
                : ListView.separated(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      color: AppColors.line2,
                      indent: 24,
                      endIndent: 24,
                    ),
                    itemBuilder: (ctx, i) {
                      final item = filtered[i];
                      final selected = widget.isSelected(item);
                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 24),
                        title: Text(
                          widget.labelOf(item),
                          style: TextStyle(
                            color: AppColors.ink,
                            fontWeight:
                                selected ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        trailing: _CheckBubble(selected: selected),
                        // Toggle in place and rebuild the sheet so the check
                        // updates without closing it.
                        onTap: () {
                          widget.onToggle(item);
                          setState(() {});
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CheckBubble extends StatelessWidget {
  final bool selected;
  const _CheckBubble({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: selected ? AppColors.accent : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.accent : AppColors.muteSoft,
          width: 2,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
          : null,
    );
  }
}

class _SheetGrabber extends StatelessWidget {
  const _SheetGrabber();

  @override
  Widget build(BuildContext context) {
    return Column(
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
      ],
    );
  }
}

class _SheetTitle extends StatelessWidget {
  final String title;
  const _SheetTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}

class _NoMatches extends StatelessWidget {
  const _NoMatches();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppLocalizations.of(context)!.onboardingNoMatches,
        style: const TextStyle(
          color: AppColors.muteSoft,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PickerSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _PickerSearchField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded, color: AppColors.mute, size: 20),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: AppColors.accent,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                hintText: AppLocalizations.of(context)!.onboardingSearchHint,
                hintStyle: const TextStyle(
                  color: AppColors.muteSoft,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                contentPadding: const EdgeInsets.fromLTRB(10, 13, 14, 13),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable selectable pill used by the Role and Taste steps. Selected pills
/// invert to the ink fill with white text.
class OnboardingChoicePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const OnboardingChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(selected ? 28 : 6),
              blurRadius: selected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.ink2,
            fontWeight: FontWeight.w800,
            fontSize: 13,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}
