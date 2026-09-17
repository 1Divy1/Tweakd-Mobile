import 'package:flutter/material.dart';

import '../../../../../core/shared/widgets/app_avatar.dart';

/// Small circular avatar with an initial-letter fallback. [username] null
/// (deleted author) renders a neutral placeholder.
class ForumAvatar extends StatelessWidget {
  final String? username;
  final String? avatarUrl;
  final double size;

  const ForumAvatar({
    super.key,
    this.username,
    this.avatarUrl,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return AppAvatar(size: size, url: avatarUrl, name: username);
  }
}
