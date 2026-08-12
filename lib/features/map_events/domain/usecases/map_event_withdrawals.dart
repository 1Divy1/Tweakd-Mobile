import 'package:car_social_media_app/core/error/base_failures.dart';
import 'package:car_social_media_app/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../entities/map_event_participant.dart';
import '../entities/map_event_withdrawal_request.dart';
import '../repositories/map_events_repository.dart';

class WithdrawFromMapEventParams {
  final String eventId;

  /// The dialog's optional "note for organizers".
  final String? note;

  const WithdrawFromMapEventParams({required this.eventId, this.note});
}

/// `POST /{id}/withdraw`. Flags every accepted car the caller has in the event
/// as `withdrawn` and waits for an organizer.
///
/// **One-way.** No endpoint lets the participant cancel their own request, so
/// the UI must not offer an undo.
@lazySingleton
class WithdrawFromMapEventUseCase
    implements
        UseCase<List<MapEventParticipantEntity>, WithdrawFromMapEventParams> {
  final MapEventsRepository repository;

  WithdrawFromMapEventUseCase(this.repository);

  @override
  Future<Either<Failure, List<MapEventParticipantEntity>>> call(
    WithdrawFromMapEventParams params,
  ) {
    return repository.withdraw(params.eventId, note: params.note);
  }
}

/// Organizer-only queue of pending withdrawal requests, grouped by owner.
@lazySingleton
class GetMapEventWithdrawalsUseCase
    implements UseCase<List<MapEventWithdrawalRequestEntity>, String> {
  final MapEventsRepository repository;

  GetMapEventWithdrawalsUseCase(this.repository);

  @override
  Future<Either<Failure, List<MapEventWithdrawalRequestEntity>>> call(
    String eventId,
  ) {
    return repository.getWithdrawals(eventId);
  }
}

class ReviewWithdrawalParams {
  final String eventId;

  /// The participant's user id — withdrawals are keyed by owner, not by car.
  final String ownerId;

  const ReviewWithdrawalParams({required this.eventId, required this.ownerId});
}

/// Lets the owner out: hard-deletes their rows for the event.
@lazySingleton
class ApproveWithdrawalUseCase implements UseCase<Unit, ReviewWithdrawalParams> {
  final MapEventsRepository repository;

  ApproveWithdrawalUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ReviewWithdrawalParams params) {
    return repository.approveWithdrawal(params.eventId, params.ownerId);
  }
}

/// Keeps the owner in: reverts their rows to `accepted`.
@lazySingleton
class RejectWithdrawalUseCase
    implements
        UseCase<List<MapEventParticipantEntity>, ReviewWithdrawalParams> {
  final MapEventsRepository repository;

  RejectWithdrawalUseCase(this.repository);

  @override
  Future<Either<Failure, List<MapEventParticipantEntity>>> call(
    ReviewWithdrawalParams params,
  ) {
    return repository.rejectWithdrawal(params.eventId, params.ownerId);
  }
}
