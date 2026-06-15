---
title: "Bug: FCM token silently skipped after APNS retries when mic is tapped"
priority: medium
labels: [bug, notifications, ios]
blocked_by: []
---

When the user taps the mic button, `NotificationService` is invoked and attempts
to obtain an APNS token. After exhausting retries it logs
`[NotificationService] APNS token unavailable after retries (simulator or APNs error) — skipping FCM token`
and continues without an FCM token. Two problems: (1) the service is being
triggered on mic tap rather than at startup, suggesting a late-init or
lazy-init path is not guarded; (2) silently skipping the FCM token means any
feature that depends on push messaging will fail without surfacing the reason.

## Acceptance criteria

- [ ] Tapping the mic on a simulator or a device where APNs is unavailable no
  longer triggers a `NotificationService` init or retry loop — if the token was
  already attempted at startup the result is cached and mic tap incurs no extra
  work
- [ ] When the FCM token is unavailable (after retries), the app logs a
  structured warning and the mic flow continues or fails with a clear in-app
  message rather than silently degrading
- [ ] On a physical iOS device with APNs available, tapping the mic works
  correctly and the FCM token is present in Firestore (or the relevant store)
- [ ] The fix is verified on the simulator: mic tap completes without the
  `[NotificationService] APNS token unavailable` log or, if the log is kept,
  the notification init is confirmed to have been skipped at startup (not
  re-invoked on tap)

## Notes

The symptom is a `[NotificationService]` log on mic tap. Likely cause: the mic
button triggers a code path that calls `NotificationService.init()` (or
`getToken()`) without checking whether init already ran. The retry logic
referenced in the log is the guard added to resolve the crash in
`0017-apns-token-not-set-crash`, but it fires again per-tap instead of once at
startup.
