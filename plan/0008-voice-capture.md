---
title: "Capture and transcribe voice input on Dashboard"
priority: medium
---

Record audio from the microphone, transcribe it (via `speech_to_text`), and
display the result in the status text area.

## Acceptance criteria

- [ ] Holding the mic button starts recording; releasing stops it
- [ ] Transcription text appears in the status area within 3 s of release
- [ ] Recording indicator (pulse animation) is visible during capture
- [ ] `flutter analyze` passes with zero issues
