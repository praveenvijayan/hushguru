---
title: "Record practice sessions to Firestore progress journal"
priority: medium
blocked_by:
  - 0011-asana-library
---

After each practice session write a document to `users/{uid}/sessions` with
timestamp, asana name, duration, and AI guide transcript. Display the last 7
sessions in the Progress Journal screen.

- [ ] Session document written to Firestore on practice completion
- [ ] Progress Journal screen lists sessions in reverse-chronological order
- [ ] Each row shows date, asana, and duration
- [ ] `flutter analyze` passes with zero issues
