# Plan file format

Each file in `plan/` maps to one GitHub issue via `plan-sync`.

## File naming

`NNNN-short-slug.md` — four-digit zero-padded number, hyphen, kebab slug.

## Frontmatter fields

```yaml
---
title: "Short imperative sentence (under 72 chars)"
priority: high | medium | low
blocked_by:
  - NNNN-other-slug   # slug of another plan file (not an issue number)
---
```

- `title` and `priority` are required.
- `blocked_by` is optional; omit the key entirely if there are no blockers.
- Express dependencies using **slugs** (e.g. `0002-user-model`), never `#numbers`.

## Body

Free-form Markdown. Must include at least one acceptance criterion:

```markdown
- [ ] Testable, observable outcome a reviewer can verify
```

Vague restatements of the title are not criteria.

## plan-sync behaviour

`scripts/plan-sync.mjs` inserts `<!-- ratchet-slug: NNNN-slug -->` into the
issue body to track which file owns which issue. Re-running is idempotent.
