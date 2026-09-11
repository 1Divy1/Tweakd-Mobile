import 'package:equatable/equatable.dart';

import '../../../domain/entities/contest.dart';
import '../../utils/map_event_error_mapper.dart';

/// The three ways the design lets an organizer say when voting opens.
enum ContestOpensChoice { now, atEventStart, custom }

enum CreateContestStatus { loading, ready, submitting, success, failure }

class CreateContestState extends Equatable {
  final CreateContestStatus status;
  final List<ContestCategoryEntity> categories;
  final MapEventError? error;

  /// Set when editing; null when creating.
  final ContestEntity? editing;

  final String? categoryId;
  final String title;
  final String criteria;
  final ContestOpensChoice opensChoice;
  final DateTime? customOpensAt;

  /// When voting is *planned* to close. Purely informative — attendees see it,
  /// but nothing acts on it: the organizer opens and closes voting by hand.
  final DateTime? closesAt;

  /// Set on success; the page pops with it.
  final ContestEntity? result;

  const CreateContestState({
    this.status = CreateContestStatus.loading,
    this.categories = const [],
    this.error,
    this.editing,
    this.categoryId,
    this.title = '',
    this.criteria = '',
    this.opensChoice = ContestOpensChoice.atEventStart,
    this.customOpensAt,
    this.closesAt,
    this.result,
  });

  bool get isEditing => editing != null;

  /// Once voting is open only the note and the closing time may change.
  bool get isLockedOpen => editing?.isOpen ?? false;

  ContestCategoryEntity? get category {
    for (final c in categories) {
      if (c.id == categoryId) return c;
    }
    return null;
  }

  bool get isCustomCategory => category?.isCustom ?? false;

  bool get canSubmit =>
      status == CreateContestStatus.ready &&
      categoryId != null &&
      title.trim().length >= 3 &&
      (opensChoice != ContestOpensChoice.custom || customOpensAt != null) &&
      closesAt != null;

  CreateContestState copyWith({
    CreateContestStatus? status,
    List<ContestCategoryEntity>? categories,
    MapEventError? error,
    bool clearError = false,
    ContestEntity? editing,
    String? categoryId,
    String? title,
    String? criteria,
    ContestOpensChoice? opensChoice,
    DateTime? customOpensAt,
    DateTime? closesAt,
    ContestEntity? result,
  }) {
    return CreateContestState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      error: clearError ? null : (error ?? this.error),
      editing: editing ?? this.editing,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      criteria: criteria ?? this.criteria,
      opensChoice: opensChoice ?? this.opensChoice,
      customOpensAt: customOpensAt ?? this.customOpensAt,
      closesAt: closesAt ?? this.closesAt,
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props => [
        status,
        categories,
        error,
        editing,
        categoryId,
        title,
        criteria,
        opensChoice,
        customOpensAt,
        closesAt,
        result,
      ];
}
