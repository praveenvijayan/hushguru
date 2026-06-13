#!/usr/bin/env node
/**
 * plan-sync.mjs — compile plan/*.md into GitHub issues
 *
 * Reads every NNNN-slug.md in plan/, parses YAML frontmatter, then
 * creates or updates GitHub issues idempotently using a
 * <!-- ratchet-slug: NNNN-slug --> marker in the issue body.
 *
 * Usage (from repo root):
 *   GITHUB_TOKEN=<pat> GITHUB_REPOSITORY=owner/repo node scripts/plan-sync.mjs
 */

import { readdir, readFile } from 'fs/promises';
import { join } from 'path';

// ─── Config ──────────────────────────────────────────────────────────────────

const TOKEN = process.env.GITHUB_TOKEN;
const REPO = process.env.GITHUB_REPOSITORY;

if (!TOKEN) { console.error('GITHUB_TOKEN not set'); process.exit(1); }
if (!REPO)  { console.error('GITHUB_REPOSITORY not set'); process.exit(1); }

const API = 'https://api.github.com';
const headers = {
  Authorization: `token ${TOKEN}`,
  Accept: 'application/vnd.github+json',
  'X-GitHub-Api-Version': '2022-11-28',
  'Content-Type': 'application/json',
  'User-Agent': 'plan-sync/1.0',
};

// ─── Helpers ─────────────────────────────────────────────────────────────────

function parseFrontmatter(raw) {
  const match = raw.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n([\s\S]*)$/);
  if (!match) return { meta: {}, body: raw.trim() };
  const fm = match[1];
  const body = match[2].trim();
  const meta = {};
  for (const line of fm.split('\n')) {
    const kv = line.match(/^(\w[\w_-]*):\s*(.+)$/);
    if (kv) {
      const val = kv[2].trim().replace(/^["']|["']$/g, '');
      meta[kv[1]] = val;
    }
    // blocked_by list items
    const item = line.match(/^\s+-\s+(.+)$/);
    if (item && meta._lastKey === 'blocked_by') {
      meta.blocked_by = meta.blocked_by || [];
      if (!Array.isArray(meta.blocked_by)) meta.blocked_by = [];
      meta.blocked_by.push(item[1].trim());
    }
    if (kv && kv[1] === 'blocked_by') {
      meta._lastKey = 'blocked_by';
      meta.blocked_by = [];
    } else if (kv) {
      meta._lastKey = kv[1];
    } else if (item) {
      // handled above
    } else {
      meta._lastKey = null;
    }
  }
  return { meta, body };
}

async function ghGet(path) {
  const r = await fetch(`${API}${path}`, { headers });
  if (r.status === 404) return null;
  if (!r.ok) throw new Error(`GET ${path} → ${r.status} ${await r.text()}`);
  return r.json();
}

async function ghPost(path, data) {
  const r = await fetch(`${API}${path}`, {
    method: 'POST',
    headers,
    body: JSON.stringify(data),
  });
  if (!r.ok) throw new Error(`POST ${path} → ${r.status} ${await r.text()}`);
  return r.json();
}

async function ghPatch(path, data) {
  const r = await fetch(`${API}${path}`, {
    method: 'PATCH',
    headers,
    body: JSON.stringify(data),
  });
  if (!r.ok) throw new Error(`PATCH ${path} → ${r.status} ${await r.text()}`);
  return r.json();
}

// ─── Fetch all open issues with ratchet markers ───────────────────────────────

async function fetchExistingIssues() {
  const map = {}; // slug → { number, state, body }
  let page = 1;
  while (true) {
    const issues = await ghGet(`/repos/${REPO}/issues?state=all&per_page=100&page=${page}`);
    if (!issues || issues.length === 0) break;
    for (const issue of issues) {
      const m = issue.body?.match(/<!--\s*ratchet-slug:\s*([^\s]+)\s*-->/);
      if (m) map[m[1]] = { number: issue.number, state: issue.state, body: issue.body };
    }
    if (issues.length < 100) break;
    page++;
  }
  return map;
}

// ─── Priority → label ────────────────────────────────────────────────────────

function priorityLabel(p) {
  if (p === 'high')   return 'priority:high';
  if (p === 'medium') return 'priority:medium';
  if (p === 'low')    return 'priority:low';
  return 'priority:medium';
}

// ─── Main ────────────────────────────────────────────────────────────────────

const planDir = join(process.cwd(), 'plan');
const files = (await readdir(planDir))
  .filter(f => /^\d{4}-[a-z0-9-]+\.md$/.test(f))
  .sort();

const existing = await fetchExistingIssues();

let created = 0, updated = 0, held = 0, skipped = 0;

for (const file of files) {
  if (file === 'README.md') continue;
  const slug = file.replace(/\.md$/, '');
  const raw = await readFile(join(planDir, file), 'utf8');
  const { meta, body } = parseFrontmatter(raw);

  if (!meta.title || !meta.priority) {
    console.log(`SKIP  ${file} — missing title or priority`);
    skipped++;
    continue;
  }

  const marker = `<!-- ratchet-slug: ${slug} -->`;
  const issueBody = `${body}\n\n${marker}`;

  const labels = ['state:ready', priorityLabel(meta.priority)];

  if (existing[slug]) {
    const ex = existing[slug];
    // If in-progress or in-review, hold
    const inFlight = ex.body?.includes('state:in-progress') ||
      ex.body?.includes('state:in-review');
    if (inFlight) {
      console.log(`HOLD  #${ex.number}  ${slug}`);
      held++;
      continue;
    }
    // Update title + body + labels
    await ghPatch(`/repos/${REPO}/issues/${ex.number}`, {
      title: meta.title,
      body: issueBody,
      labels,
    });
    console.log(`UPDATE #${ex.number}  ${slug}`);
    updated++;
  } else {
    const issue = await ghPost(`/repos/${REPO}/issues`, {
      title: meta.title,
      body: issueBody,
      labels,
    });
    console.log(`CREATE #${issue.number}  ${slug}`);
    created++;
  }
}

console.log(`\nDone — ${created} created, ${updated} updated, ${held} held, ${skipped} skipped`);
