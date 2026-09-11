import 'dart:io';

import 'package:tweakd/core/services/image_service.dart';
import 'package:tweakd/features/map/domain/entities/geo_position.dart';

import '../../domain/entities/map_event_enums.dart';
import '../../domain/entities/organizer_candidate.dart';
import '../bloc/create_contest/state.dart';
import '../bloc/create_event/state.dart';

/// Turns the create-event form into a plain map and back, for
/// [CreateEventDraftLocalDataSource].
///
/// Keys are the state's own field names rather than the API's snake_case: this
/// file never reaches the backend, and matching the Dart side keeps the two
/// directions readable against each other.
///
/// What is deliberately *not* saved:
/// - the wizard's step. Restoring always lands on BASICS, so the organizer
///   walks past their own answers instead of being dropped mid-flow into a
///   screen they've forgotten the context of.
/// - the loaded category lists, which are reference data and refetched anyway.
class CreateEventDraft {
  CreateEventDraft._();

  static Map<String, dynamic> encode(CreateMapEventState state) {
    final position = state.position;
    return {
      'title': state.title,
      'categoryId': state.categoryId,
      'description': state.description,
      'locationName': state.locationName,
      'city': state.city,
      'street': state.street,
      'number': state.number,
      'lat': position?.lat,
      'lng': position?.lng,
      'startsAt': state.startsAt?.toIso8601String(),
      'endsAt': state.endsAt?.toIso8601String(),
      'registrationDeadline': state.registrationDeadline?.toIso8601String(),
      'capacity': state.capacity,
      'requiresApproval': state.requiresApproval,
      'rules': state.rules,
      'coverPath': state.cover?.path,
      'organizers': [
        for (final pending in state.pendingOrganizers)
          {
            'type': pending.candidate.type.apiValue,
            'referenceId': pending.candidate.referenceId,
            'name': pending.candidate.name,
            'username': pending.candidate.username,
            'imageUrl': pending.candidate.imageUrl,
          },
      ],
      'contests': [
        for (final contest in state.pendingContests)
          {
            'localId': contest.localId,
            'categoryId': contest.categoryId,
            'categoryLabel': contest.categoryLabel,
            'title': contest.title,
            'criteria': contest.criteria,
            'opensChoice': contest.opensChoice.name,
            'customOpensAt': contest.customOpensAt?.toIso8601String(),
            'closesAt': contest.closesAt?.toIso8601String(),
          },
      ],
    };
  }

  /// Rebuilds the form fields from [draft], layering them onto [base] so the
  /// freshly loaded category lists survive.
  ///
  /// [imageService] is needed to restart compression on a restored cover; a
  /// `CompressedImage` holds a live future, which a file can't.
  static CreateMapEventState decode(
    Map<String, dynamic> draft,
    CreateMapEventState base,
    ImageService imageService,
  ) {
    final lat = _double(draft['lat']);
    final lng = _double(draft['lng']);

    // The picked cover lives in the image picker's temp directory, which iOS
    // is free to empty between launches. A path that no longer resolves is
    // dropped rather than restored into a form that would fail at upload.
    final coverPath = draft['coverPath'] as String?;
    final coverExists =
        coverPath != null && coverPath.isNotEmpty && File(coverPath).existsSync();

    return base.copyWith(
      title: draft['title'] as String? ?? '',
      categoryId: draft['categoryId'] as String? ?? base.categoryId,
      description: draft['description'] as String? ?? '',
      locationName: draft['locationName'] as String? ?? '',
      city: draft['city'] as String? ?? '',
      street: draft['street'] as String? ?? '',
      number: draft['number'] as String? ?? '',
      position: (lat != null && lng != null)
          ? GeoPosition(lat: lat, lng: lng)
          : null,
      startsAt: _date(draft['startsAt']),
      endsAt: _date(draft['endsAt']),
      registrationDeadline: _date(draft['registrationDeadline']),
      capacity: draft['capacity'] as int?,
      requiresApproval: draft['requiresApproval'] as bool? ?? true,
      rules: [
        for (final rule in (draft['rules'] as List<dynamic>? ?? const []))
          rule as String,
      ],
      cover: coverExists
          ? CompressedImage.compress(coverPath, imageService)
          : null,
      pendingOrganizers: [
        for (final entry
            in (draft['organizers'] as List<dynamic>? ?? const []))
          PendingOrganizer(
            OrganizerCandidateEntity(
              type: MapEventOrganizerType.fromApi(
                (entry as Map<String, dynamic>)['type'] as String?,
              ),
              referenceId: entry['referenceId'] as String? ?? '',
              name: entry['name'] as String? ?? '',
              username: entry['username'] as String?,
              imageUrl: entry['imageUrl'] as String?,
            ),
          ),
      ],
      pendingContests: [
        for (final entry in (draft['contests'] as List<dynamic>? ?? const []))
          PendingContest(
            localId: (entry as Map<String, dynamic>)['localId'] as String? ?? '',
            categoryId: entry['categoryId'] as String? ?? '',
            categoryLabel: entry['categoryLabel'] as String? ?? '',
            title: entry['title'] as String? ?? '',
            criteria: entry['criteria'] as String? ?? '',
            opensChoice: _opens(entry['opensChoice'] as String?),
            customOpensAt: _date(entry['customOpensAt']),
            closesAt: _date(entry['closesAt']),
          ),
      ],
      restoredFromDraft: true,
    );
  }

  /// True when the draft holds anything worth restoring. A draft written after
  /// a single keystroke that was then deleted shouldn't announce itself.
  static bool isWorthRestoring(Map<String, dynamic> draft) {
    bool filled(Object? value) => value is String && value.trim().isNotEmpty;

    return filled(draft['title']) ||
        filled(draft['description']) ||
        filled(draft['locationName']) ||
        draft['startsAt'] != null ||
        draft['coverPath'] != null ||
        (draft['rules'] as List<dynamic>? ?? const []).isNotEmpty ||
        (draft['organizers'] as List<dynamic>? ?? const []).isNotEmpty ||
        (draft['contests'] as List<dynamic>? ?? const []).isNotEmpty;
  }

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;

  static double? _double(Object? value) =>
      value is num ? value.toDouble() : null;

  static ContestOpensChoice _opens(String? name) {
    for (final choice in ContestOpensChoice.values) {
      if (choice.name == name) return choice;
    }
    return ContestOpensChoice.atEventStart;
  }
}
