import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_page_header.dart';

void main() {
  testWidgets(
    'ShiftIQCollapsibleHeaderBody hides header on scroll down and shows on scroll up',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShiftIQCollapsibleHeaderBody(
              header: const ShiftIQPageHeader(title: 'Test Header'),
              body: ListView.builder(
                itemCount: 40,
                itemBuilder: (_, i) => SizedBox(
                  height: 60,
                  child: Text('Item $i'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      AnimatedAlign alignFinder() =>
          tester.widget<AnimatedAlign>(find.byType(AnimatedAlign));

      expect(alignFinder().heightFactor, 1.0);

      // Scroll down
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(alignFinder().heightFactor, 0.0);

      // Scroll up
      await tester.drag(find.byType(ListView), const Offset(0, 180));
      await tester.pumpAndSettle();
      expect(alignFinder().heightFactor, 1.0);
    },
  );
}
