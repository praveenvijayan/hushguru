---
title: "Add Firebase to Flutter project"
priority: high
---

Wire up `firebase_core`, `firebase_auth`, and `cloud_firestore` so the app boots
with a live Firebase connection on both iOS and Android.

## Acceptance criteria
- [ ] `flutter pub get` succeeds with firebase_core, firebase_auth, cloud_firestore
- [ ] `lib/firebase_options.dart` contains real iOS + Android credentials
- [ ] `android/app/google-services.json` present with package `com.hushguru.dev`
- [ ] `ios/Runner/GoogleService-Info.plist` present with bundle `com.hushguru.dev`
- [ ] `lib/main.dart` calls `Firebase.initializeApp()` before `runApp()`
- [ ] `flutter analyze` passes with zero issues
