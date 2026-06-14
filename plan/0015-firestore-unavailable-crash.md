---
title: "App crashes on Firestore unavailable during profile load"
priority: high
labels: [bug]
blocked_by: []
---

On app start, `UserProfileService.ensureProfile` performs a Firestore document
fetch without handling transient service failures. When Firestore returns a
`cloud_firestore/unavailable` error (network hiccup, cold-start race, or brief
outage), the exception propagates unhandled and crashes the app. The correct
behaviour is to surface a recoverable error state or retry with exponential
back-off so the user can continue without a hard crash.

## Acceptance criteria

- [ ] When Firestore returns `unavailable` during `ensureProfile`, the app does
  not throw an unhandled exception and does not crash
- [ ] The user sees a clear, user-visible message (e.g. "Unable to connect —
  please try again") rather than a blank screen or force-close
- [ ] `ensureProfile` retries at least once with a short back-off before
  surfacing the error to the UI
- [ ] If retries are exhausted, the returned error is logged (debug) and the
  caller receives a typed failure value (not a thrown exception)
- [ ] A test covers the `unavailable` error path: mock Firestore to throw
  `unavailable`, assert no unhandled exception and that the correct error state
  is returned

## Notes

Stack trace points directly to `lib/services/user_profile_service.dart:16`
(`ensureProfile`). The Firestore SDK documents `unavailable` as a transient
condition suitable for client-side retry with back-off.
