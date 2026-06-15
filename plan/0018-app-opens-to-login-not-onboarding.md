---
title: "Wire 'Create account' flow: RegisterScreen + LoginScreen link"
priority: high
labels: [bug, auth]
blocked_by: []
---

The "Create account" link in `lib/screens/login_screen.dart` has `onTap: () {}` —
it does nothing. New users have no way to register via email/password. The fix is
to build a RegisterScreen (collect email + password, call
`FirebaseAuth.createUserWithEmailAndPassword`) and wire the existing link to
navigate there. After successful registration the auth-state router in `app.dart`
automatically routes to OnboardingScreen (user authenticated, no profile yet).

## Acceptance criteria

- [ ] Tapping "Create account" on the login screen navigates to a registration screen.
- [ ] The registration screen accepts an email address and password with basic
  validation (non-empty, valid email format, password ≥ 8 characters).
- [ ] On successful registration the user is authenticated in Firebase and the
  app navigates to OnboardingScreen without any extra user action.
- [ ] On registration failure (duplicate email, network error, weak password) a
  clear, user-visible error message is displayed and the user stays on the
  registration screen.
- [ ] A widget test covers the success path (mock Firebase → onboarding) and at
  least one error path (duplicate email → error shown).
