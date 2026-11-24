import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/widgets/shiftiq_profile_avatar_button.dart';

void main() {
  tearDown(() {
    ShiftIQProfileAvatarStore.clear();
  });

  testWidgets(
    'ShiftIQProfileAvatarButton shows person icon when no image and switches to Image.network when photo URL is set',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: ShiftIQProfileAvatarButton(tooltip: 'Mi perfil'),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
      expect(find.byType(Image), findsNothing);

      ShiftIQProfileAvatarStore.setImageUrl(
        'https://res.cloudinary.com/demo/image/upload/v1/customers/avatar.jpg',
      );
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsNothing);
    },
  );
}
