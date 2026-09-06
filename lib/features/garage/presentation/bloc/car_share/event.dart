import 'package:equatable/equatable.dart';

abstract class CarShareEvent extends Equatable {
  const CarShareEvent();

  @override
  List<Object?> get props => [];
}

/// Opens the car's share link, minting one if this is the first time. Sent
/// when the share sheet opens.
class LoadShareLink extends CarShareEvent {
  final String carId;
  const LoadShareLink(this.carId);

  @override
  List<Object?> get props => [carId];
}

/// Fetches the printable QR. Sent when the QR modal opens; the SVG is kept on
/// the state afterwards, so re-opening the modal costs nothing.
class LoadShareQr extends CarShareEvent {
  final String carId;
  const LoadShareQr(this.carId);

  @override
  List<Object?> get props => [carId];
}

/// Pauses or resumes the public page. The code survives, so a printed sticker
/// starts working again the moment sharing is resumed.
class SetShareEnabled extends CarShareEvent {
  final String carId;
  final bool enabled;
  const SetShareEnabled({required this.carId, required this.enabled});

  @override
  List<Object?> get props => [carId, enabled];
}
