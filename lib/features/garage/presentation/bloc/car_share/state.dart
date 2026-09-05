import 'package:equatable/equatable.dart';

import '../../../domain/entities/car_share.dart';
import '../../utils/garage_error_mapper.dart';

abstract class CarShareState extends Equatable {
  const CarShareState();

  @override
  List<Object?> get props => [];
}

class CarShareLoading extends CarShareState {
  const CarShareLoading();
}

/// The link is in hand. QR state rides along on the same object because the
/// modal is opened from the sheet and both need the code — splitting them
/// would mean two blocs sharing one link.
class CarShareLoaded extends CarShareState {
  final CarShareEntity link;

  /// The QR as raw SVG source, once fetched. Held for the life of the sheet so
  /// closing and re-opening the modal does not hit the network again.
  final String? qrSvg;
  final bool isQrLoading;

  /// Set when the QR fetch failed; the modal shows a retry instead of the code.
  final GarageErrorCode? qrError;

  /// True while the pause/resume switch is waiting on the server.
  final bool isTogglingEnabled;

  const CarShareLoaded({
    required this.link,
    this.qrSvg,
    this.isQrLoading = false,
    this.qrError,
    this.isTogglingEnabled = false,
  });

  CarShareLoaded copyWith({
    CarShareEntity? link,
    String? qrSvg,
    bool? isQrLoading,
    GarageErrorCode? qrError,
    bool clearQrError = false,
    bool? isTogglingEnabled,
  }) {
    return CarShareLoaded(
      link: link ?? this.link,
      qrSvg: qrSvg ?? this.qrSvg,
      isQrLoading: isQrLoading ?? this.isQrLoading,
      qrError: clearQrError ? null : (qrError ?? this.qrError),
      isTogglingEnabled: isTogglingEnabled ?? this.isTogglingEnabled,
    );
  }

  @override
  List<Object?> get props => [
    link,
    qrSvg,
    isQrLoading,
    qrError,
    isTogglingEnabled,
  ];
}

/// The link itself could not be loaded, so the sheet has nothing to show.
class CarShareError extends CarShareState {
  final GarageErrorCode code;
  const CarShareError({required this.code});

  @override
  List<Object?> get props => [code];
}
