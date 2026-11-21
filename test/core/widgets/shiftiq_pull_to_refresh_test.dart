import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_pull_to_refresh.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_skeleton.dart';

void main() {
  group('ShiftIQPullToRefresh', () {
    testWidgets('shows skeleton instead of spinner while refreshing',
        (tester) async {
      final completer = Completer<void>();
      var refreshCalls = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShiftIQPullToRefresh(
              skeleton: const ShiftIQSkeletonCardList(itemCount: 2),
              onRefresh: () {
                refreshCalls++;
                return completer.future;
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120, child: Text('Item 1')),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.drag(find.byType(ListView), const Offset(0, 180));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(refreshCalls, 1);
      expect(find.byType(ShiftIQSkeletonCardList), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      completer.complete();
      await tester.pumpAndSettle();

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.byType(ShiftIQSkeletonCardList), findsNothing);
    });
  });
}
