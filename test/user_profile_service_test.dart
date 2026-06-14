import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hashguru/services/user_profile_service.dart';

void main() {
  group('withFirestoreRetry', () {
    test('returns true when operation succeeds immediately', () async {
      final result = await withFirestoreRetry(() async {});
      expect(result, isTrue);
    });

    test(
      'retries on unavailable and returns false after all attempts fail',
      () async {
        var calls = 0;
        final result = await withFirestoreRetry(
          () async {
            calls++;
            throw FirebaseException(
              plugin: 'cloud_firestore',
              code: 'unavailable',
              message: 'The service is currently unavailable.',
            );
          },
          maxAttempts: 2,
          backoff: Duration.zero,
        );
        expect(result, isFalse);
        expect(calls, equals(2));
      },
    );

    test('returns true when operation succeeds on a retry', () async {
      var calls = 0;
      final result = await withFirestoreRetry(
        () async {
          calls++;
          if (calls < 2) {
            throw FirebaseException(
              plugin: 'cloud_firestore',
              code: 'unavailable',
            );
          }
        },
        maxAttempts: 3,
        backoff: Duration.zero,
      );
      expect(result, isTrue);
      expect(calls, equals(2));
    });

    test(
      'rethrows non-unavailable FirebaseException without retrying',
      () async {
        var calls = 0;
        await expectLater(
          withFirestoreRetry(() async {
            calls++;
            throw FirebaseException(
              plugin: 'cloud_firestore',
              code: 'permission-denied',
            );
          }, backoff: Duration.zero),
          throwsA(isA<FirebaseException>()),
        );
        expect(calls, equals(1));
      },
    );
  });
}
