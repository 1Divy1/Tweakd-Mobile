import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/core/error/base_exceptions.dart';
import 'package:tweakd/core/network/dio_http_client.dart';
import 'package:tweakd/core/network/rate_limit_interceptor.dart';
import 'package:tweakd/core/network/rate_limit_notifier.dart';

/// A 429 from the backend's limiter must reach the data layer as a typed
/// [TooManyRequestsException] (still an [ApiException], so existing repository
/// handlers keep working), be reported to the app-wide notifier exactly once,
/// and never be retried.
void main() {
  late _StubAdapter adapter;
  late RateLimitNotifier notifier;
  late List<RateLimitNotice> notices;
  late DioHttpClient client;

  setUp(() {
    adapter = _StubAdapter();
    notifier = RateLimitNotifier.withClock(() => DateTime.utc(2026, 9, 16));
    notices = [];
    notifier.notices.listen(notices.add);
    final dio = Dio(BaseOptions(baseUrl: 'http://api.test/api/v1'))
      ..httpClientAdapter = adapter
      ..interceptors.add(RateLimitInterceptor(notifier));
    client = DioHttpClient(dio);
  });

  /// The exact body `RateLimitInterceptor.reject` writes on the backend.
  Map<String, dynamic> backendBody({
    int seconds = 7,
    String limit = 'comments',
  }) => {
    'status': 429,
    'message': 'Too many requests. Try again in ${seconds}s.',
    'path': null,
    'timestamp': '2026-09-16T12:00:00Z',
    'error': 'rate_limited',
    'details': {'limit': limit, 'retry_after_seconds': seconds},
  };

  test(
    'maps a 429 to TooManyRequestsException with the Retry-After wait',
    () async {
      adapter.respond(429, backendBody(seconds: 99), retryAfter: '7');

      final error = await client
          .post('/posts/1/comments', body: {'content': 'hi'})
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(error, isA<TooManyRequestsException>());
      expect(error, isA<ApiException>());
      final tooMany = error! as TooManyRequestsException;
      expect(tooMany.statusCode, 429);
      expect(tooMany.retryAfter, const Duration(seconds: 7));
      expect(tooMany.limit, 'comments');
      expect(tooMany.errorCode, 'rate_limited');

      await Future<void>.delayed(Duration.zero);
      expect(notices, [
        const RateLimitNotice(retryAfter: Duration(seconds: 7)),
      ]);
      expect(adapter.calls, 1, reason: 'a 429 must not be retried');
    },
  );

  test(
    'falls back to details.retry_after_seconds without the header',
    () async {
      adapter.respond(429, backendBody(seconds: 120, limit: 'posts.create'));

      final error = await client
          .post('/posts')
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(
        (error! as TooManyRequestsException).retryAfter,
        const Duration(minutes: 2),
      );
    },
  );

  test('a 429 with no usable wait still maps and reports', () async {
    adapter.respond(429, 'Too Many Requests', contentType: 'text/plain');

    final error = await client
        .get('/feed/global')
        .then<Object?>((_) => null, onError: (Object e) => e);

    expect((error! as TooManyRequestsException).retryAfter, isNull);
    await Future<void>.delayed(Duration.zero);
    expect(notices, [const RateLimitNotice()]);
  });

  test('other errors are not reported as rate limits', () async {
    adapter.respond(404, {'error': 'not_found', 'message': 'Nope'});

    final error = await client
        .get('/posts/1')
        .then<Object?>((_) => null, onError: (Object e) => e);

    expect(error, isNot(isA<TooManyRequestsException>()));
    expect((error! as ApiException).statusCode, 404);
    await Future<void>.delayed(Duration.zero);
    expect(notices, isEmpty);
  });
}

class _StubAdapter implements HttpClientAdapter {
  int calls = 0;
  late int _status;
  late Object _body;
  String? _retryAfter;
  String _contentType = 'application/json';

  void respond(
    int status,
    Object body, {
    String? retryAfter,
    String contentType = 'application/json',
  }) {
    _status = status;
    _body = body;
    _retryAfter = retryAfter;
    _contentType = contentType;
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    final text = _body is String ? _body as String : jsonEncode(_body);
    return ResponseBody.fromString(
      text,
      _status,
      headers: {
        Headers.contentTypeHeader: [_contentType],
        if (_retryAfter != null) 'retry-after': [_retryAfter!],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
