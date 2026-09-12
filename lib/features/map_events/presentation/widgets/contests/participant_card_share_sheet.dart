import 'dart:typed_data';

import 'package:tweakd/core/di/injection.dart';
import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/features/garage/presentation/widgets/share/share_origin.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/share_win/cubit.dart';
import '../../bloc/share_win/state.dart';
import '../../utils/contest_formatting.dart';
import 'participant_card.dart';

/// The share sheet: the participant card, an OS-share button and — when the card
/// is the viewer's own — POST TO FEED with an optional caption. Someone else's
/// card gets the OS button only.
///
/// The card shown here is fully interactive; the capture is not (see
/// [_ParticipantCardShareSheetState._capture]).
Future<void> showParticipantCardShareSheet(
  BuildContext context, {
  required ParticipantCardData data,
  required bool isMine,
  VoidCallback? onOpenCar,
  VoidCallback? onOpenEvent,
  void Function(String contestId)? onOpenContest,
}) async {
  final cubit = getIt<ShareWinCubit>();
  try {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider<ShareWinCubit>.value(
        value: cubit,
        child: _ParticipantCardShareSheet(
          data: data,
          isMine: isMine,
          onOpenCar: onOpenCar,
          onOpenEvent: onOpenEvent,
          onOpenContest: onOpenContest,
        ),
      ),
    );
  } finally {
    await cubit.close();
  }
}

class _ParticipantCardShareSheet extends StatefulWidget {
  final ParticipantCardData data;
  final bool isMine;
  final VoidCallback? onOpenCar;
  final VoidCallback? onOpenEvent;
  final void Function(String contestId)? onOpenContest;

  const _ParticipantCardShareSheet({
    required this.data,
    required this.isMine,
    this.onOpenCar,
    this.onOpenEvent,
    this.onOpenContest,
  });

  @override
  State<_ParticipantCardShareSheet> createState() =>
      _ParticipantCardShareSheetState();
}

class _ParticipantCardShareSheetState
    extends State<_ParticipantCardShareSheet> {
  final _cardKey = GlobalKey();
  final _caption = TextEditingController();

  /// True for the single frame the card is rasterised in. The shared image is a
  /// flat PNG, so it must not carry chevrons promising taps it cannot honour —
  /// the card is rendered non-interactive for the capture and restored after.
  bool _capturing = false;

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  /// Drops the chevrons, waits for that frame to paint, rasterises, restores.
  Future<Uint8List?> _capture() async {
    setState(() => _capturing = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return null;
      return await ParticipantCard.capturePng(_cardKey);
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  /// "Sep 13, 2026, 18:40" in the viewer's locale.
  static String _formatWhen(BuildContext context, DateTime when) {
    final loc = MaterialLocalizations.of(context);
    return '${loc.formatMediumDate(when)}, '
        '${loc.formatTimeOfDay(TimeOfDay.fromDateTime(when))}';
  }

  String _shareText(AppLocalizations l10n) {
    final data = widget.data;
    final best = data.bestRank;
    if (best == null) {
      return l10n.participantCardShareText(data.car.name, data.eventTitle);
    }
    // Name the contest the placement came from, not just the rank.
    final contest = data.contests.firstWhere(
      (c) => c.rank == best,
      orElse: () => data.contests.first,
    );
    return l10n.participantCardShareTextPlaced(
      data.car.name,
      ContestFormat.rank(l10n, best),
      contest.title,
      data.eventTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final width = (MediaQuery.sizeOf(context).width - 36).clamp(240.0, 340.0);

    return BlocConsumer<ShareWinCubit, ShareWinState>(
      listener: (context, state) {
        final next = state.nextAllowedAt;
        final message = switch (state.status) {
          ShareWinStatus.failure => l10n.contestsPostFailed,
          // Reposting is welcome, just not the same card again so soon.
          ShareWinStatus.cooldown when next != null =>
            l10n.participantCardCooldown(_formatWhen(context, next)),
          _ => null,
        };
        if (message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(18, 18, 18, 18 + bottomInset),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          state.isPosted
                              ? l10n.contestsPostedTitle
                              : l10n.participantCardShareSheetTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        color: AppColors.ink,
                        style: IconButton.styleFrom(backgroundColor: AppColors.bg),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: ParticipantCard(
                      data: widget.data,
                      width: width,
                      captureKey: _cardKey,
                      interactive: !_capturing,
                      onOpenCar: widget.onOpenCar,
                      onOpenEvent: widget.onOpenEvent,
                      onOpenContest: widget.onOpenContest,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (state.isPosted)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_rounded, size: 15, color: AppColors.accent),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            l10n.contestsPostedBody,
                            style: TextStyle(fontSize: 12.5, color: AppColors.mute),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    if (widget.isMine) ...[
                      TextField(
                        controller: _caption,
                        maxLength: 500,
                        maxLines: 2,
                        minLines: 1,
                        enabled: !state.isBusy,
                        decoration: InputDecoration(
                          hintText: l10n.contestsCaptionHint,
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.bg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(fontSize: 13.5, color: AppColors.ink),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Row(
                      children: [
                        Builder(
                          builder: (buttonContext) => SizedBox(
                            width: 52,
                            height: 48,
                            child: IconButton(
                              onPressed: state.isBusy
                                  ? null
                                  : () async {
                                      final png = await _capture();
                                      if (png == null || !context.mounted) return;
                                      await context.read<ShareWinCubit>().shareExternally(
                                            cardPng: png,
                                            text: _shareText(l10n),
                                            origin: shareOriginOf(buttonContext),
                                          );
                                    },
                              icon: const Icon(Icons.ios_share_rounded, size: 18),
                              color: AppColors.ink,
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.bg,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (widget.isMine) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: FilledButton(
                                onPressed: state.isBusy
                                    ? null
                                    : () async {
                                        // No picture for the feed: the backend
                                        // derives and draws the real card.
                                        await context.read<ShareWinCubit>().shareCardToFeed(
                                              eventId: widget.data.eventId,
                                              carId: widget.data.car.id,
                                              caption: _caption.text.trim().isEmpty
                                                  ? null
                                                  : _caption.text.trim(),
                                            );
                                      },
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.9,
                                  ),
                                ),
                                child: state.status == ShareWinStatus.posting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(l10n.contestsPostToFeed),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
