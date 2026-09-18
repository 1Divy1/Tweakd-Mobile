import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../authentication/presentation/bloc/bloc.dart';
import '../../../authentication/presentation/bloc/event.dart';
import '../../../authentication/presentation/bloc/state.dart';
import '../../../authentication/presentation/utils/auth_error_mapper.dart';
import '../../../profile/presentation/bloc/locale/cubit.dart';
import '../../../profile/presentation/widgets/settings/language_picker_sheet.dart';
import '../../../profile/presentation/widgets/shared/profile_top_bar.dart';
import '../bloc/theme/cubit.dart';
import '../widgets/analytics_consent_tile.dart';
import '../widgets/logout_button.dart';
import '../widgets/settings_tile.dart';
import '../widgets/theme_picker_sheet.dart';
import '../../../../core/shared/layout/app_layout.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.settingsLogoutTitle),
        content: Text(l10n.settingsLogoutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              l10n.commonCancel,
              style: TextStyle(color: AppColors.ink2),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.settingsLogout,
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      context.read<AuthBloc>().add(LogoutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            // Logout completed — the session and every cached token are gone,
            // so send the user back to the entry point of the app.
            if (state is Unauthenticated || state is AuthInitial) {
              context.go('/signup');
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text(authErrorMessage(l10n, state.code))),
                );
            }
          },
          builder: (context, state) {
            final isLoggingOut = state is AuthLoading;
            return Column(
              children: [
                ProfileTopBar(title: l10n.settingsTitle),
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.fromLTRB(16, 12, 16, 24) +
                        AppLayout.inset(context, maxWidth: AppLayout.formWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SettingsTile(
                          icon: Icons.bookmark_border_rounded,
                          label: l10n.settingsSavedPosts,
                          onTap: () => context.push('/saved-posts'),
                        ),
                        const SizedBox(height: 12),
                        SettingsTile(
                          icon: Icons.flag_outlined,
                          label: l10n.settingsMyReports,
                          onTap: () => context.push('/reports'),
                        ),
                        const SizedBox(height: 12),
                        SettingsTile(
                          icon: Icons.block_rounded,
                          label: l10n.settingsBlockedAccounts,
                          onTap: () =>
                              context.push('/settings/blocked-accounts'),
                        ),
                        const SizedBox(height: 12),
                        SettingsTile(
                          icon: Icons.forum_outlined,
                          label: l10n.settingsMyFeedback,
                          onTap: () => context.push('/feedback/mine'),
                        ),
                        const SizedBox(height: 12),
                        SettingsTile(
                          icon: Icons.campaign_outlined,
                          label: l10n.settingsSendFeedback,
                          onTap: () => context.push('/feedback'),
                        ),
                        const SizedBox(height: 12),
                        BlocBuilder<LocaleCubit, Locale?>(
                          builder: (context, locale) {
                            final code = locale?.languageCode ?? 'en';
                            final label = code == 'ro'
                                ? l10n.languageRomanian
                                : l10n.languageEnglish;
                            return SettingsTile(
                              icon: Icons.language_rounded,
                              label: l10n.settingsLanguage,
                              trailingLabel: label,
                              onTap: () => showLanguagePickerSheet(
                                context,
                                currentCode: code,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        BlocBuilder<ThemeModeCubit, ThemeMode>(
                          builder: (context, mode) {
                            final label = switch (mode) {
                              ThemeMode.light => l10n.themeLight,
                              ThemeMode.dark => l10n.themeDark,
                              ThemeMode.system => l10n.themeSystem,
                            };
                            return SettingsTile(
                              icon: Icons.dark_mode_outlined,
                              label: l10n.settingsTheme,
                              trailingLabel: label,
                              onTap: () => showThemePickerSheet(context),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        const AnalyticsConsentTile(),
                        const SizedBox(height: 12),
                        LogoutButton(
                          isLoading: isLoggingOut,
                          onTap: () => _confirmLogout(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
