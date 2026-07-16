import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/compose.dart';
import 'event.dart';
import 'state.dart';

/// Drives the new-message sheet: user search as the viewer types. Picking a
/// user is handled by the sheet itself (it pops with the tapped user) —
/// there is no create-conversation call; the first message creates it.
@injectable
class ComposeBloc extends Bloc<ComposeEvent, ComposeState> {
  final GetComposeSuggestionsUseCase getSuggestions;

  ComposeBloc({required this.getSuggestions}) : super(const ComposeState()) {
    on<ComposeQueryChanged>(_onQueryChanged);
  }

  Future<void> _onQueryChanged(
    ComposeQueryChanged event,
    Emitter<ComposeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final result = await getSuggestions(event.query);
    result.fold(
      (_) => emit(state.copyWith(isLoading: false, users: const [])),
      (users) => emit(state.copyWith(isLoading: false, users: users)),
    );
  }
}
