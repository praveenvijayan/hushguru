import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hashguru/screens/register_screen.dart';
import 'package:hashguru/widgets/hg_button.dart';

void main() {
  group('RegisterScreen validation', () {
    testWidgets('shows error when both fields are empty', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));
      await tester.tap(find.byType(HgButton));
      await tester.pump();
      expect(
        find.text('Please enter your email and password.'),
        findsOneWidget,
      );
    });

    testWidgets('shows error for invalid email format', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));
      await tester.enterText(find.byType(TextField).at(0), 'notanemail');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.tap(find.byType(HgButton));
      await tester.pump();
      expect(find.text('Please enter a valid email address.'), findsOneWidget);
    });

    testWidgets('shows error when password is fewer than 8 characters', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));
      await tester.enterText(find.byType(TextField).at(0), 'user@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'short');
      await tester.tap(find.byType(HgButton));
      await tester.pump();
      expect(
        find.text('Password must be at least 8 characters.'),
        findsOneWidget,
      );
    });
  });

  group('RegisterScreen registration paths', () {
    testWidgets('success path: createAccount is called and no error is shown', (
      tester,
    ) async {
      bool called = false;
      await tester.pumpWidget(
        MaterialApp(
          home: RegisterScreen(
            createAccount: (email, password) async {
              called = true;
            },
          ),
        ),
      );
      await tester.enterText(find.byType(TextField).at(0), 'user@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'validpassword');
      await tester.tap(find.byType(HgButton));
      await tester.pump();
      await tester.pump();
      expect(called, isTrue);
      expect(find.textContaining('failed'), findsNothing);
      expect(find.textContaining('Please enter'), findsNothing);
    });

    testWidgets(
      'error path: duplicate email shows FirebaseAuthException message',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: RegisterScreen(
              createAccount: (email, password) async {
                throw FirebaseAuthException(
                  code: 'email-already-in-use',
                  message:
                      'The email address is already in use by another account.',
                );
              },
            ),
          ),
        );
        await tester.enterText(
          find.byType(TextField).at(0),
          'taken@example.com',
        );
        await tester.enterText(find.byType(TextField).at(1), 'validpassword');
        await tester.tap(find.byType(HgButton));
        await tester.pump();
        await tester.pump();
        expect(
          find.text('The email address is already in use by another account.'),
          findsOneWidget,
        );
      },
    );
  });
}
