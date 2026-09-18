import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/ensure_car_share_link.dart';
import '../../../domain/usecases/get_car_share_qr.dart';
import '../../../domain/usecases/set_car_share_enabled.dart';
import '../../utils/garage_error_mapper.dart';
import 'event.dart';
import 'state.dart';
import 'package:tweakd/core/analytics/analytics_events.dart';
import 'package:tweakd/core/analytics/analytics_service.dart';

/// Owns the share sheet: the link, the QR, and the pause switch.
///
/// One bloc for all three because they are one screen's worth of state — the
/// modal is opened from the sheet and needs the same link — and because the
/// link call is what mints the code, so nothing else can run before it.
@injectable
class CarShareBloc extends Bloc<CarShareEvent, CarShareState> {
  final EnsureCarShareLinkUseCase ensureShareLinkUseCase;
  final GetCarShareQrUseCase getShareQrUseCase;
  final SetCarShareEnabledUseCase setShareEnabledUseCase;
  final AnalyticsService analytics;

  CarShareBloc({
    required this.ensureShareLinkUseCase,
    required this.getShareQrUseCase,
    required this.setShareEnabledUseCase,
    this.analytics = const NoopAnalyticsService(),
  }) : super(const CarShareLoading()) {
    on<LoadShareLink>(_onLoadShareLink);
    on<LoadShareQr>(_onLoadShareQr);
    on<SetShareEnabled>(_onSetShareEnabled);
  }

  FutureOr<void> _onLoadShareLink(
    LoadShareLink event,
    Emitter<CarShareState> emit,
  ) async {
    emit(const CarShareLoading());
    final result = await ensureShareLinkUseCase(
      EnsureCarShareLinkParams(carId: event.carId),
    );
    result.fold(
      (failure) => emit(CarShareError(code: GarageErrorMapper.getCode(failure))),
      (link) {
        analytics.track(AnalyticsEvents.carShareOpened);
        emit(CarShareLoaded(link: link));
      },
    );
  }

  FutureOr<void> _onLoadShareQr(
    LoadShareQr event,
    Emitter<CarShareState> emit,
  ) async {
    final current = state;
    // Already fetched, or still fetching: the modal can be re-opened freely.
    if (current is! CarShareLoaded ||
        current.isQrLoading ||
        current.qrSvg != null) {
      return;
    }

    emit(current.copyWith(isQrLoading: true, clearQrError: true));
    final result = await getShareQrUseCase(
      GetCarShareQrParams(carId: event.carId),
    );
    result.fold(
      (failure) => emit(
        current.copyWith(
          isQrLoading: false,
          qrError: GarageErrorMapper.getCode(failure),
        ),
      ),
      (svg) => emit(current.copyWith(isQrLoading: false, qrSvg: svg)),
    );
  }

  FutureOr<void> _onSetShareEnabled(
    SetShareEnabled event,
    Emitter<CarShareState> emit,
  ) async {
    final current = state;
    if (current is! CarShareLoaded || current.isTogglingEnabled) return;

    // Flip optimistically: the switch is the one control here that has to feel
    // instant, and the only failure mode is it snapping back.
    emit(
      current.copyWith(
        link: current.link.copyWith(enabled: event.enabled),
        isTogglingEnabled: true,
      ),
    );

    final result = await setShareEnabledUseCase(
      SetCarShareEnabledParams(carId: event.carId, enabled: event.enabled),
    );
    result.fold(
      (_) => emit(current.copyWith(isTogglingEnabled: false)),
      (link) => emit(current.copyWith(link: link, isTogglingEnabled: false)),
    );
  }
}
