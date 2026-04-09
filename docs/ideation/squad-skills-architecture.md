# Squad Skills Architecture

Status: draft, validated by prototype
Date: 2026-04-08

## Overview

Squad is a Claude Code plugin that extends the Superpowers execution
loop with product management, architecture, design, and quality gates.
It follows the Claude Code plugin framework and reuses Superpowers for
the inner cycle (brainstorm → plan → implement → review).

## Plugin Structure

```
squad/
├── .claude-plugin/
│   └── plugin.json              # Manifest: name, version, userConfig
├── skills/
│   ├── product-brief/
│   │   └── SKILL.md             # PO: create/maintain product brief
│   ├── product-brief-review/
│   │   └── SKILL.md             # QA: review brief (context: fork)
│   ├── product-backlog/         # planned
│   ├── product-gate/            # planned
│   ├── architecture-record/     # planned
│   ├── architecture-gate/       # planned
│   ├── design-system/           # planned
│   ├── design-gate/             # planned
│   ├── qa-gate/                 # planned
│   ├── delivery-record/         # planned
│   ├── knowledge-log/           # planned
│   └── health-register/         # planned
└── hooks/
    └── hooks.json               # Auto-discovered, empty for now
```

## Plugin Configuration

`plugin.json` defines:
- `name`: "squad"
- `version`: semver
- `userConfig.product_home`: directory path for shared artifacts
  - Type: `directory`, with `title` and `description`
  - Accessed in skills as `${user_config.product_home}`

Skills and hooks directories are auto-discovered — do not duplicate
paths in the manifest.

## Skill Design Patterns

### Proven patterns (validated by product-brief test)

**1. Produce/Validate separation**

Every artifact that matters has two skills:
- A **produce** skill (role: the creator) — guided process, writes artifact
- A **validate** skill (role: QA/Reviewer, `context: fork`) — fresh
  context, checklist-based review, structured verdict

The producer invokes the validator. The validator never rewrites —
it reports findings only. The producer addresses findings.

```
[Produce skill] → writes artifact → [Validate skill (fork)] → PASS/FAIL
       ↑                                        │
       └────────── fix FAIL items ──────────────┘
```

**2. CPTO approval at outer perimeter**

After the validate skill passes, the produce skill presents to the
human for approval. The human can:
- **Approve** → skill updates artifact status, chains to next skill
- **Request changes** → skill goes back to relevant step, re-runs
  produce → validate → present cycle

**3. Checklist-driven process**

Each skill defines a numbered checklist. The agent creates a task per
item and completes them in order. This gives the user visibility into
progress and ensures no steps are skipped.

**4. Open-ended discovery, structured validation**

- **Produce skills** (discovery, ideation): use open-ended questions,
  NEVER predefined categories or multiple-choice. The user's problem
  is unique — don't put it in a box.
- **Validate skills** (gates, reviews): use structured checklists with
  pass/fail criteria. This is where structure belongs.
- **Action steps** (addressing findings): multiple-choice is OK but
  ALWAYS include "Chat about this" as an open-ended escape hatch.

**5. Artifact output to shared directory**

All durable artifacts write to `${user_config.product_home}/` in a
predictable structure:

```
$product_home/
├── product/
│   ├── brief.md                 # Product Brief
│   └── backlog/                 # Product Backlog (shaped items)
├── architecture/
│   ├── record.md                # Architecture Record (map + ADRs)
│   ├── api-contracts/           # API Contracts
│   └── data-models/             # Data Models
├── design/
│   └── system.md                # Design System Doc
├── qa/
│   ├── scenarios/               # Test Scenarios (cumulative)
│   └── reports/                 # QA Reports
└── continuous/
    ├── knowledge.md             # Knowledge Log
    └── health.md                # System Health & Debt Register
```

**6. Skill chaining**

Each skill declares what it chains to. The produce skill explicitly
names the next skill after completion:

```markdown
## Chains To
After CPTO approves, invoke `squad:product-backlog`.
```

### Anti-patterns to avoid

| Anti-pattern | Why it fails | Instead |
|-------------|-------------|---------|
| Self-review | Same context, same blind spots | Use `context: fork` for independent review |
| Predefined categories in discovery | Kills ideation, constrains to author's imagination | Open-ended questions |
| Multiple-choice without escape | User may disagree with all options | Always add "Chat about this" |
| Validate your own output | Producer bias confirms own work | Separate role validates |
| Architecture in product brief | Premature solution design | Hard gate: problem space only |

## Skill Inventory

### Implemented (v0.1.0)

| Skill | Role | Type | Lines | Validated |
|-------|------|------|-------|-----------|
| `product-brief` | Product Owner | Produce | 220 | Yes — e2e test |
| `product-brief-review` | QA/Reviewer | Validate (fork) | 110 | Yes — e2e test |

### Planned

| Skill | Role | Type | Priority |
|-------|------|------|----------|
| `product-backlog` | Product Owner | Produce | Next |
| `product-gate` | QA/Reviewer | Validate | High |
| `architecture-record` | Architect | Produce | High |
| `architecture-gate` | Architect | Validate (fork) | High |
| `design-system` | Designer | Produce | Medium |
| `design-gate` | Designer | Validate (fork) | Medium |
| `qa-gate` | QA/Reviewer | Validate | Medium |
| `delivery-record` | PO + Designer | Produce | Medium |
| `knowledge-log` | All roles | Produce | Low |
| `health-register` | Dev + Architect | Produce | Low |

### Inner cycle (Superpowers — not rebuilt)

| Activity | Superpowers Skill | Our Equivalent |
|----------|------------------|----------------|
| Brainstorm | `superpowers:brainstorming` | Implementation Spec |
| Plan | `superpowers:writing-plans` | Task Breakdown |
| Implement | `superpowers:executing-plans` | Code + Tests |
| Code Review | `superpowers:requesting-code-review` | Review Findings |

## Methodology Reference

Each skill embeds techniques from the methodology research
(see `docs/ideation/squad-methodologies.md`). Pick the leanest
technique per skill:

| Skill | Primary Technique |
|-------|------------------|
| `product-brief` | MITRE 3-phase canvas + JTBD + Shape Up appetite |
| `product-backlog` | Epic hypothesis + Given/When/Then + ICE scoring |
| `architecture-record` | C4 Model L1+L2 + Nygard ADR |
| `architecture-gate` | Fitness functions + boundary checklist |
| `design-system` | Design tokens + Gstack DESIGN.md template |
| `design-gate` | Confidence-tier checklist + WCAG essentials |
| `qa-gate` | BDD scenarios + exploratory testing charters |
| `delivery-record` | Delta changelog + narrative arc demo |
| `knowledge-log` | Typed entries + staleness pruning |
| `health-register` | DORA metrics + impact/effort debt scoring |

## Testing (validated by product-brief tests)

Three-tier bash test framework adapted from Superpowers. Tests run real
Claude Code sessions and verify behavior through output parsing — no
mock frameworks, no grader agents.

**Directory structure:**

```
tests/
├── test-helpers.sh              # Shared utilities (run_claude, assertions)
├── run-tests.sh                 # Runner with --tier flag
├── skill-knowledge/             # Tier 1: does Claude understand the skill?
│   └── test-<skill>.sh
├── skill-triggering/            # Tier 2: does the right skill activate?
│   ├── run-test.sh              # Generic trigger harness
│   ├── run-all.sh
│   └── prompts/                 # One .txt per test case
└── skill-execution/             # Tier 3: full workflow → correct artifacts?
    ├── test-<skill>-execution.sh
    └── fixtures/
```

**Three tiers:**

| Tier | Speed | What it verifies | How |
|------|-------|-----------------|-----|
| Knowledge | ~30s | Claude loaded the skill and understands its process | `claude -p "question about skill"` + grep assertions |
| Triggering | ~30s | Correct skill activates for a given prompt | `--output-format stream-json` + check for `"name":"Skill"` |
| Execution | 5-15min | Full workflow produces correct artifacts | Run skill with rich context, verify output file structure |

**Running tests:**

```bash
./tests/run-tests.sh                    # knowledge + triggering (fast)
./tests/run-tests.sh --tier knowledge   # just knowledge
./tests/run-tests.sh --tier triggering  # just triggering
./tests/run-tests.sh --tier execution   # slow, full workflow
./tests/run-tests.sh --verbose          # show all output
```

**Key lessons:**

- Knowledge tests must cap `--max-turns` (5) to prevent Claude from
  launching the actual skill workflow instead of answering the question
- Assertion patterns need multiple alternatives (`fix\|Fix\|repair`)
  because Claude's phrasing varies between runs
- Triggering tests use `--output-format stream-json` and grep for
  `"skill":"<name>"` in the JSON log — same technique as Superpowers
- On API 500/429 errors, stop — do not retry

**Adding tests for a new skill:**

1. Add `tests/skill-knowledge/test-<skill>.sh` — 3-5 questions about
   the skill's process, one `run_claude_knowledge` + assertions per test
2. Add prompt files in `tests/skill-triggering/prompts/` — explicit,
   implicit, and negative cases
3. Add the skill to `tests/skill-triggering/run-all.sh` TESTS array
4. Add `tests/skill-execution/test-<skill>-execution.sh` if the skill
   produces artifacts that can be structurally validated

## Platform Notes (Claude Code)

- Plugin manifest: `.claude-plugin/plugin.json`
- `userConfig` requires `type`, `title`, `description` fields
- `hooks/hooks.json` auto-discovered — do not duplicate in manifest
- `skills/` auto-discovered — can omit from manifest
- Skills invocable as `/skill-name` (prefix optional) or `/squad:skill-name`
- `context: fork` in skill frontmatter creates isolated subagent
- `${user_config.key}` for non-sensitive config substitution
- Keep SKILL.md under 500 lines; use supporting files for templates
- `/reload-plugins` to pick up changes during development
- Install for dev: `claude --plugin-dir /path/to/squad`
