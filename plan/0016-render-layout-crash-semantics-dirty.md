---
title: "Crash: RenderBox not laid out / semantics.parentDataDirty assertion"
priority: high
labels: [bug]
blocked_by: []
---

The app throws a repeating cascade of Flutter rendering assertions during
operation. Two errors interleave in a loop: `'!semantics.parentDataDirty': is
not true` (object.dart:5705) and `RenderBox was not laid out:
RenderClipRRect#8616f relayoutBoundary=up1`. Both originate from the same
widget — a `ClipRRect` whose parent never completes layout before a semantics
pass runs, triggering an assertion failure. The errors repeat continuously,
degrading the UI and producing noise that can mask other errors.

## Acceptance criteria

- [ ] The app runs without the `!semantics.parentDataDirty` assertion firing in
  debug mode during normal navigation and use
- [ ] The `RenderBox was not laid out: RenderClipRRect` error no longer appears
  in the debug console during any standard user flow
- [ ] The fix is verified by reproducing the original error path, confirming the
  crash no longer occurs
- [ ] No regression in any screen that contains a `ClipRRect` widget (e.g.
  avatars, cards, image previews)

## Notes

The repeated cycle suggests a `ClipRRect` (or its ancestor) is being inserted
into the render tree and immediately asked for semantics before its first layout
pass completes — typically caused by a `setState` or reactive rebuild that
triggers a semantics flush mid-frame. Suspects include animated widgets, lazy
lists, or a `Stack`/`Overlay` where a child is conditionally shown and the
parent's constraints are not yet propagated.
