import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/features/garage/domain/entities/car_modification.dart';
import 'package:tweakd/features/garage/domain/entities/mod_share_card.dart';
import 'package:tweakd/l10n/app_localizations.dart';

import '../../../domain/entities/post_image.dart';
import 'post_media_carousel.dart';

/// A post's shared build-log modification, drawn where an ordinary post draws
/// its images.
///
/// Rendered natively rather than as a flattened picture, so the car line routes
/// for real and the photos keep the carousel's swipe and pinch-zoom. When the
/// mod has both phases the viewer can switch between them; with only one, the
/// switcher stays off rather than offering an empty side.
///
/// [interactive] false renders it display-only, for surfaces where the whole
/// post is a single tap target.
class PostModShareCardView extends StatefulWidget {
  final ModShareCardEntity card;
  final bool interactive;

  const PostModShareCardView({
    super.key,
    required this.card,
    this.interactive = true,
  });

  @override
  State<PostModShareCardView> createState() => _PostModShareCardViewState();
}

class _PostModShareCardViewState extends State<PostModShareCardView> {
  /// Which phase is on screen. Starts on the result — that is what was shared.
  bool _showingBefore = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final card = widget.card;
    final media = _showingBefore ? card.beforeMedia : card.displayMedia;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (media.isNotEmpty)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: PostMediaCarousel(
                  // Keyed by phase so switching rebuilds the carousel from its
                  // first page instead of holding the other phase's index.
                  key: ValueKey(_showingBefore),
                  images: _asImages(media),
                  aspectRatio: 16 / 9,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(16),
                  enableZoom: widget.interactive,
                  peek: true,
                ),
              ),
              if (card.hasBeforeAndAfter && widget.interactive)
                Positioned(
                  top: 12,
                  left: 12,
                  child: _PhaseSwitcher(
                    showingBefore: _showingBefore,
                    beforeLabel: l10n.garageModBefore,
                    afterLabel: l10n.garageModAfter,
                    onChanged: (before) =>
                        setState(() => _showingBefore = before),
                  ),
                ),
            ],
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(4, media.isNotEmpty ? 12 : 0, 4, 0),
          child: _Details(card: card, interactive: widget.interactive),
        ),
      ],
    );
  }

  /// The carousel speaks post images; a mod's media is the same thing under a
  /// different name, so it is adapted rather than duplicated.
  static List<PostImageEntity> _asImages(List<ModificationMediaEntity> media) {
    return [
      for (var i = 0; i < media.length; i++)
        PostImageEntity(
          id: media[i].key,
          imageUrl: media[i].url,
          displayOrder: i,
        ),
    ];
  }
}

/// The card's text: what was fitted, and onto which car.
class _Details extends StatelessWidget {
  final ModShareCardEntity card;
  final bool interactive;

  const _Details({required this.card, required this.interactive});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final car = card.car;
    final carName = [
      if (car.year != null) '${car.year}',
      car.brand,
      car.model,
    ].join(' ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            _Pill(text: l10n.modShareNewMod),
            if (card.categoryName.isNotEmpty)
              Text(
                card.categoryName,
                style: TextStyle(
                  color: AppColors.mute,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          card.title,
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 17,
            height: 1.25,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        // The car is the card's one tap target: it is what the mod went on.
        InkWell(
          onTap: interactive
              // `extra: false` matches the post's car tags: the feed doesn't
              // know whether the viewer owns the car, so it opens the
              // read-only page.
              ? () => context.push('/garage/cars/${car.id}', extra: false)
              : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.directions_car_filled_outlined,
                  size: 15,
                  color: AppColors.mute,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    l10n.modShareOnCar(carName),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.ink2,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (interactive)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 17,
                    color: AppColors.muteSoft,
                  ),
              ],
            ),
          ),
        ),
        if (card.price != null) ...[
          const SizedBox(height: 4),
          Text(
            _formatPrice(card.price!, card.priceCurrency),
            style: TextStyle(
              color: AppColors.mute,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }

  /// Whole euros unless the owner recorded cents. The currency is whatever the
  /// build log stored; there is no conversion to guess at.
  static String _formatPrice(double price, String? currency) {
    final amount = price % 1 == 0
        ? price.toStringAsFixed(0)
        : price.toStringAsFixed(2);
    return currency == null || currency.isEmpty
        ? '€$amount'
        : '$amount $currency';
  }
}

/// The before/after toggle over the photo. Two taps, no menu.
class _PhaseSwitcher extends StatelessWidget {
  final bool showingBefore;
  final String beforeLabel;
  final String afterLabel;
  final ValueChanged<bool> onChanged;

  const _PhaseSwitcher({
    required this.showingBefore,
    required this.beforeLabel,
    required this.afterLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        // Near-opaque rather than blurred: cheaper, and indistinguishable at
        // this size over a photo.
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segment(beforeLabel, selected: showingBefore, value: true),
          _segment(afterLabel, selected: !showingBefore, value: false),
        ],
      ),
    );
  }

  Widget _segment(String label, {required bool selected, required bool value}) {
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.onLight : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;

  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accentWash,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.accent,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
