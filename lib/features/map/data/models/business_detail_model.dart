import '../../domain/entities/business_detail_entity.dart';
import '../../domain/entities/geo_position.dart';
import 'business_hours_model.dart';

/// `GET /businesses/{id}`.
class BusinessDetailModel {
  final String id;
  final String name;
  final String typeId;
  final String typeLabel;
  final String description;
  final String logoUrl;
  final String address;
  final String cityId;
  final String cityName;
  final double lat;
  final double lng;
  final String? phoneNumber;
  final String? email;
  final String? websiteUrl;
  final double averageRating;
  final int reviewCount;
  final int followerCount;
  final String timezone;
  final bool isOpenNow;
  final List<BusinessHoursModel> hours;
  final DateTime? verifiedAt;
  final DateTime? createdAt;

  const BusinessDetailModel({
    required this.id,
    required this.name,
    required this.typeId,
    required this.typeLabel,
    required this.description,
    required this.logoUrl,
    required this.address,
    required this.cityId,
    required this.cityName,
    required this.lat,
    required this.lng,
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

  factory BusinessDetailModel.fromJson(Map<String, dynamic> json) {
    final rawHours = json['hours'] as List<dynamic>? ?? const [];
    return BusinessDetailModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      typeId: json['type_id'] as String? ?? '',
      typeLabel: json['type_label'] as String? ?? '',
      description: json['description'] as String? ?? '',
      logoUrl: json['logo_url'] as String? ?? '',
      address: json['address'] as String? ?? '',
      cityId: json['city_id'] as String? ?? '',
      cityName: json['city_name'] as String? ?? '',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      phoneNumber: json['phone_number'] as String?,
      email: json['email'] as String?,
      websiteUrl: json['website_url'] as String?,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      followerCount: (json['follower_count'] as num?)?.toInt() ?? 0,
      timezone: json['timezone'] as String? ?? '',
      isOpenNow: json['is_open_now'] as bool? ?? false,
      hours: [
        for (final h in rawHours)
          BusinessHoursModel.fromJson(h as Map<String, dynamic>),
      ],
      verifiedAt: _parseDate(json['verified_at']),
      createdAt: _parseDate(json['created_at']),
    );
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is! String || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  BusinessDetailEntity toEntity() {
    return BusinessDetailEntity(
      id: id,
      name: name,
      typeId: typeId,
      typeLabel: typeLabel,
      description: description,
      logoUrl: logoUrl,
      address: address,
      cityId: cityId,
      cityName: cityName,
      position: GeoPosition(lat: lat, lng: lng),
      phoneNumber: phoneNumber,
      email: email,
      websiteUrl: websiteUrl,
      averageRating: averageRating,
      reviewCount: reviewCount,
      followerCount: followerCount,
      timezone: timezone,
      isOpenNow: isOpenNow,
      hours: [for (final h in hours) h.toEntity()],
      verifiedAt: verifiedAt,
      createdAt: createdAt,
    );
  }
}
