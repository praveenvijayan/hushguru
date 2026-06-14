---
title: "Add onboarding flow for new users"
priority: low
blocked_by:
  - 0010-user-profile-firestore
---

First-time users see a 3-step onboarding after sign-up: name entry, practice
level selection, and session duration preference. Saves to Firestore and proceeds
to Dashboard.

## Acceptance criteria

- [ ] Onboarding shown only when `users/{uid}` does not exist
- [ ] Step 1: name input; Step 2: level picker; Step 3: duration picker
- [ ] Completing all 3 steps creates the Firestore document and opens Dashboard
- [ ] Skipping is not allowed — all fields required
- [ ] `flutter analyze` passes with zero issues
