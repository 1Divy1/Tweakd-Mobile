import 'package:tweakd/core/usecases/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/contest.dart';
import '../../../domain/entities/map_event.dart';
import '../../../domain/usecases/map_event_contests.dart';
import '../../utils/map_event_error_mapper.dart';
import 'state.dart';
import 'package:tweakd/core/analytics/analytics_events.dart';
import 'package:tweakd/core/analytics/analytics_service.dart';

/// The new / edit contest form.
///
/// The opening time is resolved here, from the event's own schedule, so the
/// form can offer "at the start of the meet" without the page doing date
/// arithmetic. The closing time is a plain instant the organizer picks — it is
/// only a label attendees see; the organizer opens and closes voting by hand.
@injectable
class CreateContestCubit extends Cubit<CreateContestState> {
  final GetContestCategoriesUseCase getCategories;
  final CreateContestUseCase createContest;
  final UpdateContestUseCase updateContest;
  final AnalyticsService analytics;

  CreateContestCubit({
    required this.getCategories,
    required this.createContest,
    required this.updateContest,
    this.analytics = const NoopAnalyticsService(),
  }) : super(const CreateContestState());

  Future<void> load({MapEventEntity? event, ContestEntity? editing}) async {
    emit(CreateContestState(
      status: CreateContestStatus.loading,
      editing: editing,
      categoryId: editing?.category.id,
      title: editing?.title ?? '',
      criteria: editing?.criteria ?? '',
      opensChoice: editing == null
          ? ContestOpensChoice.atEventStart
          : ContestOpensChoice.custom,
      customOpensAt: editing?.opensAt,
      // Seed a sensible planned close so the form is valid without a tap; the
      // organizer overrides it from the picker. It's a label only.
      closesAt: editing?.closesAt ??
          (event == null ? null : _defaultCloses(event)),
    ));
    final result = await getCategories(NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        status: CreateContestStatus.failure,
        error: MapEventErrorMapper.from(failure),
      )),
      (categories) => emit(state.copyWith(
        status: CreateContestStatus.ready,
        categories: categories,
        clearError: true,
      )),
    );
  }

  /// Picking a predefined category pre-fills the title with its label unless
  /// the organizer already typed something of their own.
  void pickCategory(ContestCategoryEntity category) {
    final previous = state.category;
    final titleWasDefault =
        state.title.isEmpty || (previous != null && state.title == previous.label);
    emit(state.copyWith(
      categoryId: category.id,
      title: category.isCustom
          ? (titleWasDefault ? '' : state.title)
          : (titleWasDefault ? category.label : state.title),
    ));
  }

  void setTitle(String value) => emit(state.copyWith(title: value));
  void setCriteria(String value) => emit(state.copyWith(criteria: value));

  void setOpensChoice(ContestOpensChoice choice, {DateTime? at}) =>
      emit(state.copyWith(opensChoice: choice, customOpensAt: at));

  void setClosesAt(DateTime at) => emit(state.copyWith(closesAt: at));

  /// "An hour before the meet ends" — the value the form starts on, kept only
  /// as a default the organizer can move, not as an offered choice.
  static DateTime _defaultCloses(MapEventEntity event) {
    final end = event.endsAt ?? event.startsAt.add(const Duration(hours: 24));
    return end.subtract(const Duration(hours: 1));
  }

  /// The instants the form currently means, given the event's schedule.
  ({DateTime opensAt, DateTime closesAt}) resolveTimes(MapEventEntity event) {
    final now = DateTime.now();
    final opensAt = switch (state.opensChoice) {
      ContestOpensChoice.now => now,
      ContestOpensChoice.atEventStart =>
        event.startsAt.isAfter(now) ? event.startsAt : now,
      ContestOpensChoice.custom => state.customOpensAt ?? now,
    };
    final closesAt = state.closesAt ?? _defaultCloses(event);
    return (opensAt: opensAt, closesAt: closesAt);
  }

  Future<void> submit(MapEventEntity event) async {
    if (!state.canSubmit) return;
    emit(state.copyWith(status: CreateContestStatus.submitting, clearError: true));

    final times = resolveTimes(event);
    final criteria = state.criteria.trim();
    final editing = state.editing;

    final result = editing == null
        ? await createContest(CreateContestParams(
            eventId: event.id,
            categoryId: state.categoryId!,
            title: state.title.trim(),
            criteria: criteria.isEmpty ? null : criteria,
            opensAt: times.opensAt,
            closesAt: times.closesAt,
          ))
        : await updateContest(UpdateContestParams(
            eventId: event.id,
            contestId: editing.id,
            // While open the backend refuses a title or opening change; send
            // only what may change so an untouched form never 409s.
            title: editing.isOpen ? null : state.title.trim(),
            criteria: criteria,
            opensAt: editing.isOpen ? null : times.opensAt,
            closesAt: times.closesAt,
          ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: CreateContestStatus.ready,
        error: MapEventErrorMapper.from(failure),
      )),
      (contest) {
        if (editing == null) {
          analytics.track(AnalyticsEvents.contestCreated, {
            'category': state.categoryId!,
            'source': 'manage_event',
          });
        }
        emit(state.copyWith(
          status: CreateContestStatus.success,
          result: contest,
        ));
      },
    );
  }

  void clearError() => emit(state.copyWith(clearError: true));
}
