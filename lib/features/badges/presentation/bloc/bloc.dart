import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_my_locked_badges.dart';
import '../utils/badge_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Owns the *locked* half of the badges sheet. The earned half comes down with
/// the profile, so this bloc exists only on your own profile.
@injectable
class BadgesBloc extends Bloc<BadgesEvent, BadgesState> {
  final GetMyLockedBadgesUseCase getMyLockedBadges;

  BadgesBloc({required this.getMyLockedBadges}) : super(const BadgesInitial()) {
    on<LoadLockedBadges>(_onLoadLockedBadges);
  }

  FutureOr<void> _onLoadLockedBadges(
    LoadLockedBadges event,
    Emitter<BadgesState> emit,
  ) async {
    emit(const BadgesLoading());
    final result = await getMyLockedBadges(NoParams());
    result.fold(
      (failure) => emit(BadgesError(BadgeErrorMapper.getCode(failure))),
      (badges) => emit(BadgesLoaded(badges)),
    );
  }
}
