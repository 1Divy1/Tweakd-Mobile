import 'package:flutter/material.dart';

import '../../../../core/theme/tweakd_wordmark.dart';

/// The "Tweakd." brand mark shown at the top of both the login and sign up
/// pages.
class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: TweakdWordmark(height: 32));
  }
}
