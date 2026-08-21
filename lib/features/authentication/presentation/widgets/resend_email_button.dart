import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Seconds the button stays disabled after a send. Supabase's own email rate
/// limit is stricter than one press per minute; the cooldown keeps users from
/// tripping it and getting an error instead of an email.
const int kResendCooldownSeconds = 60;

/// "Didn't get it? Resend" with a visible countdown.
///
/// The cooldown starts immediately on mount, because reaching any screen that
/// shows this button means an email was just sent.
class ResendEmailButton extends StatefulWidget {
  final VoidCallback onResend;

  /// Bump this to restart the countdown after a successful resend.
  final int resendCount;

  const ResendEmailButton({
    super.key,
    required this.onResend,
    this.resendCount = 0,
  });

  @override
  State<ResendEmailButton> createState() => _ResendEmailButtonState();
}

class _ResendEmailButtonState extends State<ResendEmailButton> {
  Timer? _timer;
  int _secondsLeft = kResendCooldownSeconds;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void didUpdateWidget(ResendEmailButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.resendCount != oldWidget.resendCount) _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = kResendCooldownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final waiting = _secondsLeft > 0;

    return TextButton(
      onPressed: waiting ? null : widget.onResend,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.ink,
        disabledForegroundColor: AppColors.mute,
      ),
      child: Text(
        waiting ? l10n.authResendIn(_secondsLeft) : l10n.authResendEmail,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
