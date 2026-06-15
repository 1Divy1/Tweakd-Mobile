import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        leading: IconButton(
          // TODO: create a custom reusable back button similar to iOS style
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
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
