import 'package:equatable/equatable.dart';

class NotificationPreferences extends Equatable {
  final bool likesEnabled;
  final bool commentsEnabled;
  final bool sharesEnabled;
  final bool dmsEnabled;
  final bool flashMeetsEnabled;
  final bool organizedEventsEnabled;

  /// Reminders for scheduled services / expiring documents (service book) on
  /// the user's cars. No backend producer is wired up for this yet — the
  /// toggle ships ahead of that feature.
  final bool serviceRemindersEnabled;

  /// Tags on posts, forum threads and forum replies. Required by
  /// `PUT /profile/me/notifications` — the payload replaces every flag.
  final bool tagsEnabled;

  /// Someone enters a car in an event you organize, is added as
  /// co-organizer, or asks to withdraw from your event.
  final bool eventOrganizerEnabled;

  const NotificationPreferences({
    required this.likesEnabled,
    required this.commentsEnabled,
    required this.sharesEnabled,
    required this.dmsEnabled,
    required this.flashMeetsEnabled,
    required this.organizedEventsEnabled,
    required this.serviceRemindersEnabled,
    required this.tagsEnabled,
    required this.eventOrganizerEnabled,
  });

  /// Sensible opt-in defaults shown when the Notifications step first opens.
  factory NotificationPreferences.defaults() => const NotificationPreferences(
        likesEnabled: true,
        commentsEnabled: true,
        sharesEnabled: true,
        dmsEnabled: true,
        flashMeetsEnabled: true,
        organizedEventsEnabled: true,
        serviceRemindersEnabled: true,
        tagsEnabled: true,
        eventOrganizerEnabled: true,
      );

  /// Every topic off — the effective state while OS-level push permission
  /// isn't granted, since per-topic prefs are meaningless without it.
  factory NotificationPreferences.allDisabled() => const NotificationPreferences(
        likesEnabled: false,
        commentsEnabled: false,
        sharesEnabled: false,
        dmsEnabled: false,
        flashMeetsEnabled: false,
        organizedEventsEnabled: false,
        serviceRemindersEnabled: false,
        tagsEnabled: false,
        eventOrganizerEnabled: false,
      );

  NotificationPreferences copyWith({
    bool? likesEnabled,
    bool? commentsEnabled,
    bool? sharesEnabled,
    bool? dmsEnabled,
    bool? flashMeetsEnabled,
    bool? organizedEventsEnabled,
    bool? serviceRemindersEnabled,
    bool? tagsEnabled,
    bool? eventOrganizerEnabled,
  }) {
    return NotificationPreferences(
      likesEnabled: likesEnabled ?? this.likesEnabled,
      commentsEnabled: commentsEnabled ?? this.commentsEnabled,
      sharesEnabled: sharesEnabled ?? this.sharesEnabled,
      dmsEnabled: dmsEnabled ?? this.dmsEnabled,
      flashMeetsEnabled: flashMeetsEnabled ?? this.flashMeetsEnabled,
      organizedEventsEnabled:
          organizedEventsEnabled ?? this.organizedEventsEnabled,
      serviceRemindersEnabled:
          serviceRemindersEnabled ?? this.serviceRemindersEnabled,
      tagsEnabled: tagsEnabled ?? this.tagsEnabled,
      eventOrganizerEnabled:
          eventOrganizerEnabled ?? this.eventOrganizerEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'likes_enabled': likesEnabled,
        'comments_enabled': commentsEnabled,
        'shares_enabled': sharesEnabled,
        'dms_enabled': dmsEnabled,
        'flash_meets_enabled': flashMeetsEnabled,
        'organized_events_enabled': organizedEventsEnabled,
        'service_reminders_enabled': serviceRemindersEnabled,
        'tags_enabled': tagsEnabled,
        'event_organizer_enabled': eventOrganizerEnabled,
      };

  @override
  List<Object?> get props => [
        likesEnabled,
        commentsEnabled,
        sharesEnabled,
        dmsEnabled,
        flashMeetsEnabled,
        organizedEventsEnabled,
        serviceRemindersEnabled,
        tagsEnabled,
        eventOrganizerEnabled,
      ];
}
