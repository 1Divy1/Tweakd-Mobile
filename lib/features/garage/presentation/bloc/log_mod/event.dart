import 'package:equatable/equatable.dart';

import '../add_car/event.dart';

abstract class LogModEvent extends Equatable {
  const LogModEvent();

  @override
  List<Object?> get props => [];
}

class LoadModCategories extends LogModEvent {
  const LoadModCategories();
}

class SubmitModification extends LogModEvent {
  final String carId;

  /// The entry's text plus its before/after photos — up to
  /// `maxModImagesPerPhase` per phase, each already being compressed since
  /// selection time.
  final NewModInput input;

  /// Whether the finished entry also goes to the feed. On by default in the UI
  /// — the share is what turns a private build log into content other people
  /// see.
  final bool shareToFeed;

  /// Whether [shareToFeed] is still the default the user was shown. Analytics
  /// only; it says how much of the sharing the default is responsible for.
  final bool shareIsDefault;

  const SubmitModification({
    required this.carId,
    required this.input,
    this.shareToFeed = false,
    this.shareIsDefault = true,
  });

  @override
  List<Object?> get props => [carId, input, shareToFeed, shareIsDefault];
}
