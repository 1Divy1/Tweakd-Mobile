import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/share_post.dart';
import '../../utils/post_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Backs the dedicated share screen: attaches an optional note to a share and
/// reports success/failure so the screen can pop or surface an error.
@injectable
class SharePostBloc extends Bloc<SharePostEvent, SharePostState> {
  final SharePostUseCase sharePost;

  SharePostBloc(this.sharePost) : super(const SharePostState()) {
    on<SubmitShare>(_onSubmit);
  }

  Future<void> _onSubmit(
    SubmitShare event,
    Emitter<SharePostState> emit,
  ) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(status: ShareStatus.submitting));

    final content = event.content?.trim();
    final result = await sharePost(SharePostParams(
      postId: event.postId,
      content: (content == null || content.isEmpty) ? null : content,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: ShareStatus.failure,
        errorCode: PostErrorMapper.getCode(failure),
      )),
      (_) => emit(state.copyWith(status: ShareStatus.success)),
    );
  }
}
