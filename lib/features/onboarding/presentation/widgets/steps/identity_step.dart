import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../bloc/username_availability/bloc.dart';
import '../../bloc/username_availability/event.dart';
import '../../bloc/username_availability/state.dart';
import '../onboarding_fields.dart';

/// Max bio length surfaced in the UI counter. Stays well within the backend's
/// 500-char ceiling.
const int kOnboardingBioMaxLength = 150;

/// Step 1 — claim a public handle and add an optional bio. The controllers are
/// owned by the wizard so the entered values survive step navigation; this
/// widget only listens to them to drive the live availability hint and the
/// bio character counter.
class IdentityStep extends StatelessWidget {
  final TextEditingController usernameCtrl;
  final TextEditingController bioCtrl;

  const IdentityStep({
    super.key,
    required this.usernameCtrl,
    required this.bioCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingSectionHeader(
          label: '01 — IDENTITY',
          title: 'Claim your handle',
          subtitle: 'This is how the community finds and @-mentions you. '
              'Add a short bio so people get your vibe at a glance.',
        ),
        const SizedBox(height: 24),
        const OnboardingFieldLabel('USERNAME'),
        const SizedBox(height: 8),
        BlocBuilder<UsernameAvailabilityBloc, UsernameAvailabilityState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _UsernameField(
                  controller: usernameCtrl,
                  borderColor: _borderColorFor(state),
                  onChanged: (value) => context
                      .read<UsernameAvailabilityBloc>()
                      .add(UsernameChanged(value)),
                ),
                const SizedBox(height: 10),
                _AvailabilityHint(state: state),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        const OnboardingFieldLabel('BIO', optional: true),
        const SizedBox(height: 8),
        _BioField(controller: bioCtrl),
        const SizedBox(height: 8),
        ListenableBuilder(
          listenable: bioCtrl,
          builder: (context, _) => Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${bioCtrl.text.characters.length} / $kOnboardingBioMaxLength',
              style: const TextStyle(
                color: AppColors.muteSoft,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Border tint reflects the live availability state: neutral while idle or
/// checking, accent when the handle is free, hot when it's malformed or taken.
Color _borderColorFor(UsernameAvailabilityState state) {
  if (state is UsernameAvailable) return AppColors.accent;
  if (state is UsernameAvailabilityInvalid || state is UsernameTaken) {
    return AppColors.accentHot;
  }
  return AppColors.line;
}

class _UsernameField extends StatelessWidget {
  final TextEditingController controller;
  final Color borderColor;
  final ValueChanged<String> onChanged;

  const _UsernameField({
    required this.controller,
    required this.borderColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.line),
            ),
            child: const Center(
              child: Text(
                '@',
                style: TextStyle(
                  color: AppColors.mute,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.next,
              cursorColor: AppColors.accent,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'your_handle',
                hintStyle: TextStyle(
                  color: AppColors.muteSoft,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                contentPadding: EdgeInsets.fromLTRB(10, 16, 16, 16),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Live hint under the handle field. Reflects the real-time availability
/// state: a neutral helper line while idle, the format error while malformed,
/// a spinner while the backend check is debouncing/in flight, and a final
/// available/taken verdict once the check resolves.
class _AvailabilityHint extends StatelessWidget {
  final UsernameAvailabilityState state;

  const _AvailabilityHint({required this.state});

  @override
  Widget build(BuildContext context) {
    final state = this.state;

    if (state is UsernameAvailabilityInvalid) {
      return _hintText(state.message, AppColors.accentHot);
    }

    if (state is UsernameAvailabilityChecking) {
      return Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.mute,
            ),
          ),
          const SizedBox(width: 10),
          _hintText('Checking availability…', AppColors.mute),
        ],
      );
    }

    if (state is UsernameTaken) {
      return _verdict(
        username: state.username,
        trailing: ' is already taken',
        color: AppColors.accentHot,
        icon: Icons.close_rounded,
        iconBg: AppColors.accentHot,
      );
    }

    if (state is UsernameAvailable) {
      return _verdict(
        username: state.username,
        trailing: ' is available',
        color: AppColors.mute,
        icon: Icons.check_rounded,
        iconBg: AppColors.accent,
      );
    }

    if (state is UsernameAvailabilityFailed) {
      return _hintText(state.message, AppColors.mute);
    }

    // UsernameAvailabilityInitial — field is empty.
    return _hintText('This will be your public handle.', AppColors.mute);
  }

  Widget _hintText(String text, Color color) => Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      );

  Widget _verdict({
    required String username,
    required String trailing,
    required Color color,
    required IconData icon,
    required Color iconBg,
  }) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 12, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              children: [
                TextSpan(
                  text: '@$username',
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: trailing,
                  style: TextStyle(color: color),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BioField extends StatelessWidget {
  final TextEditingController controller;

  const _BioField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        maxLines: 4,
        minLines: 4,
        maxLength: kOnboardingBioMaxLength,
        textInputAction: TextInputAction.newline,
        cursorColor: AppColors.accent,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 15,
          height: 1.35,
          fontWeight: FontWeight.w600,
        ),
        // Hide the built-in counter; the step renders its own.
        buildCounter: (_,
                {required int currentLength,
                int? maxLength,
                required bool isFocused}) =>
            null,
        decoration: const InputDecoration(
          isDense: true,
          hintText: 'Tell the grid about your current ride, your dream '
              'garage, or what you’re here for…',
          hintStyle: TextStyle(
            color: AppColors.muteSoft,
            fontSize: 15,
            height: 1.35,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
