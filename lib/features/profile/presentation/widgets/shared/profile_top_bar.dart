import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/shared/widgets/app_pill_button.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/shared/layout/app_layout.dart';

class ProfileTopBar extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final bool showBackButton;

  /// Replaces the back pill in the leading slot. Your own profile has nothing
  /// to go back to, so it puts the create ("+") button there instead.
  final Widget? leading;

  /// Left-aligns the title next to the leading pill instead of centring it.
  final bool alignTitleStart;

  /// Types the title as a handle (`@marcus_vlox`) rather than an uppercase
  /// section name: bigger, tighter, no letter-spacing.
  final bool isHandle;

  const ProfileTopBar({
    super.key,
    required this.title,
    this.trailing,
    this.leading,
    this.showBackButton = true,
    this.alignTitleStart = false,
    this.isHandle = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleText = Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: AppColors.ink,
        fontSize: isHandle ? 17 : 14,
        fontWeight: FontWeight.w800,
        letterSpacing: isHandle ? -0.2 : 0,
      ),
    );

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(16, 8, 16, 8) + AppLayout.inset(context),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child:
                leading ??
                (showBackButton
                    ? AppPillButton(
                        icon: Icons.chevron_left_rounded,
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          }
                        },
                      )
                    : null),
          ),
          if (alignTitleStart) const SizedBox(width: 10),
          Expanded(
            child: alignTitleStart ? titleText : Center(child: titleText),
          ),
          SizedBox(width: 44, child: trailing),
        ],
      ),
    );
  }
}
