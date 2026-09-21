import 'package:equatable/equatable.dart';

import '../../../domain/entities/car.dart';
import '../../utils/garage_error_mapper.dart';

abstract class CarDetailState extends Equatable {
  const CarDetailState();

  @override
  List<Object?> get props => [];
}

class CarDetailLoading extends CarDetailState {
  const CarDetailLoading();
}

class CarDetailLoaded extends CarDetailState {
  final CarEntity car;
  final bool isDeleting;

  /// The mod currently being posted to the feed, if any — its row shows a
  /// spinner instead of the share label.
  final String? sharingModId;

  /// Set for one emission when a share failed, so the page can say so once
  /// without a state that has to be cleared by hand.
  final String? shareFailedModId;

  const CarDetailLoaded({
    required this.car,
    this.isDeleting = false,
    this.sharingModId,
    this.shareFailedModId,
  });

  CarDetailLoaded copyWith({
    CarEntity? car,
    bool? isDeleting,
    String? sharingModId,
    String? shareFailedModId,
  }) {
    return CarDetailLoaded(
      car: car ?? this.car,
      isDeleting: isDeleting ?? this.isDeleting,
      // Both are transient, so copyWith clears them unless asked otherwise —
      // a stale spinner or a repeated snackbar would be worse than a lost one.
      sharingModId: sharingModId,
      shareFailedModId: shareFailedModId,
    );
  }

  @override
  List<Object?> get props => [car, isDeleting, sharingModId, shareFailedModId];
}

class CarDetailError extends CarDetailState {
  final GarageErrorCode code;
  const CarDetailError({required this.code});

  @override
  List<Object?> get props => [code];
}

class CarDetailDeleted extends CarDetailState {
  const CarDetailDeleted();
}
