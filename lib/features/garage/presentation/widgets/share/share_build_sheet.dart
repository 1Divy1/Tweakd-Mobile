import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/services/share_launcher_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/car_share.dart';
import '../../bloc/car_share/bloc.dart';
import '../../bloc/car_share/event.dart';
import '../../bloc/car_share/state.dart';
import '../../utils/garage_error_mapper.dart';
import 'share_channel_tile.dart';
import 'share_qr_dialog.dart';

/// What the sheet was closed for, so the caller knows whether to open the QR
/// modal next.
enum _ShareSheetAction { qr }

/// Opens the owner's "Share build" sheet for [carId].
///
/// The bloc is created here rather than inside the sheet because the QR modal
/// opens *after* the sheet closes (the design shows the modal alone over the
/// page) and needs the same link. Owning it at this level lets both routes
/// share one bloc, and one `POST …/share` — the call that mints the code.
Future<void> showShareBuildSheet(
  BuildContext context, {
  required String carId,
  required String carTitle,
}) async {
  final bloc = getIt<CarShareBloc>()..add(LoadShareLink(carId));

  try {
    final action = await showModalBottomSheet<_ShareSheetAction>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider<CarShareBloc>.value(
        value: bloc,
        child: _ShareBuildSheet(carId: carId, carTitle: carTitle),
      ),
    );

    if (action == _ShareSheetAction.qr && context.mounted) {
      bloc.add(LoadShareQr(carId));
      await showShareQrDialog(context, bloc: bloc, carId: carId);
    }
  } finally {
    await bloc.close();
  }
}

class _ShareBuildSheet extends StatelessWidget {
  final String carId;
  final String carTitle;

  const _ShareBuildSheet({required this.carId, required this.carTitle});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _Header(title: carTitle, label: l10n.garageShareSheetLabel),
            const SizedBox(height: 18),
            BlocBuilder<CarShareBloc, CarShareState>(
              builder: (context, state) => switch (state) {
                CarShareLoaded(:final link) => _Body(
                  carId: carId,
                  carTitle: carTitle,
                  link: link,
                  isToggling: state.isTogglingEnabled,
                ),
                CarShareError(:final code) => _ErrorBody(code: code),
                _ => const _LoadingBody(),
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String title;
  final String label;

  const _Header({required this.title, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _CloseButton(onTap: () => Navigator.of(context).pop()),
      ],
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
        ),
        child: Icon(Icons.close, size: 18, color: AppColors.ink),
      ),
    );
  }
}

// ── Loading / error ──────────────────────────────────────────────────────────

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final GarageErrorCode code;
  const _ErrorBody({required this.code});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 220,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            garageErrorMessage(l10n, code),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.mute,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Body ─────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final String carId;
  final String carTitle;
  final CarShareEntity link;
  final bool isToggling;

  const _Body({
    required this.carId,
    required this.carTitle,
    required this.link,
    required this.isToggling,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _QrCallToAction(
          title: l10n.garageShareQrTitle,
          subtitle: l10n.garageShareQrSubtitle,
          onTap: () => Navigator.of(context).pop(_ShareSheetAction.qr),
        ),
        const SizedBox(height: 16),
        _ChannelRow(link: link, carTitle: carTitle),
        const SizedBox(height: 16),
        _CopyLinkRow(link: link),
        const SizedBox(height: 14),
        _SharingFooter(carId: carId, link: link, isToggling: isToggling),
      ],
    );
  }
}

/// The primary action: the printable QR. Loudest thing in the sheet because a
/// sticker on the car is the share that keeps working when nobody is looking.
class _QrCallToAction extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QrCallToAction({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.accent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.qr_code_2,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

/// The per-app tiles. Each one tags its own channel on the URL — that tagging
/// is the reason these exist instead of a single system-share button.
///
/// Laid out like the iOS share sheet: brand icons on one line that scrolls
/// sideways rather than squeezing, so the row survives a narrow phone and a
/// large text scale instead of clipping the labels.
class _ChannelRow extends StatelessWidget {
  final CarShareEntity link;
  final String carTitle;

  const _ChannelRow({required this.link, required this.carTitle});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final tiles = <({CarShareChannel channel, String label})>[
      (channel: CarShareChannel.messages, label: l10n.garageShareChannelMessages),
      (channel: CarShareChannel.whatsapp, label: l10n.garageShareChannelWhatsApp),
      (
        channel: CarShareChannel.instagram,
        label: l10n.garageShareChannelInstagram,
      ),
      (channel: CarShareChannel.x, label: l10n.garageShareChannelX),
      (channel: CarShareChannel.telegram, label: l10n.garageShareChannelTelegram),
    ];

    // Icon + gap + the label's own line height, so a large text scale grows
    // the row instead of clipping the names.
    final labelHeight = MediaQuery.textScalerOf(context).scale(11) * 1.4;

    return SizedBox(
      height: 60 + 7 + labelHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: tiles.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, i) => ShareChannelTile(
          channel: tiles[i].channel,
          label: tiles[i].label,
          onTap: (origin) => getIt<ShareLauncherService>().shareTo(
            tiles[i].channel,
            link: link,
            text: l10n.garageShareMessage(carTitle),
            origin: origin,
          ),
        ),
      ),
    );
  }
}

class _CopyLinkRow extends StatelessWidget {
  final CarShareEntity link;
  const _CopyLinkRow({required this.link});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: AppColors.bgSoft,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _copy(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.line),
                ),
                child: Icon(Icons.link, size: 20, color: AppColors.ink),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.garageShareCopyLink,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      link.displayUrl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.mute,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.muteSoft,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _copy(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    // Tagged like every other channel, so a link that spreads by paste is not
    // invisible in the numbers.
    await Clipboard.setData(
      ClipboardData(text: link.urlFor(CarShareChannel.copy)),
    );

    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.garageShareLinkCopied),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Pause switch and the two counters.
///
/// Not in the original design, but it is the only place the owner can turn a
/// public page off — and "scanned 12 times" is the cheapest reason there is to
/// come back and look.
class _SharingFooter extends StatelessWidget {
  final String carId;
  final CarShareEntity link;
  final bool isToggling;

  const _SharingFooter({
    required this.carId,
    required this.link,
    required this.isToggling,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.garageShareToggleLabel,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  link.enabled
                      ? l10n.garageShareStats(link.qrScanCount, link.viewCount)
                      : l10n.garageSharePausedHint,
                  style: TextStyle(
                    color: AppColors.mute,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: link.enabled,
            activeTrackColor: AppColors.accent,
            onChanged: isToggling
                ? null
                : (value) => context.read<CarShareBloc>().add(
                    SetShareEnabled(carId: carId, enabled: value),
                  ),
          ),
        ],
      ),
    );
  }
}
