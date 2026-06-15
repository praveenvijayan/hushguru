---
title: "Add escape from OnboardingScreen back to LoginScreen"
priority: medium
labels: [bug, ux]
blocked_by: []
---

`lib/screens/onboarding_screen.dart` has no back navigation or exit action.
A user who lands there unintentionally (e.g., completed Google OAuth but has no
profile, or tapped "Create account" and then changed their mind) is trapped: the
only way forward is to finish onboarding. Adding a "Sign in with existing account"
link (or a back/close button) that calls `FirebaseAuth.signOut()` returns the
auth-state router to `user == null`, which routes to LoginScreen automatically.

## Acceptance criteria

- [ ] OnboardingScreen displays a clearly visible "Already have an account? Sign in"
  link (or equivalent back/close control) on all three onboarding steps.
- [ ] Tapping that link calls `FirebaseAuth.signOut()` and the app navigates to
  LoginScreen without a manual restart.
- [ ] No onboarding progress is saved when the user escapes (profile is not
  partially written to Firestore).
- [ ] A widget test verifies the escape tap signs the user out and results in
  LoginScreen being shown.
