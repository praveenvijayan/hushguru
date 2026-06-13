---
title: "Persist Firebase auth state across app restarts"
priority: high
blocked_by:
  - 0004-login-screen
---

On cold start check `firebase_auth.currentUser`; if signed in, skip Login and
go directly to Dashboard. On sign-out, return to Login.

- [ ] App opens directly to Dashboard when a session is already active
- [ ] Tapping sign-out clears the session and returns to Login
- [ ] `flutter analyze` passes with zero issues
