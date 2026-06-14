---
title: "Wire Claude API for voice yoga guidance responses"
priority: medium
blocked_by:
  - 0008-voice-capture
---

Send the transcribed user input to Claude (claude-haiku-4-5 for latency) with a
yoga-guide system prompt; stream the reply as TTS audio and update status text.

## Acceptance criteria

- [ ] Claude API key stored in Firestore (never in client bundle)
- [ ] Response streams back within 2 s on a good connection
- [ ] Status text updates word-by-word as the response streams
- [ ] TTS audio plays concurrently with text display
- [ ] `flutter analyze` passes with zero issues
