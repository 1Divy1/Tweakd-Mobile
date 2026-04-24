import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bloc.dart';
import '../bloc/event.dart';

class SocialButtonSignin extends StatelessWidget {
  final Widget svgLogo;
  final String socialApp;

  const SocialButtonSignin({
    super.key,
    required this.svgLogo,
    required this.socialApp,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        shadowColor: Colors.transparent,
      ),
      onPressed: () => context.read<AuthBloc>().add(
            switch (socialApp) {
              'Google' => GoogleLoginRequested(),
              'Apple' => AppleLoginRequested(),
              _ => throw UnimplementedError(),
            },
          ),
      child: svgLogo,
    );
  }
}
