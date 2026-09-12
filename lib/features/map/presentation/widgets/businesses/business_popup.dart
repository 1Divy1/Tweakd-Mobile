import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/business_pin_entity.dart';
import '../../bloc/map/state.dart';
import '../../utils/map_error_mapper.dart';
import '../navigation/navigate_button.dart';
import 'business_popup_content.dart';

/// The floating card that opens over the map when a business pin is tapped.
///
/// Deliberately *not* a modal bottom sheet: the map stays visible and usable
/// behind it, and the tapped pin keeps its highlight. It animates in from the
/// bottom and caps its height so a business with a long description can be
/// scrolled without ever covering the whole map.
class BusinessPopup extends StatelessWidget {
  final MapState state;
  final VoidCallback onClose;
  final VoidCallback onRetry;

  const BusinessPopup({
    super.key,
    required this.state,
    required this.onClose,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final pin = state.selectedPin;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.62;

    // The pin already carries coordinates, so the destination is known before
    // `GET /businesses/{id}` lands — the bar is live from the first frame.
    // It's hidden on failure only: offering directions to a business the popup
    // just said is gone would contradict itself.
    final business = state.selectedBusiness;
    final destination = business?.position ?? pin?.position;
    final detailFailed = state.detailStatus == BusinessDetailStatus.failure;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowAlpha(0x1F),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // The details scroll; the Navigate bar is pinned below them so it
          // stays reachable at the popup's bottom edge however far down a long
          // description or a full week of opening hours has been scrolled.
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                  child: switch (state.detailStatus) {
                    BusinessDetailStatus.loaded =>
                      BusinessPopupContent(business: business!),
                    BusinessDetailStatus.failure => _PopupError(
                        code: state.detailErrorCode ?? MapErrorCode.generic,
                        onRetry: onRetry,
                      ),
                    _ => _PopupLoading(pin: pin),
                  },
                ),
              ),
              if (destination != null && !detailFailed) ...[
                Divider(color: AppColors.line2, height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                  child: NavigateButton(
                    position: destination,
                    label: business?.name ?? pin?.name ?? '',
                  ),
                ),
              ],
            ],
          ),
          Positioned(
            top: 10,
            right: 10,
            child: _CloseButton(onTap: onClose),
          ),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      label: l10n.mapPopupClose,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.close_rounded, size: 20, color: AppColors.mute),
        ),
      ),
    );
  }
}

/// Shown while the full profile is in flight.
///
/// The pin already carries a name, logo and type, so those render immediately —
/// only the parts that need the detail call get a placeholder. That makes the
/// popup feel instant even on a slow connection.
class _PopupLoading extends StatelessWidget {
  final BusinessPinEntity? pin;

  const _PopupLoading({required this.pin});

  @override
  Widget build(BuildContext context) {
    final business = pin;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BusinessLogo(logoUrl: business?.logoUrl ?? '', size: 54),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (business != null) ...[
                    Text(
                      business.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      business.typeLabel,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.mute,
                      ),
                    ),
                  ] else ...[
                    const _SkeletonBar(width: 160, height: 18),
                    const SizedBox(height: 8),
                    const _SkeletonBar(width: 90, height: 12),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const _SkeletonBar(width: double.infinity, height: 12),
        const SizedBox(height: 10),
        const _SkeletonBar(width: 220, height: 12),
        const SizedBox(height: 10),
        const _SkeletonBar(width: 170, height: 12),
        const SizedBox(height: 20),
        Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.muteSoft,
            ),
          ),
        ),
      ],
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonBar({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.line2,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _PopupError extends StatelessWidget {
  final MapErrorCode code;
  final VoidCallback onRetry;

  const _PopupError({required this.code, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // A hidden business (pending, suspended, rejected) answers 404 exactly like
    // a deleted one — by design — so retrying it would only fail again.
    final canRetry = code != MapErrorCode.notFound;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 28,
            color: AppColors.muteSoft,
          ),
          const SizedBox(height: 12),
          Text(
            mapErrorMessage(l10n, code),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.ink2),
          ),
          if (canRetry) ...[
            const SizedBox(height: 14),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accent,
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(l10n.mapRetry),
            ),
          ],
        ],
      ),
    );
  }
}
