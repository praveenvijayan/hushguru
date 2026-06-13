---
title: "Capture and transcribe voice input on Dashboard"
priority: medium
blocked_by:
  - 0007-microphone-permissions
---

Record audio from the microphone, transcribe it (via `speech_to_text` or
Gemini audio API), and display the result in the status text area.

- [ ] Holding the mic button starts recording; releasing stops it
- [ ] Transcription text appears in the status area within 3 s of release
- [ ] Recording indicator (pulse animation) is visible during capture
- [ ] `flutter analyze` passes with zero issues
