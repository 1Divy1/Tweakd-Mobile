import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// The one corner radius every boxy control in the create-post wizard uses —
/// the same 16 the add-car and create-event wizards use.
const double kPostRadius = 16;

/// Widest the wizard's content ever gets, so the steps don't sprawl into
/// unreadable line lengths on a tablet.
const double kPostMaxWidth = 560;

/// The soft lift that replaces borders on white surfaces, matching the other
/// wizards.
List<BoxShadow> get kPostSurfaceShadow => [
      BoxShadow(
        color: AppColors.shadowAlpha(0x06),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];

/// Large title + supporting line that opens every step. There is no step
/// eyebrow; the progress bar is the only step indicator.
class PostStepHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const PostStepHeader({super.key, required this.title, this.subtitle});

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

/// Small uppercase field caption, optionally followed by a muted count chip
/// (e.g. the "CARS 2" / "PEOPLE 3" labels on the tags step).
class PostFieldLabel extends StatelessWidget {
  final String text;
  final int? count;

  const PostFieldLabel(this.text, {super.key, this.count});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(
            color: AppColors.ink2,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        if (count != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.line2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: AppColors.mute,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

/// The white rounded surface every field and card in the wizard sits on.
class PostSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const PostSurface({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(kPostRadius),
        boxShadow: kPostSurfaceShadow,
      ),
      child: child,
    );
  }
}

/// The filled tile behind the wizard's "add" affordances (add photo, tag a
/// car) — a plain surface, not a dashed outline.
class PostAddSurface extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const PostAddSurface({super.key, required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: PostSurface(child: child),
    );
  }
}

/// The search input used on the tags step.
class PostSearchField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const PostSearchField({
    super.key,
    required this.hint,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PostSurface(
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
                // The app theme sets `filled: true` with a square fill. Painted
                // over this rounded surface it squares the corners off, so the
                // field opts out and lets the surface do the painting.
                filled: false,
                hintText: hint,
                hintStyle: TextStyle(
                  color: AppColors.muteSoft,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                contentPadding: const EdgeInsets.fromLTRB(10, 15, 14, 15),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
