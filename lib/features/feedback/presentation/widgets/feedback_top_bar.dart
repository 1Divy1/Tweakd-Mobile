import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Top bar for the feedback modal: a close (✕) button on the left and the brand
/// wordmark centred. Mirrors the pill-button styling used elsewhere in the app.
class FeedbackTopBar extends StatelessWidget {
  final String brand;
  final VoidCallback onClose;

  const FeedbackTopBar({super.key, required this.brand, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 44,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.close, color: AppColors.ink, size: 20),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                brand.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}
