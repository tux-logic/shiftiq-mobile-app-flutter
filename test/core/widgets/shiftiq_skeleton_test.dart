import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_skeleton.dart';

void main() {
  group('ShiftIQSkeleton widgets', () {
    testWidgets('renders skeleton card list without CircularProgressIndicator',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShiftIQSkeletonCardList(itemCount: 3, showKpiRow: true),
          ),
        ),
      );

      expect(find.byType(ShiftIQSkeletonShimmer), findsOneWidget);
      expect(find.byType(ShiftIQSkeletonBox), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('renders dashboard, branch, and detail skeletons cleanly',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(child: ShiftIQSkeletonDashboard()),
                Expanded(child: ShiftIQSkeletonBranchList()),
                Expanded(child: ShiftIQSkeletonDetail()),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(ShiftIQSkeletonShimmer), findsNWidgets(3));
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
