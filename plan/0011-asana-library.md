---
title: "Build Asana library with Firestore-backed pose catalogue"
priority: medium
blocked_by:
  - 0010-user-profile-firestore
---

Store asana metadata (name, Sanskrit name, video URL, duration, difficulty) in
Firestore. Render a browsable list in the Asana Player overlay.

## Acceptance criteria

- [ ] Firestore collection `asanas` seeded with at least 5 poses
- [ ] Asana list renders in the overlay with name + difficulty badge
- [ ] Tapping a pose loads it in the video player
- [ ] `flutter analyze` passes with zero issues
