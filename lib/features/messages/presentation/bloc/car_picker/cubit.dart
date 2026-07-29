import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../../../garage/domain/usecases/get_my_garage.dart';
import 'state.dart';

/// Loads the viewer's own garage cars for the DM car-share picker. Reuses the
/// garage feature's [GetMyGarageUseCase] — no DM-specific endpoint.
@injectable
class GarageCarsCubit extends Cubit<GarageCarsState> {
  final GetMyGarageUseCase getMyGarage;

  GarageCarsCubit({required this.getMyGarage}) : super(const GarageCarsState());

  Future<void> load() async {
    emit(const GarageCarsState(status: GarageCarsStatus.loading));
    final result = await getMyGarage(NoParams());
    if (isClosed) return;
    result.fold(
      (_) => emit(const GarageCarsState(status: GarageCarsStatus.error)),
      (garage) => emit(GarageCarsState(
        status: GarageCarsStatus.loaded,
        cars: garage.cars,
      )),
    );
  }
}
