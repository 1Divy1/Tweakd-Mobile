import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../../domain/usecases/get_inbox.dart';
import '../../utils/messages_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Drives the messages inbox: one-shot load, pull-to-refresh and client-side
/// search over the loaded conversations.
@injectable
class InboxBloc extends Bloc<InboxEvent, InboxState> {
  final GetInboxUseCase getInbox;

  InboxBloc({required this.getInbox}) : super(const InboxInitial()) {
    on<LoadInbox>(_onLoad);
    on<RefreshInbox>(_onRefresh);
    on<InboxSearchChanged>(_onSearchChanged);
  }

  Future<void> _onLoad(LoadInbox event, Emitter<InboxState> emit) async {
    emit(const InboxLoading());
    final result = await getInbox(NoParams());
    result.fold(
      (failure) => emit(InboxError(MessagesErrorMapper.getCode(failure))),
      (inbox) => emit(InboxLoaded(inbox: inbox)),
    );
  }

  Future<void> _onRefresh(RefreshInbox event, Emitter<InboxState> emit) async {
    try {
      final result = await getInbox(NoParams());
      result.fold(
        (_) {}, // keep the current list on a failed refresh
        (inbox) {
          final current = state;
          emit(current is InboxLoaded
              ? current.copyWith(inbox: inbox)
              : InboxLoaded(inbox: inbox));
        },
      );
    } finally {
      event.completer?.complete();
    }
  }

  void _onSearchChanged(InboxSearchChanged event, Emitter<InboxState> emit) {
    final current = state;
    if (current is InboxLoaded) emit(current.copyWith(query: event.query));
  }
}
