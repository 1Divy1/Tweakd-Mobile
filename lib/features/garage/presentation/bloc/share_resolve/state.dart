import 'package:equatable/equatable.dart';

import '../../utils/garage_error_mapper.dart';

abstract class ShareResolveState extends Equatable {
  const ShareResolveState();

  @override
  List<Object?> get props => [];
}

class ShareResolveLoading extends ShareResolveState {
  const ShareResolveLoading();
}

/// The code pointed at a car. The landing page redirects to it and is gone —
/// this state exists to be listened to, not to be drawn.
class ShareResolveResolved extends ShareResolveState {
  final String carId;
  final String ownerUsername;

  const ShareResolveResolved({
    required this.carId,
    required this.ownerUsername,
  });

  @override
  List<Object?> get props => [carId, ownerUsername];
}

/// Unknown code (404), or one that no longer serves (410 — paused, revoked, or
/// a banned owner). Both render the same screen; the distinction is kept
/// because only one of them can come back.
class ShareResolveFailed extends ShareResolveState {
  final GarageErrorCode code;
  const ShareResolveFailed({required this.code});

  @override
  List<Object?> get props => [code];
}
