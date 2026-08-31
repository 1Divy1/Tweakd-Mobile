import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:tweakd/features/garage/domain/usecases/get_reference_data.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../utils/forum_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Loads the browse page: the car brand catalog, reused from the garage
/// reference data. Brands (and their models) are the only forum categories.
@injectable
class ForumBrowseBloc extends Bloc<ForumBrowseEvent, ForumBrowseState> {
  final GetBrandsUseCase getBrands;

  ForumBrowseBloc({required this.getBrands}) : super(const ForumBrowseInitial()) {
    on<LoadForumBrowse>(_onLoad);
  }

  Future<void> _onLoad(
    LoadForumBrowse event,
    Emitter<ForumBrowseState> emit,
  ) async {
    emit(const ForumBrowseLoading());

    final brandsResult = await getBrands(NoParams());

    brandsResult.fold(
      (f) => emit(ForumBrowseError(ForumErrorMapper.getCode(f))),
      (brands) => emit(ForumBrowseLoaded(brands: brands)),
    );
  }
}
