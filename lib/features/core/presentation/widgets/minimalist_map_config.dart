import 'package:maplibre_gl/maplibre_gl.dart';

/// Shared MapLibre + OpenFreeMap configuration for minimalist vector maps.
abstract final class MinimalistMapConfig {
  /// Bundled ShiftIQ-themed OpenFreeMap Positron vector style asset.
  static const String styleUrl = 'assets/map_styles/shiftiq_positron.json';

  /// Builds consistent vector pin circle options matching ShiftIQColors.
  static CircleOptions pinCircleOptions(
    LatLng point, {
    bool isSelected = false,
  }) {
    return CircleOptions(
      geometry: point,
      circleRadius: isSelected ? 9.0 : 6.5,
      circleColor: isSelected ? '#1E3A8A' : '#0F172A',
      circleStrokeColor: '#FFFFFF',
      circleStrokeWidth: 2.0,
      circleOpacity: 0.95,
    );
  }
}
