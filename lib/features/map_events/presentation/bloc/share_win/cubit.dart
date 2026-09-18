import 'dart:ui' show Rect;

import 'package:tweakd/core/services/share_launcher_service.dart';
import 'package:tweakd/features/posts/domain/entities/post_params.dart';
import 'package:tweakd/features/posts/domain/failures/post_failures.dart';
import 'package:tweakd/features/posts/domain/usecases/share_participant_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'state.dart';
import 'package:tweakd/core/analytics/analytics_events.dart';
import 'package:tweakd/core/analytics/analytics_service.dart';

/// Shares a participant card: to the feed, or out through the OS share sheet.
///
/// The feed path sends no image and no rank — only which card. The backend
/// checks the card is the viewer's, creates an ordinary post that tags the car
/// and carries the card reference, and derives the card on every read, so the
/// feed draws the real, tappable card rather than a picture of one. The OS
/// share sheet still gets a rendered PNG: outside the app, a picture is all
/// there is.
@injectable
class ShareWinCubit extends Cubit<ShareWinState> {
  final ShareParticipantCardUseCase shareCard;
  final ShareLauncherService shareLauncher;
  final AnalyticsService analytics;

  ShareWinCubit({
    required this.shareCard,
    required this.shareLauncher,
    this.analytics = const NoopAnalyticsService(),
  }) : super(const ShareWinState());

  Future<void> shareCardToFeed({
    required String eventId,
    required String carId,
    String? caption,
  }) async {
    if (state.isBusy || state.isPosted) return;
    emit(const ShareWinState(status: ShareWinStatus.posting));

    final result = await shareCard(ShareParticipantCardParams(
      eventId: eventId,
      carId: carId,
      description: caption,
    ));
    if (isClosed) return;
    result.fold(
      (failure) {
        debugPrint('Share card to feed failed: ${failure.message}');
        emit(failure is ParticipantCardCooldownFailure
            ? ShareWinState(
                status: ShareWinStatus.cooldown,
                nextAllowedAt: failure.nextAllowedAt,
              )
            : const ShareWinState(status: ShareWinStatus.failure));
      },
      (post) {
        analytics.track(AnalyticsEvents.participantCardShared, {
          'destination': 'feed',
        });
        emit(ShareWinState(status: ShareWinStatus.posted, postId: post.id));
      },
    );
  }

  Future<void> shareExternally({
    required Uint8List cardPng,
    required String text,
    Rect? origin,
  }) async {
    if (state.isBusy) return;
    final before = state;
    emit(const ShareWinState(status: ShareWinStatus.sharing));
    // The system sheet can't report whether anything was actually sent, so
    // this counts opening it.
    analytics.track(AnalyticsEvents.participantCardShared, {
      'destination': 'external',
    });
    await shareLauncher.shareImage(
      cardPng,
      fileName: 'tweakd-card.png',
      text: text,
      origin: origin,
    );
    emit(before);
  }

  void reset() => emit(const ShareWinState());
}
