import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/features/posts/data/models/post_models.dart';

Map<String, dynamic> _post({Object? repostedBy, bool? viewerHasReposted}) => {
  'id': 'p1',
  'description': 'Fresh coilovers',
  'author': {'id': 'a1', 'username': 'author'},
  'images': <dynamic>[],
  'tagged_people': <dynamic>[],
  'tagged_cars': <dynamic>[],
  'likes_count': 4,
  'comments_count': 1,
  'shares_count': 3,
  'saved_count': 0,
  'created_at': '2026-09-14T10:00:00Z',
  'viewer_has_reposted': ?viewerHasReposted,
  'reposted_by': ?repostedBy,
};

Map<String, dynamic> _user(String id) => {'id': id, 'username': 'user_$id'};

void main() {
  test('a post without repost fields is not reposted and names nobody', () {
    final post = PostModel.fromJson(_post()).toEntity();

    expect(post.viewerHasReposted, isFalse);
    expect(post.repostedBy, isNull);
    expect(post.sharesCount, 3);
  });

  test('parses the viewer flag and the followed reposters', () {
    final post = PostModel.fromJson(
      _post(
        viewerHasReposted: true,
        repostedBy: {
          'users': [_user('f1'), _user('f2')],
          'total_count': 5,
        },
      ),
    ).toEntity();

    expect(post.viewerHasReposted, isTrue);
    expect(post.repostedBy!.users.map((u) => u.id), ['f1', 'f2']);
    expect(post.repostedBy!.totalCount, 5);
  });

  test('a reposted_by that names nobody is dropped', () {
    final post = PostModel.fromJson(
      _post(repostedBy: {'users': <dynamic>[], 'total_count': 2}),
    ).toEntity();

    expect(post.repostedBy, isNull);
  });

  test('the total never reads lower than the reposters it lists', () {
    final post = PostModel.fromJson(
      _post(repostedBy: {'users': [_user('f1'), _user('f2')]}),
    ).toEntity();

    expect(post.repostedBy!.totalCount, 2);
  });
}
