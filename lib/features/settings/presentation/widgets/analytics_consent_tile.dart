import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tweakd/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/analytics_consent/cubit.dart';
import '../bloc/analytics_consent/state.dart';

/// Settings row for the analytics opt-in: same card as [SettingsTile], with a
/// switch instead of a chevron and a one-line explanation underneath. Grows
/// with the text scale instead of clipping at a fixed height.
class AnalyticsConsentTile extends StatelessWidget {
  const AnalyticsConsentTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<AnalyticsConsentCubit, AnalyticsConsentState>(
      listenWhen: (previous, current) => current.failed && !previous.failed,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(l10n.settingsAnalyticsUpdateError)),
          );
      },
      builder: (context, state) {
        final granted = state.granted;
        final enabled = granted != null && !state.saving;
        return Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Icon(Icons.insights_outlined, color: AppColors.ink, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsAnalytics,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.settingsAnalyticsHint,
                      style: TextStyle(
                        color: AppColors.mute,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch.adaptive(
                value: granted ?? false,
                activeTrackColor: AppColors.accent,
                onChanged: enabled
                    ? (value) =>
                          context.read<AnalyticsConsentCubit>().toggle(value)
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
