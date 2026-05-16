import 'package:injectable/injectable.dart';

import '../../domain/usecases/resolve_image_url.dart';

/// Resolves canonical storage paths to short-lived signed download URLs and
/// caches the result per session. Backend signed URLs are valid for 6h; we
/// expire our cache entries a bit earlier to stay clear of the boundary.
/// Concurrent requests for the same path share one in-flight future.
@lazySingleton
class ImageUrlResolver {
  final ResolveImageUrlUseCase _resolveImageUrl;

  ImageUrlResolver(this._resolveImageUrl);

  static const _ttl = Duration(hours: 5);

  final Map<String, _CacheEntry> _cache = {};
  final Map<String, Future<String?>> _inFlight = {};

  /// Returns a signed URL for [storagePath], or null if resolution failed.
  Future<String?> resolve(String storagePath) {
    final cached = _cache[storagePath];
    if (cached != null && !cached.isExpired) {
      return Future.value(cached.url);
    }

    final pending = _inFlight[storagePath];
    if (pending != null) return pending;

    final future = _fetch(storagePath);
    _inFlight[storagePath] = future;
    return future;
  }

  Future<String?> _fetch(String storagePath) async {
    try {
      final result = await _resolveImageUrl(
        ResolveImageUrlParams(storagePath: storagePath),
      );
      return result.fold((_) => null, (url) {
        _cache[storagePath] = _CacheEntry(url, DateTime.now().add(_ttl));
        return url;
      });
    } finally {
      _inFlight.remove(storagePath);
    }
  }

  void invalidate(String storagePath) => _cache.remove(storagePath);
}

class _CacheEntry {
  final String url;
  final DateTime expiresAt;

  _CacheEntry(this.url, this.expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
