import '../../domain/entities/business_hours_entity.dart';

/// One `hours[]` row of `GET /businesses/{id}`.
class BusinessHoursModel {
  final int weekday;
  final bool isClosed;
  final String? openingHour;
  final String? closingHour;
  final String? notes;

  const BusinessHoursModel({
    required this.weekday,
    required this.isClosed,
    this.openingHour,
    this.closingHour,
    this.notes,
  });

  factory BusinessHoursModel.fromJson(Map<String, dynamic> json) {
    return BusinessHoursModel(
      weekday: (json['weekday'] as num).toInt(),
      isClosed: json['is_closed'] as bool? ?? false,
      openingHour: json['opening_hour'] as String?,
      closingHour: json['closing_hour'] as String?,
      notes: json['notes'] as String?,
    );
  }

  BusinessHoursEntity toEntity() {
    return BusinessHoursEntity(
      weekday: weekday,
      isClosed: isClosed,
      openingHour: openingHour,
      closingHour: closingHour,
      notes: notes,
    );
  }
}
