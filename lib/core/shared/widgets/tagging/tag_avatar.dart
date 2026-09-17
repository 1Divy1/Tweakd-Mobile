import 'package:flutter/material.dart';

import 'package:tweakd/core/shared/widgets/app_avatar.dart';

/// Small circular avatar with an initial-letter fallback, used by the shared
/// tagging widgets. [username] null renders a neutral placeholder.
class TagAvatar extends StatelessWidget {
  final String? username;
  final String? avatarUrl;
  final double size;

  const TagAvatar({super.key, this.username, this.avatarUrl, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return AppAvatar(size: size, url: avatarUrl, name: username);
  }
}
