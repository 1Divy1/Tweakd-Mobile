import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

/// The one corner radius the register-car wizard uses for every boxy control —
/// buttons, inputs, selector tiles, image cards and tiles. Pills (the status
/// chips) are the deliberate exception; they stay pill-shaped.
const double kRegisterRadius = 16;

/// The soft lift that replaces the borders on white surfaces, matching the
/// onboarding flow.
List<BoxShadow> get kRegisterSurfaceShadow => [
      BoxShadow(
        color: AppColors.shadowAlpha(0x06),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];

/// Large title that opens every step of the register-car wizard. The accent
/// "NN — STEP" eyebrow it used to carry is gone; the progress bar is the only
/// step indicator now.
class RegisterSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const RegisterSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 30,
            height: 1.05,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: TextStyle(
              color: AppColors.mute,
              fontSize: 15,
              height: 1.3,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

/// Small uppercase field caption. An optional muted `OPTIONAL` suffix can be
/// appended inline.
///
/// A [Wrap] rather than a [Row]: half-width fields ("CHASSIS CODE OPTIONAL")
/// run out of room on narrow screens and again at raised text scales, and the
/// suffix should drop to a second line rather than overflow.
class RegisterFieldLabel extends StatelessWidget {
  final String text;
  final bool optional;

  const RegisterFieldLabel(this.text, {super.key, this.optional = false});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(
            color: AppColors.ink2,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (optional)
          Text(
            AppLocalizations.of(context)!.garageOptional,
            style: TextStyle(
              color: AppColors.muteSoft,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
      ],
    );
  }
}

/// Shrinks [child] to fit instead of overflowing.
///
/// The wizard's buttons and tiles are fixed-height boxes holding an icon and a
/// short uppercase label. There is nowhere for that content to grow when the
/// reader raises their text scale, so it scales down to fit rather than
/// spilling out of the box.
class RegisterFitted extends StatelessWidget {
  final Widget child;

  const RegisterFitted({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FittedBox(fit: BoxFit.scaleDown, child: child);
  }
}

/// A small rounded chip used to denote a unit (HP, NM, KG, …) at the trailing
/// edge of a numeric field.
class RegisterUnitChip extends StatelessWidget {
  final String text;
  const RegisterUnitChip(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(kRegisterRadius),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: AppColors.mute,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

/// The shared text input used throughout the wizard. Supports an optional
/// leading widget (e.g. a currency glyph) and a trailing unit chip.
class RegisterFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefix;
  final String? unit;

  const RegisterFormField({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.prefix,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(kRegisterRadius),
        boxShadow: kRegisterSurfaceShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (prefix != null) ...[
            const SizedBox(width: 14),
            prefix!,
          ],
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              maxLines: maxLines,
              cursorColor: AppColors.accent,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                isDense: true,
                // The app theme sets `filled: true` with a square fill and no
                // border. Painted over this rounded container it squares the
                // corners off, so every field in the wizard opts out and lets
                // the container do the painting.
                filled: false,
                hintText: hint,
                hintStyle: TextStyle(
                  color: AppColors.muteSoft,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                contentPadding: EdgeInsets.fromLTRB(
                  prefix != null ? 10 : 16,
                  14,
                  unit != null ? 10 : 16,
                  14,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (unit != null) ...[
            RegisterUnitChip(unit!),
            const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

/// A labelled numeric/text field combo used on the data-heavy steps.
class RegisterLabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final String? unit;
  final bool isNumber;
  final bool isDecimal;

  const RegisterLabeledField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.unit,
    this.isNumber = false,
    this.isDecimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RegisterFieldLabel(label),
        const SizedBox(height: 8),
        RegisterFormField(
          controller: controller,
          hint: hint,
          unit: unit,
          keyboardType: isDecimal
              ? const TextInputType.numberWithOptions(decimal: true)
              : isNumber
                  ? TextInputType.number
                  : null,
          inputFormatters: isNumber
              ? [FilteringTextInputFormatter.digitsOnly]
              : isDecimal
                  ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
                  : null,
        ),
      ],
    );
  }
}

/// A tappable field that opens a picker. Shows a placeholder until a value is
/// chosen, an optional leading swatch, and a chevron affordance.
class RegisterSelectorTile extends StatelessWidget {
  final String placeholder;
  final String? value;
  final bool loading;
  final bool enabled;
  final Widget? leading;
  final VoidCallback? onTap;

  const RegisterSelectorTile({
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
            borderRadius: BorderRadius.circular(kRegisterRadius),
            boxShadow: kRegisterSurfaceShadow,
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: loading
                    ? SizedBox(
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
                          color: value != null
                              ? AppColors.ink
                              : AppColors.muteSoft,
                          fontSize: 16,
                          fontWeight:
                              value != null ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
              ),
              Icon(Icons.expand_more_rounded,
                  color: AppColors.mute, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-bleed error state shown when the reference data fails to load.
class RegisterRefDataError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const RegisterRefDataError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                color: AppColors.muteSoft, size: 40),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mute, fontSize: 15),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(kRegisterRadius),
                ),
                child: Text(
                  AppLocalizations.of(context)!.commonRetry,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filters [items] to those whose label contains [query], ranked so labels that
/// *start with* the query come before labels that merely contain it elsewhere.
/// Typing "m" against BMW's models therefore surfaces "M2", "M3", "M4" ahead of
/// "1er M Coupe" and "318 Gran Turismo". Each group keeps the incoming order,
/// so results still read alphabetically/numerically within a rank.
///
/// Mirrors the ranking the onboarding pickers use.
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

/// A bottom-sheet list picker used for brand / model / drivetrain / color /
/// category selection. Optionally renders a leading widget per row. When
/// [searchable] is set, a search box at the top filters the rows by label —
/// useful for long lists like car brands and models.
void showRegisterPicker<T>({
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
    builder: (_) => _RegisterPickerSheet<T>(
      title: title,
      items: items,
      labelOf: labelOf,
      onSelected: onSelected,
      leadingOf: leadingOf,
      searchable: searchable,
    ),
  );
}

class _RegisterPickerSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelected;
  final Widget Function(T)? leadingOf;
  final bool searchable;

  const _RegisterPickerSheet({
    required this.title,
    required this.items,
    required this.labelOf,
    required this.onSelected,
    required this.leadingOf,
    required this.searchable,
  });

  @override
  State<_RegisterPickerSheet<T>> createState() =>
      _RegisterPickerSheetState<T>();
}

class _RegisterPickerSheetState<T> extends State<_RegisterPickerSheet<T>> {
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
          Divider(height: 1, color: AppColors.line),
          Expanded(
            child: filtered.isEmpty
                ? const _NoMatches()
                : ListView.separated(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => Divider(
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
                        style: TextStyle(
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
          style: TextStyle(
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
        AppLocalizations.of(context)!.garageNoMatches,
        style: TextStyle(
          color: AppColors.muteSoft,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Compact search input shown atop a searchable [showRegisterPicker] sheet.
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
        borderRadius: BorderRadius.circular(kRegisterRadius),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.search_rounded, color: AppColors.mute, size: 20),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: AppColors.accent,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                hintText: AppLocalizations.of(context)!.garageSearchHint,
                hintStyle: TextStyle(
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

/// The neutral filled tile behind the wizard's "add" affordances (add photo,
/// add build item). Replaces the dashed borders the wizard used to draw.
class RegisterAddSurface extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const RegisterAddSurface({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(kRegisterRadius),
          boxShadow: kRegisterSurfaceShadow,
        ),
        child: child,
      ),
    );
  }
}

/// Parses a "#RRGGBB" / "RRGGBB" color code into a [Color], falling back to a
/// neutral swatch when the string can't be parsed.
Color parseColorCode(String code) {
  var hex = code.trim().replaceFirst('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  final value = int.tryParse(hex, radix: 16);
  return value == null ? AppColors.muteSoft : Color(value);
}
