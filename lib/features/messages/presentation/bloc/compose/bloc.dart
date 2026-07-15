import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/compose.dart';
import 'event.dart';
import 'state.dart';

/// Drives the new-message sheet: suggested users filtered as the viewer
/// types, and opening a conversation with a picked user.
@injectable
class ComposeBloc extends Bloc<ComposeEvent, ComposeState> {
  final GetComposeSuggestionsUseCase getSuggestions;
  final StartConversationUseCase startConversation;

  ComposeBloc({
    required this.getSuggestions,
    required this.startConversation,
  }) : super(const ComposeState()) {
    on<ComposeQueryChanged>(_onQueryChanged);
    on<ComposeUserPicked>(_onUserPicked);
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

  Future<void> _onUserPicked(
    ComposeUserPicked event,
    Emitter<ComposeState> emit,
  ) async {
    final result = await startConversation(event.userId);
    result.fold(
      (_) {},
      (conversationId) =>
          emit(state.copyWith(openConversationId: conversationId)),
    );
  }
}
