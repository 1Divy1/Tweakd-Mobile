import '../../domain/entities/business_search_page.dart';
import 'business_pin_model.dart';

/// `GET /businesses/search` — `{ items: [pin, …], next_cursor }`. The items are
/// the same shape as `/businesses/nearby`, so they reuse [BusinessPinModel].
class BusinessSearchPageModel {
  final List<BusinessPinModel> items;
  final String? nextCursor;

  const BusinessSearchPageModel({required this.items, required this.nextCursor});

  factory BusinessSearchPageModel.fromJson(Map<String, dynamic> json) {
    final cursor = json['next_cursor'];
    return BusinessSearchPageModel(
      items: [
        for (final item in (json['items'] as List<dynamic>? ?? const []))
          BusinessPinModel.fromJson(item as Map<String, dynamic>),
      ],
      nextCursor: cursor is String && cursor.isNotEmpty ? cursor : null,
    );
  }

  BusinessSearchPageEntity toEntity() => BusinessSearchPageEntity(
        items: [for (final i in items) i.toEntity()],
        nextCursor: nextCursor,
      );
}
