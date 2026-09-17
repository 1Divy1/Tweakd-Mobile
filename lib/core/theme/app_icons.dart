import 'package:flutter/material.dart';

/// App-specific glyph choices that appear in more than one place, so a glyph
/// can be swapped once instead of hunted down across features.
abstract final class AppIcons {
  /// Reposting: a two-arrow loop — content going round again. Material's glyph
  /// (Apache 2.0), not another app's.
  static const IconData repost = Icons.repeat_rounded;
}
