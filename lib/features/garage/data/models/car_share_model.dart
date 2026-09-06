import '../../domain/entities/car_share.dart';

/// `CarShareDto` — the owner's view of a car's share link.
class CarShareModel {
  final String code;
  final String url;
  final String qrUrl;
  final bool enabled;
  final DateTime? createdAt;
  final int viewCount;
  final int qrScanCount;
  final DateTime? lastViewedAt;

  const CarShareModel({
    required this.code,
    required this.url,
    required this.qrUrl,
    required this.enabled,
    this.createdAt,
    this.viewCount = 0,
    this.qrScanCount = 0,
    this.lastViewedAt,
  });

  factory CarShareModel.fromJson(Map<String, dynamic> json) {
    return CarShareModel(
      code: json['code'] as String,
      url: json['url'] as String,
      qrUrl: json['qr_url'] as String,
      enabled: json['enabled'] as bool? ?? true,
      createdAt: _parseDate(json['created_at']),
      // Counters are `bigint` server-side and arrive as num; the app only ever
      // renders them, so an int is plenty.
      viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
      qrScanCount: (json['qr_scan_count'] as num?)?.toInt() ?? 0,
      lastViewedAt: _parseDate(json['last_viewed_at']),
    );
  }

  CarShareEntity toEntity() => CarShareEntity(
    code: code,
    url: url,
    qrUrl: qrUrl,
    enabled: enabled,
    createdAt: createdAt,
    viewCount: viewCount,
    qrScanCount: qrScanCount,
    lastViewedAt: lastViewedAt,
  );

  static DateTime? _parseDate(dynamic value) =>
      value is String ? DateTime.tryParse(value)?.toLocal() : null;
}

/// `CarShareResolutionDto` — a share code turned into something the app can
/// navigate to.
class CarShareResolutionModel {
  final String carId;
  final String ownerUsername;

  const CarShareResolutionModel({
    required this.carId,
    required this.ownerUsername,
  });

  factory CarShareResolutionModel.fromJson(Map<String, dynamic> json) {
    return CarShareResolutionModel(
      carId: json['car_id'] as String,
      ownerUsername: json['owner_username'] as String? ?? '',
    );
  }

  CarShareResolutionEntity toEntity() =>
      CarShareResolutionEntity(carId: carId, ownerUsername: ownerUsername);
}
