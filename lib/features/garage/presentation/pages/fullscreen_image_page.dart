import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/app_pill_button.dart';
import '../widgets/car_image.dart';

class FullscreenImagePage extends StatelessWidget {
  final String url;

  const FullscreenImagePage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(6),
          child: AppPillButton(
            icon: Icons.chevron_left_rounded,
            onTap: () => context.pop(),
          ),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: CarImage(
            imageUrl: url,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
