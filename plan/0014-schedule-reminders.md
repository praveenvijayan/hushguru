---
title: "Send daily practice reminders via Firebase Cloud Messaging"
priority: low
blocked_by:
  - 0013-onboarding-flow
---

Use FCM to send a daily push notification at the user's preferred practice time.
The reminder deep-links into Dashboard.

- [ ] FCM token stored in `users/{uid}.fcmToken` on first launch
- [ ] Cloud Function `dailyReminder` triggered at user's local practice time
- [ ] Tapping the notification opens the app at the Dashboard screen
- [ ] Users can disable reminders from Settings
- [ ] `flutter analyze` passes with zero issues
