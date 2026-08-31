import 'package:tweakd/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../shared/map_event_chips.dart';

/// A labelled text input in the create form's house style: uppercase micro
/// label, white rounded field, no visible border until focus.
class EventTextField extends StatelessWidget {
  final String label;
  final String? labelSuffix;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;

  const EventTextField({
    super.key,
    required this.label,
    this.labelSuffix,
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        MapEventSectionLabel(label: label, trailing: labelSuffix),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: maxLines > 1
              ? TextCapitalization.sentences
              : TextCapitalization.words,
          style: const TextStyle(fontSize: 15, color: AppColors.ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 15, color: AppColors.muteSoft),
            counterText: '',
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.accent),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

/// A tappable field that opens a picker — used for every date and time slot.
class EventPickerField extends StatelessWidget {
  final String value;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isPlaceholder;

  const EventPickerField({
    super.key,
    required this.value,
    required this.icon,
    required this.onTap,
    this.isPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 17,
                color: isPlaceholder ? AppColors.muteSoft : AppColors.mute,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight:
                        isPlaceholder ? FontWeight.w400 : FontWeight.w600,
                    color: isPlaceholder ? AppColors.muteSoft : AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The dashed outline the design uses for "add something optional" targets:
/// the cover picker, "SET LOCATION ON MAP", "+ ADD A RULE", "+ ADD ORGANIZER".
class EventDashedButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final double height;
  final Widget? child;

  const EventDashedButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.height = 52,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: CustomPaint(
        painter: const _DashedBorderPainter(),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: child ??
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 17, color: AppColors.mute),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: AppColors.mute,
                      ),
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}

/// Flutter has no dashed border, so it's painted: a rounded rect walked in
/// fixed-length on/off segments.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter();

  static const _dash = 6.0;
  static const _gap = 4.0;
  static const _radius = 16.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0.7, 0.7, size.width - 1.4, size.height - 1.4),
          const Radius.circular(_radius),
        ),
      );

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + _dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => false;
}

/// The "Require approval to join" card: a title, an explanation, a switch, and
/// the registration-deadline slot nested underneath it.
class EventToggleCard extends StatelessWidget {
  final String title;
  final String body;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? nested;

  const EventToggleCard({
    super.key,
    required this.title,
    required this.body,
    required this.value,
    required this.onChanged,
    this.nested,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: AppColors.mute,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeTrackColor: AppColors.accent,
              ),
            ],
          ),
          if (nested != null) ...[
            const SizedBox(height: 14),
            const Divider(color: AppColors.line2, height: 1),
            const SizedBox(height: 14),
            nested!,
          ],
        ],
      ),
    );
  }
}
