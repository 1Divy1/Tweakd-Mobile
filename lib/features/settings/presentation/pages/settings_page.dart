import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../authentication/presentation/bloc/bloc.dart';
import '../../../authentication/presentation/bloc/event.dart';
import '../../../authentication/presentation/bloc/state.dart';
import '../../../authentication/presentation/utils/auth_error_mapper.dart';
import '../../../profile/presentation/widgets/shared/profile_top_bar.dart';
import '../widgets/logout_button.dart';
import '../widgets/settings_tile.dart';

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
              style: const TextStyle(color: AppColors.ink2),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.settingsLogout,
              style: const TextStyle(color: AppColors.accent),
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
                ..showSnackBar(SnackBar(
                    content: Text(authErrorMessage(l10n, state.code))));
            }
          },
          builder: (context, state) {
            final isLoggingOut = state is AuthLoading;
            return Column(
              children: [
                ProfileTopBar(title: l10n.settingsTitle),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SettingsTile(
                          icon: Icons.flag_outlined,
                          label: l10n.settingsMyReports,
                          onTap: () => context.push('/reports'),
                        ),
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
