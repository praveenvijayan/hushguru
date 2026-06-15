import 'package:flutter_test/flutter_test.dart';
import 'package:hashguru/services/notification_service.dart';

void main() {
  setUp(NotificationService.resetForTest);

  group('NotificationService idempotency', () {
    test('fcmAvailable is false before any init call', () {
      expect(NotificationService.fcmAvailable, isFalse);
    });

    test('second init call returns immediately without touching Firebase', () async {
      // Mark as already initialised so the guard fires.
      // Calling init() on a clean (uninitialised) state would require Firebase;
      // here we verify the guard path that runs on every subsequent tap.
      NotificationService.resetForTest();

      // Simulate the first init having completed (sets _initialized = true via
      // the guard; _fcmAvailable stays false — e.g. simulator with no APNS).
      // We achieve this by calling init() with _initialized already true, which
      // the implementation reaches via the guard before any Firebase call.
      // We prime the flag indirectly: call resetForTest then immediately call
      // init() from a context where Firebase is unavailable; the guard sets
      // _initialized=true and the Firebase call throws — we catch that, then
      // call init() a second time to prove it returns without re-throwing.
      bool secondCallThrew = false;
      try {
        // First call — hits the guard (_initialized=true), then throws on
        // FirebaseMessaging.instance since Firebase is not initialised in tests.
        await NotificationService.init('uid');
      } catch (_) {
        // Expected — Firebase is not available in unit tests.
      }
      try {
        // Second call — guard short-circuits before any Firebase call.
        await NotificationService.init('uid');
      } catch (_) {
        secondCallThrew = true;
      }
      expect(
        secondCallThrew,
        isFalse,
        reason: 'second init() call must return without hitting Firebase',
      );
    });

    test('resetForTest restores initial state', () async {
      try {
        await NotificationService.init('uid');
      } catch (_) {}

      NotificationService.resetForTest();

      expect(NotificationService.fcmAvailable, isFalse);

      // After reset a subsequent call should throw again (guard cleared),
      // confirming _initialized was actually reset.
      bool threw = false;
      try {
        await NotificationService.init('uid');
      } catch (_) {
        threw = true;
      }
      expect(
        threw,
        isTrue,
        reason: 'after resetForTest the guard must be cleared',
      );
    });
  });
}
