import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum SocialProvider { google, apple }

/// A row of rounded social provider buttons (just the logo, no label), shown
/// under the divider on the auth pages. The [order] of the providers can differ
/// between login and sign up to match the design.
class SocialLoginButtons extends StatelessWidget {
  final List<SocialProvider> order;
  final ValueChanged<SocialProvider> onTap;

  const SocialLoginButtons({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < order.length; i++) ...[
          if (i > 0) const SizedBox(width: 20),
          _SocialButton(
            provider: order[i],
            onTap: () => onTap(order[i]),
          ),
        ],
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  static const double _size = 56;

  final SocialProvider provider;
  final VoidCallback onTap;

  const _SocialButton({required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: _size,
          height: _size,
          child: Center(child: _logo()),
        ),
      ),
    );
  }

  Widget _logo() => switch (provider) {
    SocialProvider.google =>
      SvgPicture.asset('assets/logos/google_logo_button_light.svg', height: _size),
    SocialProvider.apple =>
      Image.asset('assets/logos/apple_logo_button_light@3x.png', height: _size),
  };
}
