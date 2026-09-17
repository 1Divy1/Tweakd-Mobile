import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/shared/layout/app_layout.dart';
import '../../../../../core/services/share_launcher_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../bloc/car_share/bloc.dart';
import '../../bloc/car_share/event.dart';
import '../../bloc/car_share/state.dart';

/// The printable QR, on its own over a dimmed page. Tapping anywhere off the
/// card closes it — the card carries no chrome of its own.
///
/// [bloc] is passed in rather than created: it already holds the link (and the
/// in-flight `qr.svg` request) from the share sheet that opened this. Its owner
/// is `showShareBuildSheet`, which closes it once both are done.
Future<void> showShareQrDialog(
  BuildContext context, {
  required CarShareBloc bloc,
  required String carId,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => BlocProvider<CarShareBloc>.value(
      value: bloc,
      child: _ShareQrDialog(carId: carId),
    ),
  );
}

class _ShareQrDialog extends StatelessWidget {
  final String carId;

  const _ShareQrDialog({required this.carId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        // Scannable well before this; wider only makes the card overwhelm a
        // tablet screen.
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppLayout.narrowWidth),
          child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BlocBuilder<CarShareBloc, CarShareState>(
              builder: (context, state) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _QrPanel(state: state, carId: carId),
                  const SizedBox(height: 16),
                  _DownloadButton(state: state),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}

/// The white card holding the code itself, kept square so the QR never
/// stretches.
class _QrPanel extends StatelessWidget {
  final CarShareState state;
  final String carId;

  const _QrPanel({required this.state, required this.carId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final current = state;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      padding: const EdgeInsets.all(18),
      child: AspectRatio(
        aspectRatio: 1,
        child: switch (current) {
          CarShareLoaded(:final qrSvg?) => SvgPicture.string(
            qrSvg,
            fit: BoxFit.contain,
          ),
          CarShareLoaded(qrError: != null) => _QrRetry(
            message: l10n.garageShareQrLoadFailed,
            label: l10n.garageShareRetry,
            // The link is already on the state; only the SVG fetch failed,
            // so a retry is the same event again.
            onRetry: () => context.read<CarShareBloc>().add(LoadShareQr(carId)),
          ),
          _ => Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        },
      ),
    );
  }
}

class _QrRetry extends StatelessWidget {
  final String message;
  final String label;
  final VoidCallback onRetry;

  const _QrRetry({
    required this.message,
    required this.label,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.mute,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  final CarShareState state;

  const _DownloadButton({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final current = state;
    final loaded = current is CarShareLoaded ? current : null;
    final svg = loaded?.qrSvg;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: svg == null
            ? null
            : () => _download(context, svg, loaded!.link.code),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          disabledBackgroundColor: AppColors.line,
          foregroundColor: Colors.white,
          disabledForegroundColor: AppColors.muteSoft,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.file_download_outlined, size: 20),
        label: Text(
          l10n.garageShareQrDownload,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  /// Saves the QR as a PNG to wherever on the phone the user picks — Files on
  /// iOS, the document picker (Downloads and friends) on Android.
  ///
  /// Not the share sheet: what the button promises is a copy on the phone, and
  /// the chat apps people reach for first drop an image attachment into a
  /// conversation rather than into storage.
  Future<void> _download(
    BuildContext context,
    String svg,
    String code,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    final result = await getIt<ShareLauncherService>().saveQrImage(
      svg: svg,
      fileName: 'tweakd-$code.png',
    );

    // Backing out of the picker is a decision, not an error: say nothing.
    final message = switch (result) {
      QrSaveResult.saved => l10n.garageShareQrDownloadSaved,
      QrSaveResult.failed => l10n.garageShareQrDownloadFailed,
      QrSaveResult.cancelled => null,
    };
    if (message == null) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
