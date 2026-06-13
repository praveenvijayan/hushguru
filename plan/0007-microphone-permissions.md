---
title: "Add microphone permission request for voice input"
priority: medium
blocked_by:
  - 0005-dashboard-screen
---

Request microphone access on iOS and Android so voice commands can be recorded
on the Dashboard.

- [ ] `permission_handler` added to `pubspec.yaml`
- [ ] iOS `Info.plist` contains `NSMicrophoneUsageDescription`
- [ ] Android `AndroidManifest.xml` contains `RECORD_AUDIO` permission
- [ ] Tapping the mic area on Dashboard triggers the OS permission dialog
- [ ] `flutter analyze` passes with zero issues
