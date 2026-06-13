# AGENTS.md — Operating manual for agents working in this repo

## Quick facts

- **Repo**: praveenvijayan/hushguru
- **Stack**: Flutter / Dart (SDK ^3.12.2)
- **Primary language**: Dart

## Workflow overview

Issues flow through these labels (enforced by ratchet):

`state:draft` → `state:ready` → `state:in-progress` → `state:in-review` → closed

| Label | Meaning |
|-------|---------|
| `state:draft` | Synced from `plan/` but missing acceptance criteria |
| `state:ready` | Unblocked and pickable by an agent |
| `state:in-progress` | Claimed; `agent/issue-<N>` branch exists |
| `state:in-review` | PR open, awaiting human review |
| `state:changes-requested` | Human requested changes; agent reworking |
| `state:blocked` | Has an open blocker; not pickable |

## Branch naming

One branch per issue: `agent/issue-<N>` — one PR closes one issue.

## Gates

<!-- auto-detected by /factory-init on 2026-06-13; verify before first run -->

| Gate      | Command                                 |
|-----------|-----------------------------------------|
| format    | `dart format --set-exit-if-changed .`   |
| typecheck | `flutter analyze`                       |
| lint      | `flutter analyze`                       |
| test      | `flutter test`                          |
| build     | `flutter build apk`                     |

> **Note**: In Flutter/Dart, `flutter analyze` covers both type checking and linting
> (it runs `dart analyze` with the rules in `analysis_options.yaml`).
> `typecheck` and `lint` rows intentionally share the same command.

Run gates in order: `format` → `typecheck/lint` → `test` → `build`.
All gates must pass before a PR can merge.

## Acceptance criteria

Every issue in `plan/` must have at least one testable `- [ ]` criterion
before it leaves `state:draft`. Vague descriptions are not criteria.

## File layout

```
plan/       # one .md per planned issue — compiled to GH issues by plan-sync
lib/        # Flutter app source
android/    # Android host project
ios/        # iOS host project
web/        # Web host project
```

## Ratchet skills

| Skill | When to use |
|-------|-------------|
| `/plan-issues`  | Convert a scoped idea into `plan/*.md` files |
| `/plan-sync`    | Compile `plan/*.md` into GitHub issues now (without pushing) |
| `/factory-init` | Re-run when stack, labels, or PAT drifts |
