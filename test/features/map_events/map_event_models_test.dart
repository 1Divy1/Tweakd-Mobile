import 'package:car_social_media_app/features/map_events/data/models/map_event_json.dart';
import 'package:car_social_media_app/features/map_events/data/models/map_event_list_models.dart';
import 'package:car_social_media_app/features/map_events/data/models/map_event_model.dart';
import 'package:car_social_media_app/features/map_events/data/models/map_event_pin_model.dart';
import 'package:car_social_media_app/features/map_events/domain/entities/map_event_enums.dart';
import 'package:flutter_test/flutter_test.dart';

/// The wire is snake_case and half these fields are nullable, so the mapping is
/// where this feature is most likely to break silently — a mistyped key gives a
/// plausible-looking entity full of defaults rather than an error.
void main() {
  group('MapEventPinModel', () {
    test('maps a full payload', () {
      final pin = MapEventPinModel.fromJson({
        'id': 'e1',
        'title': 'Casino Square Cars & Coffee',
        'category_id': 'car_meet',
        'category_label': 'Car meet',
        'lat': 43.7396,
        'lng': 7.4272,
        'location_name': 'Place du Casino',
        'cover_image_url': 'https://cdn/x.webp',
        'starts_at': '2026-08-11T16:00:00Z',
        'ends_at': '2026-08-11T21:00:00Z',
        'status': 'live',
        'attendees_count': 247,
        'attending_cars_count': 34,
        'max_participant_capacity': 40,
      }).toEntity();

      expect(pin.id, 'e1');
      expect(pin.categoryId, 'car_meet');
      expect(pin.position.lat, 43.7396);
      expect(pin.position.lng, 7.4272);
      expect(pin.status, MapEventStatus.live);
      expect(pin.isLive, isTrue);
      expect(pin.attendeesCount, 247);
      expect(pin.isAtCapacity, isFalse);
    });

    test('treats a full entry list as at capacity', () {
      final pin = MapEventPinModel.fromJson({
        'id': 'e1',
        'lat': 0,
        'lng': 0,
        'starts_at': '2026-08-11T16:00:00Z',
        'attending_cars_count': 40,
        'max_participant_capacity': 40,
      }).toEntity();

      expect(pin.isAtCapacity, isTrue);
    });

    test('survives a minimal payload', () {
      final pin = MapEventPinModel.fromJson({
        'id': 'e1',
        'lat': 0,
        'lng': 0,
        'starts_at': '2026-08-11T16:00:00Z',
      }).toEntity();

      expect(pin.title, '');
      expect(pin.coverImageUrl, isNull);
      expect(pin.endsAt, isNull);
      expect(pin.maxParticipantCapacity, isNull);
      // An unknown status must never crash a list of pins.
      expect(pin.status, MapEventStatus.upcoming);
      expect(pin.isAtCapacity, isFalse);
    });
  });

  group('MapEventModel', () {
    Map<String, dynamic> payload({
      Map<String, dynamic>? viewer,
      Map<String, dynamic>? carMeet,
      List<dynamic>? rules,
      List<dynamic>? organizers,
    }) {
      return {
        'id': 'e1',
        'title': 'Sunday JDM Linkup',
        'description': 'Japanese metal only.',
        'category_id': 'car_meet',
        'category_label': 'Car meet',
        'location_name': 'Port Hercule — Level 2',
        'lat': 43.73,
        'lng': 7.42,
        'starts_at': '2026-08-16T07:00:00Z',
        'ends_at': null,
        'cover_image_url': null,
        'status': 'upcoming',
        'approval_status': 'accepted',
        'rejection_reason': null,
        'requires_participant_approval': true,
        'attendees_count': 112,
        'attending_cars_count': 21,
        'max_participant_capacity': null,
        'rules': rules ?? const [],
        'organizers': organizers ?? const [],
        'car_meet': carMeet,
        'viewer': viewer,
        'created_at': '2026-08-01T10:00:00Z',
      };
    }

    test('maps rules and organizers in the order the backend sent them', () {
      final event = MapEventModel.fromJson(
        payload(
          rules: [
            {'id': 'r1', 'rule': 'Park where the marshals point you.', 'sort_order': 0},
            {'id': 'r2', 'rule': 'No revving or burnouts.', 'sort_order': 1},
          ],
          organizers: [
            {
              'id': 'o1',
              'type': 'individual',
              'role': 'creator',
              'reference_id': 'u1',
              'name': 'Sasha Petrov',
              'username': 'torque_sasha',
              'image_url': null,
            },
            {
              'id': 'o2',
              'type': 'business',
              'role': 'organizer',
              'reference_id': 'b1',
              'name': 'Apex Detailing Studio',
              'username': null,
              'image_url': 'https://cdn/logo.webp',
            },
          ],
        ),
      ).toEntity();

      expect(event.rules.map((r) => r.rule), [
        'Park where the marshals point you.',
        'No revving or burnouts.',
      ]);
      expect(event.organizers.first.isCreator, isTrue);
      expect(event.creator?.name, 'Sasha Petrov');
      expect(event.organizers.last.isBusiness, isTrue);
      // reference_id is the user/business id; id is the organizer row itself.
      // Confusing the two sends a delete to the wrong endpoint.
      expect(event.organizers.last.id, 'o2');
      expect(event.organizers.last.referenceId, 'b1');
    });

    test('only an individual organizer links to a profile', () {
      final event = MapEventModel.fromJson(
        payload(
          organizers: [
            {
              'id': 'o1',
              'type': 'individual',
              'role': 'creator',
              'reference_id': 'u1',
              'name': 'Sasha Petrov',
              'username': 'torque_sasha',
              'image_url': null,
            },
            {
              'id': 'o2',
              'type': 'business',
              'role': 'organizer',
              'reference_id': 'b1',
              'name': 'Apex Detailing Studio',
              'username': null,
              'image_url': null,
            },
          ],
        ),
      ).toEntity();

      expect(event.organizers.first.username, 'torque_sasha');
      expect(event.organizers.first.hasProfile, isTrue);
      // A business has no handle, and `/users/:username` is the only profile
      // route there is — so its row must not offer to navigate.
      expect(event.organizers.last.username, isNull);
      expect(event.organizers.last.hasProfile, isFalse);
    });

    test('defaults the viewer to no permissions when absent', () {
      final event = MapEventModel.fromJson(payload()).toEntity();

      expect(event.viewer.canRsvp, isFalse);
      expect(event.viewer.canRegisterCars, isFalse);
      expect(event.viewer.isOrganizer, isFalse);
      expect(event.viewer.attendanceStatus, isNull);
      expect(event.viewer.myRegisteredCarIds, isEmpty);
    });

    test('maps the viewer object', () {
      final event = MapEventModel.fromJson(
        payload(
          viewer: {
            'is_creator': false,
            'is_organizer': false,
            'can_edit': false,
            'attendance_status': 'attending',
            'can_rsvp': true,
            'can_register_cars': true,
            'my_registered_car_ids': ['c1', 'c2'],
          },
        ),
      ).toEntity();

      expect(event.viewer.isAttending, isTrue);
      expect(event.viewer.myRegisteredCarIds, ['c1', 'c2']);
      expect(event.viewer.hasCarsRegistered, isTrue);
    });

    test('car_meet detail drives the registration deadline', () {
      final past = MapEventModel.fromJson(
        payload(carMeet: {'registration_deadline': '2020-01-01T00:00:00Z'}),
      ).toEntity();
      final future = MapEventModel.fromJson(
        payload(carMeet: {'registration_deadline': '2099-01-01T00:00:00Z'}),
      ).toEntity();

      expect(past.carMeet?.hasPassed, isTrue);
      expect(past.isRegistrationClosed, isTrue);
      expect(future.carMeet?.hasPassed, isFalse);
      expect(future.isRegistrationClosed, isFalse);
      // Nothing else has one.
      expect(MapEventModel.fromJson(payload()).toEntity().carMeet, isNull);
    });

    test('an unactionable event closes registration whatever the deadline', () {
      final json = payload(
        carMeet: {'registration_deadline': '2099-01-01T00:00:00Z'},
      )..['status'] = 'canceled';

      expect(MapEventModel.fromJson(json).toEntity().isRegistrationClosed, isTrue);
    });
  });

  group('MapEventParticipantModel', () {
    test('reuses the garage car shape and maps the status', () {
      final participant = MapEventParticipantModel.fromJson({
        'car': {
          'id': 'c1',
          'brand': 'Nissan',
          'model': 'Skyline R34 GT-R',
          'cover_image': {'key': 'cars/1.webp', 'url': 'https://cdn/1.webp'},
          'status': {'id': 's1', 'type': 'Daily'},
          'owner': {'id': 'u1', 'username': 'jdm_jules'},
        },
        'status': 'withdrawn',
        'registered_at': '2026-08-10T09:00:00Z',
        'rejection_reason': null,
      }).toEntity();

      expect(participant.car.brand, 'Nissan');
      expect(participant.car.ownerUsername, 'jdm_jules');
      expect(participant.car.coverImage?.url, 'https://cdn/1.webp');
      expect(participant.isWithdrawn, isTrue);
      expect(participant.isAccepted, isFalse);
      // Only a rejected row carries one.
      expect(participant.rejectionReason, isNull);
    });

    test('carries the organizer reason on a rejected row', () {
      final participant = MapEventParticipantModel.fromJson({
        'car': {'id': 'c1', 'brand': 'Mazda', 'model': 'RX-7 FD'},
        'status': 'rejected',
        'registered_at': '2026-08-10T09:00:00Z',
        'rejection_reason': "Wrong category for a JDM-only meet.",
      }).toEntity();

      expect(participant.isRejected, isTrue);
      expect(
        participant.rejectionReason,
        "Wrong category for a JDM-only meet.",
      );
    });
  });

  group('OrganizerCandidateModel', () {
    test('carries a handle for people and none for businesses', () {
      final person = OrganizerCandidateModel.fromJson({
        'type': 'individual',
        'reference_id': 'u1',
        'name': 'Marius Popescu',
        'username': 'marius_dev',
        'image_url': null,
      }).toEntity();

      final business = OrganizerCandidateModel.fromJson({
        'type': 'business',
        'reference_id': 'b1',
        'name': 'Apex Detailing Studio',
        'username': null,
        'image_url': 'https://cdn/logo.webp',
      }).toEntity();

      expect(person.username, 'marius_dev');
      expect(person.isBusiness, isFalse);
      expect(business.username, isNull);
      expect(business.isBusiness, isTrue);
    });
  });

  group('MapEventPageModel', () {
    test('maps items and carries the cursor opaquely', () {
      final page = MapEventPageModel.fromJson({
        'items': [
          {
            'profile': {
              'id': 'u1',
              'username': 'sasha',
              'name': 'Sasha Petrov',
              'avatar_url': null,
            },
            'status': 'attending',
          },
        ],
        'next_cursor': 'opaque-cursor',
      }, MapEventAttendeeModel.fromJson).toEntity((m) => m.toEntity());

      expect(page.items.single.username, 'sasha');
      expect(page.items.single.name, 'Sasha Petrov');
      expect(page.items.single.status, MapEventAttendance.attending);
      expect(page.nextCursor, 'opaque-cursor');
      expect(page.hasMore, isTrue);
    });

    test('an attendee without a display name falls back to the handle', () {
      final page = MapEventPageModel.fromJson({
        'items': [
          {
            'profile': {'id': 'u1', 'username': 'sasha'},
            'status': 'interested',
          },
        ],
        'next_cursor': null,
      }, MapEventAttendeeModel.fromJson).toEntity((m) => m.toEntity());

      expect(page.items.single.name, isNull);
      expect(page.items.single.username, 'sasha');
    });

    test('a null cursor is the only end-of-list signal', () {
      final page = MapEventPageModel.fromJson(
        {'items': const [], 'next_cursor': null},
        MapEventAttendeeModel.fromJson,
      ).toEntity((m) => m.toEntity());

      expect(page.hasMore, isFalse);
    });
  });

  group('enums', () {
    test('fall back rather than throw on an unknown value', () {
      expect(MapEventStatus.fromApi('something_new'), MapEventStatus.upcoming);
      expect(MapEventApproval.fromApi(null), MapEventApproval.pending);
      expect(MapEventAttendance.fromApi('going'), isNull);
      expect(
        MapEventParticipation.fromApi('??'),
        MapEventParticipation.pending,
      );
      expect(
        MapEventOrganizerType.fromApi(null),
        MapEventOrganizerType.individual,
      );
    });

    test('only pending and rejected events are editable', () {
      expect(MapEventApproval.pending.isEditable, isTrue);
      expect(MapEventApproval.rejected.isEditable, isTrue);
      expect(MapEventApproval.accepted.isEditable, isFalse);
    });

    test('only upcoming and live events are actionable', () {
      expect(MapEventStatus.upcoming.isActionable, isTrue);
      expect(MapEventStatus.live.isActionable, isTrue);
      expect(MapEventStatus.previous.isActionable, isFalse);
      expect(MapEventStatus.canceled.isActionable, isFalse);
      expect(MapEventStatus.hidden.isActionable, isFalse);
    });
  });

  group('instant parsing', () {
    test('converts UTC to local', () {
      final parsed = parseInstant('2026-08-11T16:00:00Z');
      expect(parsed.isUtc, isFalse);
      expect(
        parsed.toUtc(),
        DateTime.utc(2026, 8, 11, 16),
      );
    });

    test('round-trips back to UTC on the way out', () {
      const wire = '2026-08-11T16:00:00Z';
      expect(
        DateTime.parse(formatInstant(parseInstant(wire))).toUtc(),
        DateTime.parse(wire).toUtc(),
      );
    });

    test('a missing or malformed required instant does not throw', () {
      expect(parseInstant(null).millisecondsSinceEpoch, 0);
      expect(parseInstant('not a date').millisecondsSinceEpoch, 0);
      expect(parseNullableInstant(''), isNull);
      expect(parseNullableString(''), isNull);
    });
  });
}
