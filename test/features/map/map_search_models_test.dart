import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/features/map/data/models/business_search_page_model.dart';
import 'package:tweakd/features/map_events/data/models/map_event_list_models.dart';
import 'package:tweakd/features/map_events/data/models/map_event_pin_model.dart';
import 'package:tweakd/features/map_events/domain/entities/map_event_enums.dart';

/// The wire shapes of `GET /businesses/search` and `GET /map-events/search`,
/// exactly as the Spring controllers' web tests pin them.
void main() {
  test('a business search page parses its pins and cursor', () {
    final page = BusinessSearchPageModel.fromJson({
      'items': [
        {
          'id': 'b1',
          'name': 'Willy Wash',
          'type_id': 'car_wash',
          'type_label': 'Car wash',
          'lat': 46.7874,
          'lng': 23.6308,
          'logo_url': null,
          'average_rating': 4.5,
          'review_count': 12,
          'is_open_now': true,
        },
      ],
      'next_cursor': 'abc',
    }).toEntity();

    expect(page.items.single.name, 'Willy Wash');
    expect(page.items.single.typeLabel, 'Car wash');
    expect(page.items.single.isOpenNow, isTrue);
    expect(page.hasMore, isTrue);
  });

  test('a null or missing cursor means the last page', () {
    expect(
      BusinessSearchPageModel.fromJson({'items': [], 'next_cursor': null})
          .toEntity()
          .hasMore,
      isFalse,
    );
    expect(BusinessSearchPageModel.fromJson({}).toEntity().items, isEmpty);
  });

  test('an event search page carries the derived phase, including past', () {
    final page = MapEventPageModel.fromJson(
      {
        'items': [
          {
            'id': 'e1',
            'title': 'Sunday meet',
            'category_id': 'car_meet',
            'category_label': 'Car meet',
            'lat': 46.77,
            'lng': 23.62,
            'location_name': 'Iulius Mall parking',
            'cover_image_url': null,
            'starts_at': '2026-08-01T09:00:00Z',
            'ends_at': '2026-08-01T13:00:00Z',
            'status': 'previous',
            'attendees_count': 42,
            'attending_cars_count': 7,
            'max_participant_capacity': null,
          },
        ],
        'next_cursor': null,
      },
      MapEventPinModel.fromJson,
    ).toEntity((p) => p.toEntity());

    expect(page.items.single.status, MapEventStatus.previous);
    expect(page.items.single.locationName, 'Iulius Mall parking');
    expect(page.hasMore, isFalse);
  });
}
