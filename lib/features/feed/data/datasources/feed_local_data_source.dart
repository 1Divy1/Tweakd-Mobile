import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The last first page of the global feed, kept on disk so a cold start can
/// paint real posts instantly and refresh them in place.
///
/// Stores the response body exactly as the backend sent it (minus
/// `pending_badge_celebrations`, which are one-shot and must never replay from
/// disk) and parses it with the same `FeedPageModel` as a live response. That
/// keeps the cache in lockstep with the wire format: there is no second,
/// hand-written serialisation of a post to drift out of date.
///
/// Deliberately no expiry. An old feed shown for a second or two while the
/// fresh one loads beats making the user stare at a skeleton.
///
/// Scoped to the user it was fetched for, so a different account on the same
/// device never sees it, and removed on sign-out. Every method swallows its
/// own IO errors: the cache is a head start, never a reason the feed fails.
@lazySingleton
class FeedLocalDataSource {
  static const _fileName = 'feed_first_page.json';

  /// Bumped when the stored envelope changes, so an old file is ignored
  /// rather than half-parsed.
  static const _version = 1;

  final SupabaseClient supabaseClient;

  FeedLocalDataSource(this.supabaseClient);

  Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_fileName');
  }

  /// The saved first page for the signed-in user, or null when there is none.
  Future<Map<String, dynamic>?> read() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) return null;

      final file = await _file();
      if (!await file.exists()) return null;

      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, dynamic> ||
          decoded['version'] != _version ||
          decoded['user_id'] != userId) {
        return null;
      }
      return decoded['page'] as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Failed to read the cached feed: ${e.runtimeType}');
      return null;
    }
  }

  /// Replaces the saved first page with [page], a raw `GET /feed/global`
  /// response body.
  Future<void> write(Map<String, dynamic> page) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) return;

      final file = await _file();
      // Written aside and renamed over the real file, so a kill mid-write
      // leaves the previous page rather than a truncated one.
      final tmp = File('${file.path}.tmp');
      await tmp.writeAsString(
        jsonEncode({
          'version': _version,
          'user_id': userId,
          'page': {...page}..remove('pending_badge_celebrations'),
        }),
        flush: true,
      );
      await tmp.rename(file.path);
    } catch (e) {
      debugPrint('Failed to save the feed cache: ${e.runtimeType}');
    }
  }

  Future<void> clear() async {
    try {
      final file = await _file();
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint('Failed to clear the feed cache: ${e.runtimeType}');
    }
  }
}
