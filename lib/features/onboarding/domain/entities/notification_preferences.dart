import 'package:equatable/equatable.dart';

class NotificationPreferences extends Equatable {
  final bool likesEnabled;
  final bool commentsEnabled;
  final bool sharesEnabled;
  final bool dmsEnabled;
  final bool flashMeetsEnabled;
  final bool organizedEventsEnabled;
  final bool priceDropsEnabled;

  const NotificationPreferences({
    required this.likesEnabled,
    required this.commentsEnabled,
    required this.sharesEnabled,
    required this.dmsEnabled,
    required this.flashMeetsEnabled,
    required this.organizedEventsEnabled,
    required this.priceDropsEnabled,
  });

  /// Sensible opt-in defaults shown when the Notifications step first opens.
  factory NotificationPreferences.defaults() => const NotificationPreferences(
        likesEnabled: true,
        commentsEnabled: true,
        sharesEnabled: true,
        dmsEnabled: true,
        flashMeetsEnabled: true,
        organizedEventsEnabled: true,
        priceDropsEnabled: true,
      );

  NotificationPreferences copyWith({
    bool? likesEnabled,
    bool? commentsEnabled,
    bool? sharesEnabled,
    bool? dmsEnabled,
    bool? flashMeetsEnabled,
    bool? organizedEventsEnabled,
    bool? priceDropsEnabled,
  }) {
    return NotificationPreferences(
      likesEnabled: likesEnabled ?? this.likesEnabled,
      commentsEnabled: commentsEnabled ?? this.commentsEnabled,
      sharesEnabled: sharesEnabled ?? this.sharesEnabled,
      dmsEnabled: dmsEnabled ?? this.dmsEnabled,
      flashMeetsEnabled: flashMeetsEnabled ?? this.flashMeetsEnabled,
      organizedEventsEnabled:
          organizedEventsEnabled ?? this.organizedEventsEnabled,
      priceDropsEnabled: priceDropsEnabled ?? this.priceDropsEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'likes_enabled': likesEnabled,
        'comments_enabled': commentsEnabled,
        'shares_enabled': sharesEnabled,
        'dms_enabled': dmsEnabled,
        'flash_meets_enabled': flashMeetsEnabled,
        'organized_events_enabled': organizedEventsEnabled,
        'price_drops_enabled': priceDropsEnabled,
      };

  @override
  List<Object?> get props => [
        likesEnabled,
        commentsEnabled,
        sharesEnabled,
        dmsEnabled,
        flashMeetsEnabled,
        organizedEventsEnabled,
        priceDropsEnabled,
      ];
}
