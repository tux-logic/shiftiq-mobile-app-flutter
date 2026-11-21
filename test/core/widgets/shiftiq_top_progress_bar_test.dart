import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_top_progress_bar.dart';

void main() {
  group('ShiftIQTopProgressBar', () {
    testWidgets('fades in when isLoading is true and out when false',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShiftIQTopProgressBar(isLoading: true),
          ),
        ),
      );

      final visibleOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(visibleOpacity.opacity, 1.0);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShiftIQTopProgressBar(isLoading: false),
          ),
        ),
      );
      await tester.pump();

      final hiddenOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(hiddenOpacity.opacity, 0.0);
    });
  });
}
