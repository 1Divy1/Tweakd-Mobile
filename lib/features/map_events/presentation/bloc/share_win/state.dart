import 'package:equatable/equatable.dart';

enum ShareWinStatus { idle, posting, posted, sharing, failure, cooldown }

class ShareWinState extends Equatable {
  final ShareWinStatus status;
  final String? postId;

  /// When the card may be shared to the feed again — set with
  /// [ShareWinStatus.cooldown].
  final DateTime? nextAllowedAt;

  const ShareWinState({
    this.status = ShareWinStatus.idle,
    this.postId,
    this.nextAllowedAt,
  });

  bool get isBusy =>
      status == ShareWinStatus.posting || status == ShareWinStatus.sharing;
  bool get isPosted => status == ShareWinStatus.posted;

  @override
  List<Object?> get props => [status, postId, nextAllowedAt];
}
