import 'package:equatable/equatable.dart';

import 'business_hours_entity.dart';
import 'geo_position.dart';

/// The full business profile behind a map pin — `GET /businesses/{id}`.
///
/// Note [description] arrives as `""` rather than `null` when unset, so the UI
/// must test `isEmpty`, not nullness. [cityName] is what gets rendered;
/// [cityId] is the slug (`cluj-napoca`) and must never reach the screen.
class BusinessDetailEntity extends Equatable {
  final String id;
  final String name;
  final String typeId;
  final String typeLabel;
  final String description;
  final String logoUrl;

  final String address;
  final String cityId;
  final String cityName;
  final GeoPosition position;

  final String? phoneNumber;
  final String? email;

  /// Comes back without a scheme (`willywash.ro`), so `https://` has to be
  /// prepended before it can be opened.
  final String? websiteUrl;

  final double averageRating;
  final int reviewCount;
  final int followerCount;

  /// IANA zone the [hours] wall-clock strings belong to.
  final String timezone;
  final bool isOpenNow;
  final List<BusinessHoursEntity> hours;

  final DateTime? verifiedAt;
  final DateTime? createdAt;

  const BusinessDetailEntity({
    required this.id,
    required this.name,
    required this.typeId,
    required this.typeLabel,
    required this.description,
    required this.logoUrl,
    required this.address,
    required this.cityId,
    required this.cityName,
    required this.position,
    required this.phoneNumber,
    required this.email,
    required this.websiteUrl,
    required this.averageRating,
    required this.reviewCount,
    required this.followerCount,
    required this.timezone,
    required this.isOpenNow,
    required this.hours,
    required this.verifiedAt,
    required this.createdAt,
  });

  bool get isVerified => verifiedAt != null;

  bool get hasRating => reviewCount > 0;

  /// The schedule for [weekday] (ISO-8601, 1 = Monday), or `null` when the
  /// backend sent no row — which means closed.
  BusinessHoursEntity? hoursFor(int weekday) {
    for (final h in hours) {
      if (h.weekday == weekday) return h;
    }
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        typeId,
        typeLabel,
        description,
        logoUrl,
        address,
        cityId,
        cityName,
        position,
        phoneNumber,
        email,
        websiteUrl,
        averageRating,
        reviewCount,
        followerCount,
        timezone,
        isOpenNow,
        hours,
        verifiedAt,
        createdAt,
      ];
}
