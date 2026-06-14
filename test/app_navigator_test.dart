import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hashguru/app.dart';
import 'package:hashguru/screens/login_screen.dart';
import 'package:hashguru/screens/splash_screen.dart';

void main() {
  group('AppNavigator', () {
    testWidgets('shows SplashScreen while auth state is loading (waiting)', (
      tester,
    ) async {
      final controller = StreamController<User?>();
      addTearDown(controller.close);
      await tester.pumpWidget(
        MaterialApp(home: AppNavigator(authStream: controller.stream)),
      );
      // Advance past the 2500 ms splash delay without emitting auth state
      await tester.pump(const Duration(milliseconds: 2600));
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets(
      'shows LoginScreen when auth stream emits null (unauthenticated)',
      (tester) async {
        final controller = StreamController<User?>();
        addTearDown(controller.close);
        await tester.pumpWidget(
          MaterialApp(home: AppNavigator(authStream: controller.stream)),
        );
        await tester.pump(const Duration(milliseconds: 2600));
        controller.add(null); // unauthenticated
        await tester.pump(); // let StreamBuilder react
        expect(find.byType(LoginScreen), findsOneWidget);
      },
    );
  });
}
