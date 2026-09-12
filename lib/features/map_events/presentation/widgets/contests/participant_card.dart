import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/features/garage/presentation/widgets/car_image.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../utils/contest_formatting.dart';
import 'participant_card_contests_sheet.dart';

/// One contest a car was entered in, as the card lists it.
class ParticipantCardContest {
  final String contestId;
  final String title;

  /// The car's frozen placement, or null when it entered but placed nowhere
  /// (4th+, or a contest nobody voted in).
  final int? rank;

  const ParticipantCardContest({
    required this.contestId,
    required this.title,
    required this.rank,
  });

  /// Only a podium place is worth naming on the card.
  bool get isOnPodium => rank != null && rank! <= 3;
}

/// What the participant card is drawn from.
///
/// The unit is **(event, car)** — not (event, contest): one card per car a
/// participant brought, listing every contest that car entered. See
/// `WINNER_CARD_REDESIGN_PROGRESS.md` §0.
///
/// In Phase 1 the caller assembles this from the contest data the app already
/// holds; in Phase 2 it is hydrated from the backend's own card resource, so
/// keep the shape close to `PostParticipantCardDto`.
class ParticipantCardData {
  final String eventId;
  final String eventTitle;
  final int attendeesCount;
  final CarSummaryLike car;

  /// Every contest this car entered at the event, best placement first.
  final List<ParticipantCardContest> contests;

  const ParticipantCardData({
    required this.eventId,
    required this.eventTitle,
    required this.attendeesCount,
    required this.car,
    required this.contests,
  });

  /// The card's pill: the car's **best** placement across the event, or null
  /// when it placed nowhere — then no pill at all.
  int? get bestRank {
    int? best;
    for (final c in contests) {
      final rank = c.rank;
      if (rank == null || rank > 3) continue;
      if (best == null || rank < best) best = rank;
    }
    return best;
  }

  bool get hasContests => contests.isNotEmpty;
}

/// The slice of a car the card draws. Kept narrow so the Phase 2 feed payload
/// can satisfy it without dragging the whole garage entity into the feed.
class CarSummaryLike {
  final String id;
  final String brand;
  final String model;
  final String? coverImageUrl;

  const CarSummaryLike({
    required this.id,
    required this.brand,
    required this.model,
    required this.coverImageUrl,
  });

  String get name => '$brand $model';
}

/// The shareable participant card — Direction C of the redesign ("if Apple
/// designed it"): a white plate, the car's cover, a frosted placement pill, the
/// car's name, then hairline disclosure rows for the event and the contests, and
/// the attendee count as the closing line.
///
/// Three things are tappable — the car name, the event row and the contests row
/// — each with a trailing chevron. **The photo is deliberately inert.**
///
/// The card is a *fixed height for any contest count*: the contests row is one
/// line of comma-separated names that ends in "+N more" when they don't fit.
/// A car that entered no contest drops that row and its hairline.
///
/// Wrapped in a [RepaintBoundary] keyed by [captureKey] so [capturePng] can
/// rasterise exactly what's on screen for the feed post and the share sheet.
/// Set [interactive] false for that capture: a flat PNG cannot honour a tap, so
/// the chevrons come off rather than promising one.
class ParticipantCard extends StatelessWidget {
  final ParticipantCardData data;
  final double width;
  final GlobalKey? captureKey;
  final bool interactive;

  /// Where a tap goes. Null callbacks simply make that row inert, which is what
  /// the capture path wants.
  final VoidCallback? onOpenCar;
  final VoidCallback? onOpenEvent;
  final void Function(String contestId)? onOpenContest;

  const ParticipantCard({
    super.key,
    required this.data,
    this.width = 330,
    this.captureKey,
    this.interactive = true,
    this.onOpenCar,
    this.onOpenEvent,
    this.onOpenContest,
  });

  /// Rasterises the card at [pixelRatio]. Call after the cover image has
  /// painted (a frame after first build at least), or the photo is blank.
  static Future<Uint8List?> capturePng(GlobalKey key, {double pixelRatio = 3}) async {
    final boundary = key.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary) return null;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return RepaintBoundary(
      key: captureKey,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.ink.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.06),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.18),
              blurRadius: 40,
              spreadRadius: -12,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Cover(data: data, width: width),
            _CarName(
              data: data,
              interactive: interactive,
              onTap: onOpenCar,
            ),
            const SizedBox(height: 8),
            _CardRow(
              label: l10n.participantCardEvent,
              value: data.eventTitle,
              interactive: interactive,
              onTap: onOpenEvent,
            ),
            if (data.hasContests)
              _ContestsRow(
                data: data,
                interactive: interactive,
                onOpenContest: onOpenContest,
              ),
            _Footer(count: data.attendeesCount),
          ],
        ),
      ),
    );
  }
}

/// The cover photo and the placement pill. Inert by design — the owner's call.
class _Cover extends StatelessWidget {
  final ParticipantCardData data;
  final double width;

  const _Cover({required this.data, required this.width});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final best = data.bestRank;

    return SizedBox(
      height: width * 0.82,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CarImage(imageUrl: data.car.coverImageUrl, fit: BoxFit.cover),
          // The white sheet's rounded top riding 18pt up over the photo — the
          // one "Apple" move in the design. Drawn inside the cover so it
          // overlaps without leaving an 18pt hole at the card's foot, which is
          // what translating the sheet itself did.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 18,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
          ),
          if (best != null)
            Positioned(
              top: 14,
              left: 14,
              // A BackdropFilter does rasterise inside toImage, but it is
              // expensive and fragile at pixelRatio 3 — a near-opaque white is
              // indistinguishable at this scale.
              child: Container(
                padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        // The design's one use of the accent. Keep it that way.
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        size: 11,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.participantCardPlace(ContestFormat.rank(l10n, best)),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CarName extends StatelessWidget {
  final ParticipantCardData data;
  final bool interactive;
  final VoidCallback? onTap;

  const _CarName({
    required this.data,
    required this.interactive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tappable = interactive && onTap != null;
    final name = Padding(
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              data.car.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                height: 1.15,
                color: AppColors.ink,
              ),
            ),
          ),
          // The owner asked for the same chevron the rows carry.
          if (tappable) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.ink.withValues(alpha: 0.25),
            ),
          ],
        ],
      ),
    );
    if (!tappable) return name;
    return InkWell(onTap: onTap, child: name);
  }
}

/// One hairline disclosure row: a small uppercase label over its value, with a
/// chevron. The contests row passes its one-line list as [valueWidget].
class _CardRow extends StatelessWidget {
  final String label;
  final Widget? valueWidget;
  final String? value;
  final bool interactive;
  final VoidCallback? onTap;

  const _CardRow({
    required this.label,
    this.valueWidget,
    this.value,
    required this.interactive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tappable = interactive && onTap != null;
    final row = Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.ink.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: AppColors.ink.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 1),
                valueWidget ??
                    Text(
                      value ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink,
                      ),
                    ),
              ],
            ),
          ),
          if (tappable) ...[
            const SizedBox(width: 10),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.ink.withValues(alpha: 0.25),
            ),
          ],
        ],
      ),
    );
    if (!tappable) return row;
    return InkWell(onTap: onTap, child: row);
  }
}

/// The contests row: one line, comma-separated, ending in "+N more" when the
/// names don't fit. One line is what keeps the card a fixed height however many
/// contests the car entered.
class _ContestsRow extends StatelessWidget {
  final ParticipantCardData data;
  final bool interactive;
  final void Function(String contestId)? onOpenContest;

  const _ContestsRow({
    required this.data,
    required this.interactive,
    required this.onOpenContest,
  });

  /// A single contest reads "Best paint / wrap (1st)" on the podium, and just
  /// its title otherwise — the parenthesised rank is the FOMO payload, so a
  /// non-placing entry shouldn't carry dead weight.
  static String _label(AppLocalizations l10n, ParticipantCardContest c) {
    if (!c.isOnPodium) return c.title;
    return l10n.participantCardContestWithRank(
      c.title,
      ContestFormat.rank(l10n, c.rank!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onTap = onOpenContest;
    final single = data.contests.length == 1 ? data.contests.first : null;

    return _CardRow(
      label: l10n.participantCardContests,
      interactive: interactive,
      // One contest goes straight there; several open the sheet, which is what
      // the owner asked "+N more" to do.
      onTap: onTap == null
          ? null
          : single != null
              ? () => onTap(single.contestId)
              : () => showParticipantCardContestsSheet(
                    context,
                    contests: data.contests,
                    onOpenContest: onTap,
                  ),
      valueWidget: LayoutBuilder(
        builder: (context, constraints) {
          final style = TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.ink,
          );
          final labels = [
            for (final c in data.contests) _label(l10n, c),
          ];
          final fit = _fitOneLine(
            context: context,
            labels: labels,
            style: style,
            maxWidth: constraints.maxWidth,
            moreLabel: (n) => l10n.participantCardMore(n),
          );
          return Row(
            children: [
              Expanded(
                child: Text(
                  fit.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style,
                ),
              ),
              if (fit.hidden > 0) ...[
                const SizedBox(width: 8),
                Text(
                  l10n.participantCardMore(fit.hidden),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// How many of [labels] fit on one line, and the joined text for them.
class _OneLineFit {
  final String text;
  final int hidden;

  const _OneLineFit(this.text, this.hidden);
}

/// Greedily fits comma-separated [labels] into [maxWidth], reserving room for
/// the "+N more" suffix whenever something is left over.
///
/// Measuring beats letting the text ellipsise: ellipsis would cut a contest
/// name mid-word and give no count of what was dropped, and the owner wants the
/// remainder named and tappable.
_OneLineFit _fitOneLine({
  required BuildContext context,
  required List<String> labels,
  required TextStyle style,
  required double maxWidth,
  required String Function(int) moreLabel,
}) {
  if (labels.isEmpty) return const _OneLineFit('', 0);
  final scaler = MediaQuery.textScalerOf(context);
  final direction = Directionality.of(context);

  double widthOf(String text) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: direction,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    return painter.width;
  }

  // Always show at least the first name, however narrow the card: a row that
  // says only "+3 more" tells the reader nothing.
  var shown = 1;
  while (shown < labels.length) {
    final candidate = labels.take(shown + 1).join(', ');
    final leftOver = labels.length - (shown + 1);
    final suffix = leftOver > 0 ? widthOf(moreLabel(leftOver)) + 8 : 0.0;
    if (widthOf(candidate) + suffix > maxWidth) break;
    shown++;
  }
  return _OneLineFit(
    labels.take(shown).join(', '),
    labels.length - shown,
  );
}

/// "247 people were at the event." — the FOMO line the design closes on.
class _Footer extends StatelessWidget {
  final int count;

  const _Footer({required this.count});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.ink.withValues(alpha: 0.08)),
        ),
      ),
      child: Text(
        l10n.participantCardAttendees(count),
        style: TextStyle(
          fontSize: 12.5,
          color: AppColors.ink.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}
