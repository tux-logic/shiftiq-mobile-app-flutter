import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_skeleton.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_skeleton_dummies.dart';

void main() {
  group('ShiftIQSkeletonizer', () {
    testWidgets('wraps real widgets without spinners', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShiftIQSkeletonizer(
              enabled: true,
              child: ShiftIQSkeletonDetail(),
            ),
          ),
        ),
      );

      expect(find.byType(ShiftIQSkeletonizer), findsNWidgets(2));
      expect(find.byType(ShiftIQSkeletonDetail), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    test('provides valid dummy collections for all modules', () {
      expect(ShiftIQSkeletonDummies.workOrders(), isNotEmpty);
      expect(ShiftIQSkeletonDummies.appointments(), isNotEmpty);
      expect(ShiftIQSkeletonDummies.customers(), isNotEmpty);
      expect(ShiftIQSkeletonDummies.products(), isNotEmpty);
      expect(ShiftIQSkeletonDummies.dtcAlerts(), isNotEmpty);
      expect(ShiftIQSkeletonDummies.vouchers(), isNotEmpty);
      expect(ShiftIQSkeletonDummies.quotes(), isNotEmpty);
      expect(ShiftIQSkeletonDummies.branches(), isNotEmpty);
    });
  });
}
