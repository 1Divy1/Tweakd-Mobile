import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/services/share_launcher_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../bloc/car_share/bloc.dart';
import '../../bloc/car_share/event.dart';
import '../../bloc/car_share/state.dart';
import 'share_origin.dart';

/// The printable QR, on its own over a dimmed page.
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
    return Stack(
      children: [
        Positioned(
          top: MediaQuery.paddingOf(context).top + 8,
          right: 12,
          child: _DismissButton(onTap: () => Navigator.of(context).pop()),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
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
      ],
    );
  }
}

class _DismissButton extends StatelessWidget {
  final VoidCallback onTap;
  const _DismissButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close, size: 20, color: AppColors.ink),
      ),
    );
  }
}

/// The white card holding the code itself, kept square so the QR never
/// stretches, with the code spelled out underneath: a sticker too scuffed to
/// scan can still be typed into the website by hand.
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
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
                onRetry: () =>
                    context.read<CarShareBloc>().add(LoadShareQr(carId)),
              ),
              _ => const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            },
          ),
          if (current is CarShareLoaded) ...[
            const SizedBox(height: 12),
            Text(
              current.link.groupedCode,
              style: const TextStyle(
                color: AppColors.mute,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
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
            style: const TextStyle(
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
              style: const TextStyle(
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
      child: Builder(
        builder: (buttonContext) => ElevatedButton.icon(
          onPressed: svg == null
              ? null
              : () => _download(buttonContext, svg, loaded!.link.code),
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
      ),
    );
  }

  /// Hands the SVG to the system share sheet as a file. On iOS that is what
  /// puts "Save to Files" in front of the user; there is no "save to gallery"
  /// because the photo library cannot hold a vector.
  Future<void> _download(
    BuildContext context,
    String svg,
    String code,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final origin = shareOriginOf(context);

    final saved = await getIt<ShareLauncherService>().shareSvgFile(
      svg: svg,
      fileName: 'tweakd-$code.svg',
      origin: origin,
    );

    if (!saved) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.garageShareQrDownloadFailed),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
