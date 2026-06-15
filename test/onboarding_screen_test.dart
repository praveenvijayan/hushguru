import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hashguru/screens/onboarding_screen.dart';
import 'package:hashguru/widgets/hg_button.dart';

void main() {
  Widget buildScreen({Future<void> Function()? signOut}) => MaterialApp(
    home: OnboardingScreen(
      uid: 'test-uid',
      email: 'test@example.com',
      signOut: signOut,
    ),
  );

  Finder escapeLink() => find.byWidgetPredicate(
    (w) =>
        w is RichText &&
        w.text.toPlainText().contains('Already have an account?'),
  );

  group('OnboardingScreen escape link visibility', () {
    testWidgets('visible on step 0', (tester) async {
      await tester.pumpWidget(buildScreen());
      expect(escapeLink(), findsOneWidget);
    });

    testWidgets('visible on step 1', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.enterText(find.byType(TextField), 'Test User');
      await tester.tap(find.byType(HgButton));
      await tester.pumpAndSettle();
      expect(escapeLink(), findsOneWidget);
    });

    testWidgets('visible on step 2', (tester) async {
      // Step 2 has 4 duration tiles; set a phone-sized viewport so they fit.
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildScreen());
      await tester.enterText(find.byType(TextField), 'Test User');
      await tester.tap(find.byType(HgButton)); // step 0 → 1
      await tester.pump();
      await tester.tap(find.byType(HgButton)); // step 1 → 2
      await tester.pumpAndSettle();
      expect(escapeLink(), findsOneWidget);
    });
  });

  group('OnboardingScreen escape link action', () {
    testWidgets('tapping escape signs the user out', (tester) async {
      bool signedOut = false;
      await tester.pumpWidget(
        buildScreen(
          signOut: () async {
            signedOut = true;
          },
        ),
      );
      await tester.tap(escapeLink());
      await tester.pump();
      await tester.pump();
      expect(signedOut, isTrue);
    });

    testWidgets('escape on step 1 signs the user out', (tester) async {
      bool signedOut = false;
      await tester.pumpWidget(
        buildScreen(
          signOut: () async {
            signedOut = true;
          },
        ),
      );
      await tester.enterText(find.byType(TextField), 'Test User');
      await tester.tap(find.byType(HgButton));
      await tester.pumpAndSettle();
      await tester.tap(escapeLink());
      await tester.pump();
      await tester.pump();
      expect(signedOut, isTrue);
    });
  });
}
