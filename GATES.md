# GATES.md — Verification gates (run in order, fail-fast)

<!-- auto-detected by /ratchet-init on 2026-06-15; verify before first run -->

Every gate must pass locally before you push. A red gate = stay on your branch.

| # | Gate        | Command                                    | When to run           |
|---|-------------|--------------------------------------------|-----------------------|
| 1 | format      | `dart format --set-exit-if-changed .`      | Every PR              |
| 2 | typecheck   | `flutter analyze`                          | Every PR              |
| 3 | lint        | `flutter analyze`                          | Every PR              |
| 4 | test        | `flutter test`                             | Every PR              |
| 5 | build       | `flutter build apk`                        | Every PR              |

**Notes:**
- Gates 2 (typecheck) and 3 (lint) overlap in Flutter/Dart — `flutter analyze`
  covers both static analysis and type checking. Mark gate 2 `TODO` or alias it
  to `flutter analyze` if your CI needs a distinct step.
- Gate 5 (`flutter build apk`) requires Android SDK and an accepted licence.
  On CI, add `flutter build web` as an alternative if the repo targets web only.
- Run all gates before `git push`; CI is a safety net, not the first check.
