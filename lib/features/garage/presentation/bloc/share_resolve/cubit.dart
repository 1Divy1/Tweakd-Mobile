import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/resolve_share_code.dart';
import '../../utils/garage_error_mapper.dart';
import 'state.dart';

/// Turns the code from a scanned QR or a tapped link into a car id.
///
/// A cubit rather than a bloc: there is exactly one thing to do, once, and the
/// screen that owns it is a spinner that redirects the moment it lands.
@injectable
class ShareResolveCubit extends Cubit<ShareResolveState> {
  final ResolveShareCodeUseCase _resolveShareCode;

  ShareResolveCubit(this._resolveShareCode) : super(const ShareResolveLoading());

  Future<void> resolve(String code, {String? source}) async {
    emit(const ShareResolveLoading());
    final result = await _resolveShareCode(
      ResolveShareCodeParams(code: code, source: source),
    );
    if (isClosed) return;
    result.fold(
      (failure) =>
          emit(ShareResolveFailed(code: GarageErrorMapper.getCode(failure))),
      (resolution) => emit(
        ShareResolveResolved(
          carId: resolution.carId,
          ownerUsername: resolution.ownerUsername,
        ),
      ),
    );
  }
}
