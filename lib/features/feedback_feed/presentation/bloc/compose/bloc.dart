import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../../domain/usecases/get_feedback_options.dart';
import '../../../domain/usecases/manage_feedback_message.dart';
import '../../utils/feedback_feed_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Drives the "Share feedback" compose screen: loads the category chips, tracks
/// the draft and publishes it.
@injectable
class ComposeFeedbackBloc
    extends Bloc<ComposeFeedbackEvent, ComposeFeedbackState> {
  final GetFeedbackTypesUseCase getTypes;
  final CreateFeedbackMessageUseCase createMessage;

  ComposeFeedbackBloc({required this.getTypes, required this.createMessage})
      : super(const ComposeFeedbackState()) {
    on<LoadFeedbackTypes>(_onLoadTypes);
    on<SelectFeedbackType>(_onSelectType);
    on<FeedbackMessageChanged>(_onMessageChanged);
    on<SubmitFeedbackMessage>(_onSubmit);
  }

  Future<void> _onLoadTypes(
    LoadFeedbackTypes event,
    Emitter<ComposeFeedbackState> emit,
  ) async {
    emit(state.copyWith(status: ComposeFeedbackStatus.loadingTypes));

    final result = await getTypes(NoParams());

    result.fold(
      // Without categories there is nothing to post, so this is a hard error.
      (_) => emit(state.copyWith(status: ComposeFeedbackStatus.typesError)),
      (types) => emit(state.copyWith(
        status: ComposeFeedbackStatus.ready,
        types: types,
      )),
    );
  }

  void _onSelectType(
    SelectFeedbackType event,
    Emitter<ComposeFeedbackState> emit,
  ) {
    emit(state.copyWith(
      selectedTypeId: event.typeId,
      clearSubmitError: true,
    ));
  }

  void _onMessageChanged(
    FeedbackMessageChanged event,
    Emitter<ComposeFeedbackState> emit,
  ) {
    emit(state.copyWith(message: event.message, clearSubmitError: true));
  }

  Future<void> _onSubmit(
    SubmitFeedbackMessage event,
    Emitter<ComposeFeedbackState> emit,
  ) async {
    if (!state.canSubmit) return;

    final typeId = state.selectedTypeId!;
    emit(state.copyWith(
      status: ComposeFeedbackStatus.submitting,
      clearSubmitError: true,
    ));

    final result = await createMessage(CreateFeedbackMessageParams(
      typeId: typeId,
      message: state.message.trim(),
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        // Back to ready so the user can fix and retry without losing the draft.
        status: ComposeFeedbackStatus.ready,
        submitError: FeedbackFeedErrorMapper.getCode(failure),
      )),
      (_) => emit(state.copyWith(status: ComposeFeedbackStatus.success)),
    );
  }
}
