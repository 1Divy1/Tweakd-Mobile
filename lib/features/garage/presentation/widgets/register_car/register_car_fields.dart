import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_colors.dart';

/// Accent eyebrow label + large title + optional supporting line that opens
/// every step of the register-car wizard.
class RegisterSectionHeader extends StatelessWidget {
  final String label;
  final String title;
  final String? subtitle;

  const RegisterSectionHeader({
    super.key,
    required this.label,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
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
            style: const TextStyle(
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
class RegisterFieldLabel extends StatelessWidget {
  final String text;
  final bool optional;

  const RegisterFieldLabel(this.text, {super.key, this.optional = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          text,
          style: const TextStyle(
            color: AppColors.ink2,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        if (optional) ...[
          const SizedBox(width: 6),
          const Text(
            'OPTIONAL',
            style: TextStyle(
              color: AppColors.muteSoft,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ],
    );
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: hint,
                hintStyle: const TextStyle(
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
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
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
                          color: value != null
                              ? AppColors.ink
                              : AppColors.muteSoft,
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
            const Icon(Icons.cloud_off_rounded,
                color: AppColors.muteSoft, size: 40),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.mute, fontSize: 15),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'RETRY',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
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
    super.key,
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
    final filtered = query.isEmpty
        ? widget.items
        : widget.items
            .where((item) => widget.labelOf(item).toLowerCase().contains(query))
            .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      expand: false,
      builder: (_, scrollCtrl) => Column(
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
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.title,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
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
                ? const Center(
                    child: Text(
                      'No matches',
                      style: TextStyle(
                        color: AppColors.muteSoft,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
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
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded, color: AppColors.mute, size: 20),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              autofocus: true,
              cursorColor: AppColors.accent,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Search…',
                hintStyle: TextStyle(
                  color: AppColors.muteSoft,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                contentPadding: EdgeInsets.fromLTRB(10, 13, 14, 13),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints a dashed rounded-rectangle border around [child]. Used for the
/// various "add" affordances in the wizard.
class DashedRoundedBorder extends StatelessWidget {
  final Widget child;
  final double radius;
  final Color color;

  const DashedRoundedBorder({
    super.key,
    required this.child,
    this.radius = 16,
    this.color = AppColors.muteSoft,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(radius: radius, color: color),
      child: child,
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  final double radius;
  final Color color;

  _DashedRRectPainter({required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    const dash = 7.0;
    const gap = 5.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dash), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.color != color;
}

/// Parses a "#RRGGBB" / "RRGGBB" color code into a [Color], falling back to a
/// neutral swatch when the string can't be parsed.
Color parseColorCode(String code) {
  var hex = code.trim().replaceFirst('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  final value = int.tryParse(hex, radix: 16);
  return value == null ? AppColors.muteSoft : Color(value);
}
