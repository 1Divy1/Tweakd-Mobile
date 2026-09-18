import 'package:flutter/material.dart';

/// The Mapbox Standard style's `lightPreset` that matches the app theme.
///
/// Follows the app's light/dark setting rather than the clock, so a dark app
/// never opens onto a bright daytime map (or a light app onto a night one).
String mapLightPresetFor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? 'night' : 'day';
