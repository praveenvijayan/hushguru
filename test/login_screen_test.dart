import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hashguru/screens/login_screen.dart';
import 'package:hashguru/theme/colors.dart';

void main() {
  group('LoginScreen', () {
    testWidgets('renders shell login content and footer', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      expect(find.text('hushguru'), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Email address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is RichText &&
              widget.text.toPlainText().contains('New to HushGuru?'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('email field uses coral focused border', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      await tester.tap(find.byType(TextField).first);
      await tester.pump();

      final focusedInput = tester.widget<TextField>(
        find.byType(TextField).first,
      );
      final focusedBorder = focusedInput.decoration?.focusedBorder;
      expect(focusedBorder, isA<OutlineInputBorder>());
      expect(
        (focusedBorder! as OutlineInputBorder).borderSide.color,
        HgColors.coral,
      );
    });

    testWidgets('validates email and password before sign-in', (tester) async {
      var signInCalls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            signInWithEmail: (_, _) async {
              signInCalls += 1;
            },
          ),
        ),
      );

      await tester.tap(find.text('Sign in'));
      await tester.pump();

      expect(signInCalls, 0);
      expect(
        find.text('Please enter your email and password.'),
        findsOneWidget,
      );
    });

    testWidgets('sign-in button calls email/password auth flow', (
      tester,
    ) async {
      String? email;
      String? password;
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            signInWithEmail: (submittedEmail, submittedPassword) async {
              email = submittedEmail;
              password = submittedPassword;
            },
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextField).at(0),
        ' user@example.com ',
      );
      await tester.enterText(find.byType(TextField).at(1), 'secret123');
      await tester.tap(find.text('Sign in'));
      await tester.pump();
      await tester.pump();

      expect(email, 'user@example.com');
      expect(password, 'secret123');
      expect(find.textContaining('failed'), findsNothing);
    });

    testWidgets('Google button triggers Google OAuth flow', (tester) async {
      var googleCalls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            signInWithGoogle: () async {
              googleCalls += 1;
            },
          ),
        ),
      );

      await tester.tap(find.text('Continue with Google'));
      await tester.pump();
      await tester.pump();

      expect(googleCalls, 1);
    });

    testWidgets('shows Google sign-in failure message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            signInWithGoogle: () async {
              throw Exception('boom');
            },
          ),
        ),
      );

      await tester.tap(find.text('Continue with Google'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Google sign-in failed.'), findsOneWidget);
    });
  });
}
