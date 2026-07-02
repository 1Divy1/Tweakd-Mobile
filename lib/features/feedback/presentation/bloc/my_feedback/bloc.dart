import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../../domain/usecases/get_my_feedback.dart';
import '../../utils/feedback_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Backs the "My feedback" screen: a one-shot load of the feedback the current
/// user has filed. Re-dispatch [LoadMyFeedback] for retry / pull-to-refresh.
@injectable
class MyFeedbackBloc extends Bloc<MyFeedbackEvent, MyFeedbackState> {
  final GetMyFeedbackUseCase getMyFeedback;

  MyFeedbackBloc({required this.getMyFeedback})
      : super(const MyFeedbackInitial()) {
    on<LoadMyFeedback>(_onLoad);
  }

  Future<void> _onLoad(
    LoadMyFeedback event,
    Emitter<MyFeedbackState> emit,
  ) async {
    emit(const MyFeedbackLoading());
    final result = await getMyFeedback(NoParams());
    result.fold(
      (failure) => emit(MyFeedbackError(FeedbackErrorMapper.getCode(failure))),
      (feedback) => emit(MyFeedbackLoaded(feedback)),
    );
  }
}
