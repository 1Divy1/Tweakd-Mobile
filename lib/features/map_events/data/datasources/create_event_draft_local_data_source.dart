import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

/// The create-event wizard's saved draft, as one JSON file in the app's
/// documents directory.
///
/// This is deliberately not wired through an entity / repository / use case
/// chain: what it stores is *form state* — half-typed fields, a step index, a
/// picked file path — not domain data, and it never leaves the device. It is
/// injected straight into `CreateMapEventBloc` the way `ImageService` already
/// is, for the same reason.
///
/// A file rather than Hive: `hive` is declared in `pubspec.yaml` but never
/// initialised anywhere in `lib/`, and adopting it for one object would mean an
/// adapter plus a `main.dart` init. `path_provider` is already a dependency.
///
/// Every method swallows its own IO errors. A draft is a convenience; losing
/// one must never be the reason the wizard fails to open.
@lazySingleton
class CreateEventDraftLocalDataSource {
  static const _fileName = 'create_map_event_draft.json';

  /// Bumped when the shape changes, so an old draft is dropped rather than
  /// half-parsed into a form the user then submits.
  static const currentVersion = 1;

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<Map<String, dynamic>?> read() async {
    try {
      final file = await _file();
      if (!await file.exists()) return null;

      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) return null;
      if (decoded['version'] != currentVersion) {
        await clear();
        return null;
      }
      return decoded;
    } catch (e) {
      debugPrint('Failed to read the event draft: $e');
      return null;
    }
  }

  Future<void> write(Map<String, dynamic> draft) async {
    try {
      final file = await _file();
      await file.writeAsString(
        jsonEncode({...draft, 'version': currentVersion}),
        flush: true,
      );
    } catch (e) {
      debugPrint('Failed to save the event draft: $e');
    }
  }

  Future<void> clear() async {
    try {
      final file = await _file();
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint('Failed to clear the event draft: $e');
    }
  }
}
