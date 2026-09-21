// A post that shares a build-log modification. The card is derived by the
// backend on every read, so what matters on this side is that it survives the
// shapes the wire actually sends — including the ones that have lost the mod.
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/features/posts/data/models/post_models.dart';

Map<String, dynamic> _post({Object? modShareCard}) => {
  'id': 'p1',
  'description': '',
  'author': {'id': 'a1', 'username': 'author'},
  'images': <dynamic>[],
  'tagged_people': <dynamic>[],
  'tagged_cars': <dynamic>[],
  'likes_count': 0,
  'comments_count': 0,
  'shares_count': 0,
  'saved_count': 0,
  'created_at': '2026-09-21T10:00:00Z',
  'mod_share_card': ?modShareCard,
};

Map<String, dynamic> _card({
  Object? price,
  Object? priceCurrency,
  List<dynamic>? beforeMedia,
  List<dynamic>? afterMedia,
}) => {
  'modification_id': 'm1',
  'car': {'id': 'c1', 'brand': 'BMW', 'model': 'M3', 'year': 2023},
  'category_name': 'Suspension',
  'title': 'H&R Coilovers',
  'description': 'Dropped 30mm.',
  'before_media': beforeMedia ?? <dynamic>[],
  'after_media': afterMedia ?? <dynamic>[],
  'installation_date': '2026-04-01T10:00:00Z',
  'price': ?price,
  'price_currency': ?priceCurrency,
  'mileage_at_install': 9000,
};

Map<String, dynamic> _media(String key, String phase) => {
  'key': key,
  'url': 'https://media.tweakdapp.com/$key',
  'type': 'image',
  'phase': phase,
};

void main() {
  test('an ordinary post carries no mod card', () {
    final post = PostModel.fromJson(_post()).toEntity();

    expect(post.modShareCard, isNull);
  });

  test('parses the card a shared mod carries', () {
    final post = PostModel.fromJson(
      _post(
        modShareCard: _card(
          beforeMedia: [_media('before.jpg', 'before')],
          afterMedia: [_media('after.jpg', 'after')],
        ),
      ),
    ).toEntity();

    final card = post.modShareCard!;
    expect(card.modificationId, 'm1');
    expect(card.title, 'H&R Coilovers');
    expect(card.categoryName, 'Suspension');
    expect(card.car.brand, 'BMW');
    expect(card.beforeMedia.single.url, endsWith('before.jpg'));
    expect(card.afterMedia.single.url, endsWith('after.jpg'));
    expect(card.hasBeforeAndAfter, isTrue);
    // The result is what the card opens on.
    expect(card.displayMedia, card.afterMedia);
  });

  test('a price the owner kept private simply is not there', () {
    final post = PostModel.fromJson(
      _post(modShareCard: _card()),
    ).toEntity();

    // The backend withholds it rather than the app hiding it, so there is
    // nothing here to leak.
    expect(post.modShareCard!.price, isNull);
    expect(post.modShareCard!.priceCurrency, isNull);
  });

  test('a published price comes through with its currency', () {
    final post = PostModel.fromJson(
      _post(modShareCard: _card(price: 1200, priceCurrency: 'EUR')),
    ).toEntity();

    expect(post.modShareCard!.price, 1200);
    expect(post.modShareCard!.priceCurrency, 'EUR');
  });

  test('a mod photographed only beforehand still has something to show', () {
    final post = PostModel.fromJson(
      _post(
        modShareCard: _card(beforeMedia: [_media('before.jpg', 'before')]),
      ),
    ).toEntity();

    final card = post.modShareCard!;
    expect(card.hasBeforeAndAfter, isFalse);
    expect(card.displayMedia, card.beforeMedia);
  });

  test('a card that cannot be parsed leaves an ordinary post behind', () {
    // The post whose mod was deleted sends null; a malformed one must degrade
    // the same way rather than break the feed page it is on.
    for (final broken in <Object?>[
      null,
      'not an object',
      {'modification_id': 'm1'}, // no car, no date
      {'car': {'id': 'c1'}, 'modification_id': 'm1'}, // car missing brand
    ]) {
      final post = PostModel.fromJson(_post(modShareCard: broken)).toEntity();
      expect(post.modShareCard, isNull, reason: 'for $broken');
    }
  });
}
