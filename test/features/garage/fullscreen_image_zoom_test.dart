import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/features/garage/presentation/pages/fullscreen_image_page.dart';
import 'package:tweakd/features/garage/presentation/widgets/car_image.dart';

/// Zooming a letterboxed photo has to grow it over the black bars.
///
/// The failure this pins is silent on a square image: when the zoom child is
/// sized to the `BoxFit.contain` picture instead of the screen, the viewer
/// clips to that box, so pinching magnifies the photo inside its own letterbox
/// and the bars sit there forever.
void main() {
  const Size phone = Size(390, 844);

  group('zoom surface', () {
    testWidgets('is sized to the screen, not to the contained image', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FullscreenImagePage(images: ['https://example.com/car.jpg']),
        ),
      );
      await tester.pump();

      final Size screen = tester.getSize(find.byType(Scaffold));
      expect(tester.getSize(find.byType(InteractiveViewer)), screen);

      // The child is pinned to the viewport too — the letterbox has to live
      // inside the zoomed subtree, not around it.
      final CarImage image = tester.widget(find.byType(CarImage));
      expect(image.width, screen.width);
      expect(image.height, screen.height);
      expect(image.fit, BoxFit.contain);
    });
  });

  group('letterboxInsets', () {
    test('measures the bars above and below a wide photo', () {
      // 16:9 in a tall phone: bars top and bottom, none at the sides.
      final EdgeInsets insets = letterboxInsets(phone, 16 / 9);
      expect(insets.left, 0);
      expect(insets.top, closeTo((844 - 390 * 9 / 16) / 2, 0.01));
      expect(insets.top, insets.bottom);
    });

    test('measures the bars beside a tall photo', () {
      // Taller than the 390x844 screen itself: bars left and right.
      const double aspect = 9 / 24;
      final EdgeInsets insets = letterboxInsets(phone, aspect);
      expect(insets.top, 0);
      expect(insets.left, closeTo((390 - 844 * aspect) / 2, 0.01));
      expect(insets.left, insets.right);
    });

    test('is zero before the aspect ratio is known', () {
      expect(letterboxInsets(phone, null), EdgeInsets.zero);
      expect(letterboxInsets(Size.zero, 16 / 9), EdgeInsets.zero);
    });
  });

  group('fullscreenMaxScale', () {
    test('lets a wide photo be zoomed past the point the bars are gone', () {
      const double aspect = 16 / 9;
      // Scale at which BoxFit.contain becomes BoxFit.cover.
      final double fill = aspect / (390 / 844);
      expect(fullscreenMaxScale(phone, aspect), greaterThan(fill));
    });

    test('keeps the plain ceiling for a photo that already fills', () {
      expect(fullscreenMaxScale(phone, 390 / 844), 5);
      expect(fullscreenMaxScale(phone, null), 5);
    });

    test('caps an extreme panorama', () {
      expect(fullscreenMaxScale(phone, 10), lessThanOrEqualTo(12));
    });
  });
}
