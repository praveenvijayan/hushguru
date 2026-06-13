---
title: "Build Login screen with email/password and Google sign-in"
priority: high
blocked_by:
  - 0002-design-system
---

Shell-background login with HgWordmark, email + password HgInput fields,
primary Sign-in button, outline Google button, and "New to HushGuru?" footer.

- [ ] Email + password fields render with coral focus border
- [ ] Sign-in button calls `firebase_auth` `signInWithEmailAndPassword`
- [ ] Google sign-in button triggers Google OAuth flow
- [ ] On success the app navigates to Dashboard
- [ ] Form validates: non-empty email + password before submission
- [ ] `flutter analyze` passes with zero issues
