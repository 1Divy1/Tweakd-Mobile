import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';

class ProfileTopBar extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final bool showBackButton;

  const ProfileTopBar({
    super.key,
    required this.title,
    this.trailing,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: showBackButton
                ? _PillIconButton(
                    icon: Icons.chevron_left,
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      }
                    },
                  )
                : null,
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                ),
              ),
            ),
          ),
          SizedBox(width: 44, child: trailing),
        ],
      ),
    );
  }
}

class _PillIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _PillIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 44,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line),
        ),
        child: Icon(icon, color: AppColors.ink, size: 20),
      ),
    );
  }
}
