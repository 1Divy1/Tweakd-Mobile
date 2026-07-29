import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../../domain/usecases/get_language_options.dart';
import '../../../domain/usecases/set_app_language.dart';
import '../../utils/profile_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Backs the language picker bottom sheet. Deliberately has no dependency on
/// `LocaleCubit` — the sheet widget listens for [LanguagePickerState.confirmNonce]
/// changes and flips the active locale itself, keeping this bloc a pure
/// fetch/PATCH data flow.
@injectable
class LanguagePickerBloc extends Bloc<LanguagePickerEvent, LanguagePickerState> {
  final GetLanguageOptionsUseCase getLanguageOptions;
  final SetAppLanguageUseCase setAppLanguage;

  LanguagePickerBloc({
    required this.getLanguageOptions,
    required this.setAppLanguage,
  }) : super(const LanguagePickerState()) {
    on<LoadLanguageOptions>(_onLoad);
    on<SelectLanguage>(_onSelect);
  }

  FutureOr<void> _onLoad(
    LoadLanguageOptions event,
    Emitter<LanguagePickerState> emit,
  ) async {
    emit(state.copyWith(
      status: LanguagePickerStatus.loading,
      activeCode: event.currentCode,
    ));

    final result = await getLanguageOptions(NoParams());
    result.fold(
      (_) => emit(state.copyWith(status: LanguagePickerStatus.error)),
      (options) => emit(state.copyWith(
        status: LanguagePickerStatus.loaded,
        options: options,
      )),
    );
  }

  FutureOr<void> _onSelect(
    SelectLanguage event,
    Emitter<LanguagePickerState> emit,
  ) async {
    if (state.updating || event.code == state.activeCode) return;

    emit(state.copyWith(updating: true));

    final result = await setAppLanguage(
      SetAppLanguageParams(languageId: event.code),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        updating: false,
        updateErrorCode: ProfileErrorMapper.getCode(failure),
        updateErrorNonce: state.updateErrorNonce + 1,
      )),
      (profile) => emit(state.copyWith(
        updating: false,
        activeCode: profile.appLanguage,
        confirmNonce: state.confirmNonce + 1,
      )),
    );
  }
}
