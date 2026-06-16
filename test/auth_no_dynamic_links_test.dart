import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hashguru/app.dart';
import 'package:hashguru/screens/login_screen.dart';
import 'package:hashguru/screens/splash_screen.dart';

void main() {
  group('Firebase Dynamic Links migration (post-shutdown audit)', () {
    test('pubspec.yaml has no firebase_dynamic_links dependency', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, isNot(contains('firebase_dynamic_links')));
    });

    test('Dart source has no Dynamic Links APIs or page.link URLs', () {
      final dartFiles = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));
      for (final file in dartFiles) {
        final src = file.readAsStringSync();
        expect(
          src,
          isNot(contains('firebase_dynamic_links')),
          reason: '${file.path} imports firebase_dynamic_links',
        );
        expect(
          src,
          isNot(contains('DynamicLinks')),
          reason: '${file.path} references DynamicLinks API',
        );
        expect(
          src,
          isNot(contains('.page.link')),
          reason: '${file.path} contains a .page.link URL',
        );
      }
    });

    testWidgets(
      'sign-out: auth stream → null routes to LoginScreen (no Dynamic Links needed)',
      (tester) async {
        final controller = StreamController<User?>();
        addTearDown(controller.close);
        await tester.pumpWidget(
          MaterialApp(home: AppNavigator(authStream: controller.stream)),
        );
        await tester.pump(const Duration(milliseconds: 2600));
        controller.add(null);
        await tester.pump();
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(SplashScreen), findsNothing);
      },
    );
  });
}
