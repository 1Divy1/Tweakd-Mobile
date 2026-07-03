import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:car_social_media_app/features/garage/domain/usecases/get_reference_data.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../../domain/usecases/get_forum_topics.dart';
import '../../utils/forum_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Loads the browse page's two tabs: the car brand catalog (reused from the
/// garage reference data) and the forum topic groups.
@injectable
class ForumBrowseBloc extends Bloc<ForumBrowseEvent, ForumBrowseState> {
  final GetBrandsUseCase getBrands;
  final GetForumTopicsUseCase getTopics;

  ForumBrowseBloc({required this.getBrands, required this.getTopics})
      : super(const ForumBrowseInitial()) {
    on<LoadForumBrowse>(_onLoad);
  }

  Future<void> _onLoad(
    LoadForumBrowse event,
    Emitter<ForumBrowseState> emit,
  ) async {
    emit(const ForumBrowseLoading());

    final brandsFuture = getBrands(NoParams());
    final topicsFuture = getTopics(NoParams());
    final brandsResult = await brandsFuture;
    final topicsResult = await topicsFuture;

    brandsResult.fold(
      (f) => emit(ForumBrowseError(ForumErrorMapper.getCode(f))),
      (brands) => topicsResult.fold(
        (f) => emit(ForumBrowseError(ForumErrorMapper.getCode(f))),
        (groups) =>
            emit(ForumBrowseLoaded(brands: brands, topicGroups: groups)),
      ),
    );
  }
}
