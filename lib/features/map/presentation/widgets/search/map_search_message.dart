import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// A centred icon + line of text filling a results tab: the prompt before
/// anything is typed, "no results", or a failed first page (with [onRetry]).
///
/// Scrollable so a large text scale on a short screen scrolls instead of
/// overflowing.
class MapSearchMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? retryLabel;
  final VoidCallback? onRetry;

  const MapSearchMessage({
    super.key,
    required this.icon,
    required this.message,
    this.retryLabel,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final retry = onRetry;
    final label = retryLabel;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: AppColors.mute, size: 36),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.mute,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (retry != null && label != null) ...[
                    const SizedBox(height: 12),
                    TextButton(onPressed: retry, child: Text(label)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
