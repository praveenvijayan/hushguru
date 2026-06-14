---
title: "Crash: APNS token not set when requesting FCM token on iOS"
priority: high
labels: [bug]
blocked_by: []
---

On iOS, `NotificationService.init()` calls `FirebaseMessaging.getToken()` before
the APNS token has been registered with APNs. This triggers an unhandled
exception (`[firebase_messaging/apns-token-not-set]`) that crashes the
notification bootstrap path. The fix should wait for the APNS token to be
available (via `getAPNSToken()`) before requesting the FCM token, and handle the
case where the token is not yet available gracefully rather than throwing.

## Acceptance criteria

- [ ] Launching the app on a physical iOS device no longer throws
  `[firebase_messaging/apns-token-not-set]` during `NotificationService.init()`
- [ ] The FCM token is successfully retrieved after the APNS token becomes
  available (verified via debug log or Firestore token write)
- [ ] If the APNS token is not available within a reasonable timeout, the failure
  is caught and logged — the app does not crash
- [ ] The fix is verified on both a physical iPhone and the iOS simulator (where
  APNS is unavailable, so token retrieval should be skipped gracefully)
- [ ] A test or comment documents the ordering requirement (APNS before FCM) so
  it is not regressed

## Notes

Stack trace points to `notification_service.dart:27` where `getToken()` is
called. The fix likely involves calling `getAPNSToken()` first (with a retry or
delay) and only proceeding to `getToken()` once a non-null APNS token is
confirmed. On simulator/non-APNS environments the call should be skipped or
guarded.
