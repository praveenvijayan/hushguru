# Firebase setup

Firebase is wired manually (without the FlutterFire CLI).

## What is already configured

| File | Purpose |
|------|---------|
| `lib/firebase_options.dart` | iOS + Android credentials |
| `ios/Runner/GoogleService-Info.plist` | iOS native config |
| `android/app/google-services.json` | Android native config |
| `android/settings.gradle.kts` | `com.google.gms.google-services` plugin |
| `android/app/build.gradle.kts` | Plugin applied + `com.hushguru.dev` IDs |
| `ios/Runner.xcodeproj/project.pbxproj` | Bundle ID `com.hushguru.dev` |

## Firebase project

- Project ID: `hushguru-775f5`
- Bundle / package: `com.hushguru.dev`
- Auth enabled: Email/Password, Google
- Apple auth: deferred

## Project MCP server

Agents that support project-scoped MCP config can discover the Firebase MCP
server from the repo-root `.mcp.json`. It runs:

```bash
npx --yes firebase-tools@15.20.0 -P hushguru-775f5 mcp
```

Keep this config in `.mcp.json` instead of user-global MCP settings so Firebase
tools are available only when an agent is working in this repository.

## To regenerate `firebase_options.dart`

If you add a new platform or rotate keys, re-run:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project hushguru-775f5
```

Or update `lib/firebase_options.dart` manually from the Firebase console.
