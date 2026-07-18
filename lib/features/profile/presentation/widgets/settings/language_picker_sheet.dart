import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/language_option.dart';
import '../../bloc/language_picker/bloc.dart';
import '../../bloc/language_picker/event.dart';
import '../../bloc/language_picker/state.dart';
import '../../bloc/locale/cubit.dart';
import '../../utils/profile_error_mapper.dart';

/// Opens the language picker bottom sheet. Lists the options from
/// `GET /profile/language-options`, check-marking [currentCode]. Tapping an
/// option PATCHes the backend; on success the sheet flips `LocaleCubit`
/// (instant app-wide language change) and persists it; on failure it shows a
/// mapped-error snackbar and keeps the old selection.
Future<void> showLanguagePickerSheet(
  BuildContext context, {
  required String currentCode,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => BlocProvider<LanguagePickerBloc>(
      create: (_) =>
          getIt<LanguagePickerBloc>()..add(LoadLanguageOptions(currentCode)),
      child: _LanguagePickerSheet(currentCode: currentCode),
    ),
  );
}

class _LanguagePickerSheet extends StatelessWidget {
  final String currentCode;

  const _LanguagePickerSheet({required this.currentCode});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MultiBlocListener(
      listeners: [
        // A PATCH just succeeded — flip the app-wide locale.
        BlocListener<LanguagePickerBloc, LanguagePickerState>(
          listenWhen: (a, b) => a.confirmNonce != b.confirmNonce,
          listener: (context, state) {
            context.read<LocaleCubit>().setLocale(state.activeCode);
          },
        ),
        // A PATCH just failed — one-shot snackbar, selection stays put.
        BlocListener<LanguagePickerBloc, LanguagePickerState>(
          listenWhen: (a, b) => a.updateErrorNonce != b.updateErrorNonce,
          listener: (context, state) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content:
                    Text(profileErrorMessage(l10n, state.updateErrorCode!)),
              ));
          },
        ),
      ],
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.settingsLanguagePickerTitle,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<LanguagePickerBloc, LanguagePickerState>(
                builder: (context, state) {
                  return switch (state.status) {
                    LanguagePickerStatus.loading => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child:
                            CircularProgressIndicator(color: AppColors.accent),
                      ),
                    LanguagePickerStatus.error => _ErrorBody(
                        message: l10n.settingsLanguageLoadError,
                        onRetry: () => context
                            .read<LanguagePickerBloc>()
                            .add(LoadLanguageOptions(currentCode)),
                      ),
                    LanguagePickerStatus.loaded => _OptionsList(state: state),
                  };
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.mute,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            child: Text(
              l10n.commonRetry,
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionsList extends StatelessWidget {
  final LanguagePickerState state;

  const _OptionsList({required this.state});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: state.options.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, color: AppColors.line),
        itemBuilder: (context, i) {
          final option = state.options[i];
          return _OptionRow(
            option: option,
            selected: option.id == state.activeCode,
            enabled: !state.updating,
            onTap: () => context
                .read<LanguagePickerBloc>()
                .add(SelectLanguage(option.id)),
          );
        },
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final LanguageOptionEntity option;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _OptionRow({
    required this.option,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled && !selected ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option.label,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 22,
                height: 22,
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        color: AppColors.accent,
                        size: 22,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
