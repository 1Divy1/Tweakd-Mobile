import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// A switch row in the register / build-log wizard's visual language: an icon
/// badge, a title with an optional pill beside it, a line of explanation, and
/// the switch itself.
///
/// Used for the two decisions the build-log flow asks the user to make about
/// something they have already typed — whether the price is public, and whether
/// the entry goes to the feed. Both read better as a sentence with a switch
/// than as another field.
class RegisterToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  /// Optional pill after the title, e.g. "Recommended".
  final String? badge;

  final bool value;
  final ValueChanged<bool> onChanged;

  const RegisterToggleTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.badge,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // The whole row is the tap target, so the switch is not a small thumb to
    // hunt for at any text scale.
    return Semantics(
      toggled: value,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: value ? AppColors.accentSoft : AppColors.line,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: value ? AppColors.accentSoft : AppColors.bg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: value ? AppColors.accent : AppColors.muteSoft,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wraps rather than truncating: at a large text scale the
                    // pill drops under the title instead of pushing it out.
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: AppColors.ink,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (badge != null) _Badge(text: badge!),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: TextStyle(
                        color: AppColors.mute,
                        fontSize: 12.5,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.accent,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: AppColors.muteSoft,
                trackOutlineColor:
                    const WidgetStatePropertyAll(Colors.transparent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;

  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accentWash,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.accent,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
