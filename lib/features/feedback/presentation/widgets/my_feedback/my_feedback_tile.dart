import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/my_feedback.dart';
import '../../utils/feedback_type_visuals.dart';

/// One row on the "My feedback" screen: the type it was filed under, the body,
/// an optional related feature, the server-assigned status, the moderator's
/// response (when there is one), and when it was sent.
class MyFeedbackTile extends StatelessWidget {
  final MyFeedbackEntity feedback;

  const MyFeedbackTile({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // The backend sends the resolved type label, but its lowercased form still
    // maps to the same icon family as the picker.
    final visual = feedbackTypeVisual(l10n, feedback.type.toLowerCase());
    final date = MaterialLocalizations.of(context).formatMediumDate(
      feedback.createdAt,
    );
    final response = feedback.response;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(visual.icon, color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            feedback.type,
                            style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(status: feedback.status),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      feedback.content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.ink2,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    if (feedback.feature != null &&
                        feedback.feature!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _FeaturePill(label: feedback.feature!),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      date,
                      style: TextStyle(
                        color: AppColors.muteSoft,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (response != null && response.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ResponseBox(label: l10n.myFeedbackResponseLabel, response: response),
          ],
        ],
      ),
    );
  }
}

/// Colored pill for the server-managed status. Uses the backend-supplied color
/// when present (a hex string), otherwise falls back to a neutral tone.
class _StatusBadge extends StatelessWidget {
  final MyFeedbackStatusEntity status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _parseHexColor(status.color) ?? AppColors.mute;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// The moderator's reply, shown in a distinct panel below the feedback body.
class _ResponseBox extends StatelessWidget {
  final String label;
  final String response;

  const _ResponseBox({required this.label, required this.response});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.mute,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            response,
            style: TextStyle(
              color: AppColors.ink2,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final String label;

  const _FeaturePill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.ink2,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Parses a "#RRGGBB", "RRGGBB", "#AARRGGBB" (or 8-digit) hex string into a
/// [Color]. Returns null for null/blank/malformed input so callers can fall
/// back to a default.
Color? _parseHexColor(String? hex) {
  if (hex == null) return null;
  var value = hex.trim().replaceFirst('#', '');
  if (value.length == 6) value = 'FF$value';
  if (value.length != 8) return null;
  final parsed = int.tryParse(value, radix: 16);
  if (parsed == null) return null;
  return Color(parsed);
}
