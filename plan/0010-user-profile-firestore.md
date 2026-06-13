---
title: "Store and load user profile from Firestore"
priority: medium
blocked_by:
  - 0006-auth-state-persistence
---

On first sign-in create a Firestore document at `users/{uid}` with display name,
email, practice level, and session duration. Read it back to populate
SettingsLetter.

- [ ] User document created on first successful sign-in
- [ ] SettingsLetter shows live values from Firestore (not hardcoded)
- [ ] Tapping a value in SettingsLetter opens an edit dialog that saves to Firestore
- [ ] `flutter analyze` passes with zero issues
