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
│   │   └── SKILL.md             # Shipped v0.2.0
│   ├── product-brief-review/
│   │   └── SKILL.md             # Shipped v0.2.0 (context: fork)
│   ├── architecture-record/
│   │   └── SKILL.md             # Shipped v0.2.0
│   ├── architecture-record-review/
│   │   └── SKILL.md             # Shipped v0.2.0 (context: fork)
│   ├── product-naming/          # Shipped v0.3.0
│   ├── product-naming-review/   # Shipped v0.3.0 (context: fork)
│   ├── design-system/           # Shipped v0.3.0
│   ├── design-system-review/    # Shipped v0.3.0 (context: fork)
│   ├── product-backlog/         # planned
│   ├── product-gate/            # planned
│   ├── architecture-gate/       # planned
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

**Skills vs. activities (clarifier).** The role × activity matrix in
`squad-process-model.md` counts activities, not skills. A single
activity may be implemented by multiple skills — for example, the
Designer's "maintain design system" activity is implemented by four
skills (`design-system` as orchestrator plus three
`design-research-*` helpers), and the Designer's separate "maintain
product identity and naming" activity is implemented by one skill
(`product-naming`). The 25% cap in the role matrix is a balance
rule on activity ownership, not a hard limit on skill count. When
introducing a new skill, first determine whether it implements an
existing activity or proposes a new one — only new activities need
to be added to the matrix explicitly.

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
├── product/                     # Product foundation (PO)
│   ├── brief.md                 # Product Brief
│   └── backlog/                 # Product Backlog (shaped items)
├── architecture/                # Architecture foundation (Architect)
│   ├── record.md                # Architecture Record (map + ADRs)
│   ├── api-contracts/           # API Contracts
│   └── data-models/             # Data Models
├── design/                      # Design System foundation (Designer)
│   ├── system.md                # Design System Doc
│   └── research/                # Reference layer (design research)
│       ├── references.md        # Design Research — References
│       ├── audience.md          # Design Research — Audience
│       └── standards.md         # Design Research — Standards
├── identity/                    # Product Identity foundation (Designer)
│   └── naming.md                # Product Naming
├── qa/
│   ├── scenarios/               # Test Scenarios (cumulative)
│   └── reports/                 # QA Reports
└── continuous/
    ├── knowledge.md             # Knowledge Log
    └── health.md                # System Health & Debt Register
```

Each of the four durable foundations gets its own top-level
directory. The Designer role owns two foundation directories
(`design/` and `identity/`) — this is fine because foundation
ownership, not directory ownership, is the organizing principle.

Reference-layer artifacts that are **emergent** (feature-work findings,
ad-hoc handoff notes, coordination memos) are self-regulated — the
producing agent picks the filename inside its role's directory
(e.g., `architecture/notes/<slug>.md`, `product/research/<slug>.md`).
Reference classification is by property, not location.

**6. Skill chaining**

Each skill declares what it chains to. The produce skill explicitly
names the next skill after completion:

```markdown
## Chains To
After CPTO approves, invoke `squad:product-backlog`.
```

**7. Orchestration**

Some skills are **entry points** that invoke other skills as
dependencies before doing their own work. The `design-system` skill
is the first instance: it reads its upstream dependencies (approved
product brief, optional research briefs, optional product naming),
invokes the missing sub-skills to create them if needed, then
synthesizes the Design System Doc.

Orchestration is distinct from chaining:

| Aspect | Chaining | Orchestration |
|---|---|---|
| Direction | Forward (A → B) | Fan-in (B, C, D → A) |
| Control | A declares "next: B" | A calls B, C, D as prerequisites |
| Data flow | A's output is B's trigger | B, C, D's outputs become A's inputs |
| Invocation | Declarative | Imperative |
| Shape | Linear sequence | Dependency resolution |

**Contract for orchestrators:**

1. **Sub-skills must be independently invocable.** The orchestrated
   skill must stand on its own for standalone use; the orchestrator
   just invokes it like any other caller.
2. **Check dependency state before invoking.** The orchestrator reads
   the filesystem to see which dependency artifacts already exist.
   If an artifact exists and is recent enough, skip invocation. This
   keeps orchestration idempotent.
3. **Read outputs read-only.** The orchestrator never mutates a
   sub-skill's artifact — only its own durable output.
4. **Handle partial and failed states explicitly.** Some dependencies
   may exist while others don't. Some may be stale. Some sub-skill
   runs may return `BLOCKED`. The orchestrator decides per-case:
   proceed with what's available, escalate to CPTO, or halt.

**Sub-skill status protocol.** When a sub-skill is invoked as a
dependency by an orchestrator, it ends its work with a Sub-skill
Report — a bulleted prose block the orchestrator reads narratively.
No regex, no sentinels, no files. This is lifted from Superpowers'
`subagent-driven-development` pattern directly, with one Squad-
specific field added to handle the shared working directory.

Report format:

````markdown
## Sub-skill Report

- **Status:** DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED
- **Artifact:** <path to the file written, or "none">
- **Summary:** <1–3 sentences on what was produced or attempted>
- **Notes / Question / Reason:** <one of these, matching status:
  notes for DONE_WITH_CONCERNS, the blocking question for
  NEEDS_CONTEXT, the reason for BLOCKED>
- **Working state:** clean | partial: <list any files written before
  stopping, if status is not DONE>
````

Status vocabulary (exact literal strings, inherited from Superpowers):

- `DONE` — artifact produced, sub-skill's self-validation passed
- `DONE_WITH_CONCERNS` — artifact produced but with caveats the
  orchestrator should read
- `NEEDS_CONTEXT` — sub-skill hit a question it cannot answer alone
- `BLOCKED` — sub-skill could not produce the artifact

**Why `Working state` is Squad-specific.** Superpowers dispatches
subagents in isolated contexts — they can't pollute the controller's
working directory. Squad's sibling skills share the working
directory, so a sub-skill that stops at `BLOCKED` or `NEEDS_CONTEXT`
may have already written partial artifacts. The `Working state`
field forces the sub-skill to declare this explicitly so the
orchestrator can roll back, accept, or continue with open eyes.

**Handling rules for the orchestrator:**

- **DONE** — read the artifact at the declared path, proceed.
- **DONE_WITH_CONCERNS** — read the artifact and the notes. If any
  note is load-bearing for the orchestrator's own work, surface to
  CPTO before proceeding. Otherwise proceed and carry the notes
  forward into the orchestrator's own output.
- **NEEDS_CONTEXT** — halt, surface the question to CPTO verbatim,
  re-invoke the sub-skill with CPTO's answer as context. If the
  sub-skill asks a second time on the same topic, escalate to CPTO
  that the sub-skill appears stuck.
- **BLOCKED** — halt, surface the reason to CPTO verbatim. **Never
  fall through to built-in knowledge silently.** If Working state
  reports partial files, offer CPTO the choice to keep or roll back
  before deciding how to proceed.

**Parsing is narrative.** The orchestrator is an LLM reading prose,
not a regex engine. This matches how Superpowers handles sub-agent
status and keeps Squad consistent with Claude Code's "trust the
agent" philosophy — simple prose rules over machine-parseable
formats.

**When to use orchestration vs chaining.** Use **chaining** for
linear forward flows where each skill triggers the next (e.g.,
`product-brief` → `architecture-record` → inner cycle), including
the fan-out case where one skill declares multiple independent
next-chains (each chain runs standalone, nothing synthesizes
them). Use **orchestration** when one skill needs outputs from
multiple upstream skills that may or may not exist and must be
synthesized into the orchestrator's own output.

**Precedent.** Superpowers' `subagent-driven-development` skill
dispatches a sequence of subagents (implementer, spec reviewer, code
quality reviewer) with exactly this status protocol and handling
pattern. Squad borrows the contract structure and adapts it from
subagent dispatch (isolated context) to sibling-skill invocation
(shared working directory) — the `Working state` field is the
adaptation. See also Superpowers' `dispatching-parallel-agents` for
the fan-out variant.

### Anti-patterns to avoid

| Anti-pattern | Why it fails | Instead |
|-------------|-------------|---------|
| Self-review | Same context, same blind spots | Use `context: fork` for independent review |
| Predefined categories in discovery | Kills ideation, constrains to author's imagination | Open-ended questions |
| Multiple-choice without escape | User may disagree with all options | Always add "Chat about this" |
| Validate your own output | Producer bias confirms own work | Separate role validates |
| Architecture in product brief | Premature solution design | Hard gate: problem space only |

## Skill Inventory

### Implemented (v0.2.0)

| Skill | Role | Type | Lines | Validated |
|-------|------|------|-------|-----------|
| `product-brief` | Product Owner | Produce | 220 | Yes — e2e test |
| `product-brief-review` | QA/Reviewer | Validate (fork) | 110 | Yes — e2e test |
| `architecture-record` | Architect | Produce | 323 | Pending |
| `architecture-record-review` | QA/Reviewer | Validate (fork) | 123 | Pending |
| `product-naming` | Designer | Produce | 521 | Yes — manual execution test |
| `product-naming-review` | Designer / QA | Validate (fork) | 200 | Yes — manual execution test |
| `design-system` | Designer | Produce | 360 | Yes — manual execution test |
| `design-system-review` | Designer / QA | Validate (fork) | 194 | Yes — manual execution test |

### Planned

Priorities below rank by **foundation completeness**, not chaining
convenience. `squad-process-model.md` names four durable foundations
of equal rank — Product, Architecture, Design System, and Product
Identity — against which every downstream gate validates. Product
and Architecture already have produce+review skills shipped; Design
System and Product Identity have nothing, leaving the inner-cycle
Design Gate without a standard to read and leaving naming unbound
to any artifact. Closing those two missing foundations outranks
extending foundations that already exist, and both outrank gates
(which presuppose their foundations) and outer/continuous skills
(which presuppose a working inner cycle).

**Design-skills family.** The Design System foundation is produced
by a two-skill pair (`design-system` + `design-system-review`)
following the shipped produce/validate pattern. Research happens
inline inside the produce skill (WebFetch/WebSearch plus built-in
knowledge); there are no separate helper skills. This supersedes
earlier notes that described a four-skill family with
`design-research-*` helpers — those were removed per the
2026-04-19 design spec Decision 4 (shipped-pair shape proves inline
research works; coordination cost of separate helpers outweighed
payoff for a solo operator).

**Product Identity skills.** The Product Identity foundation is
produced by a separate pair of skills — `product-naming` and
`product-naming-review` — which are not part of the design-skills
family. `design-system` invokes `product-naming` as a sub-skill
when the brief has no name, crossing the foundation boundary (skill
invocation is orthogonal to foundation membership). Both pairs are
shipped.

Bottom-up build order: Product Identity first (shipped), then the
`design-system` produce/validate pair (shipped). No helper skills
in this family.

| Skill | Role | Foundation | Type | Priority |
|-------|------|-----------|------|----------|
| `product-backlog` | Product Owner | Product | Produce | 4 — extends shipped Product foundation |
| `product-gate` | QA / Reviewer | Product | Validate | 5 — validates Product foundation |
| `architecture-gate` | Architect | Architecture | Validate (fork) | 6 — validates Architecture foundation |
| `design-gate` | Designer | Design System | Validate (fork) | 7 — validates Design System foundation |
| `qa-gate` | QA / Reviewer | — | Validate | 8 — outer-cycle gate (also covers Product Identity drift via terminology checks) |
| `delivery-record` | PO + Designer | — | Produce | 9 — outer cycle |
| `knowledge-log` | All roles | — | Produce | 10 — continuous |
| `health-register` | Dev + Architect | — | Produce | 11 — continuous |

Notes:
- `product-naming` lives under Designer role on craft grounds
  (naming techniques, phonetic and linguistic sensitivity, creative
  generation), with legal and IP authority absorbed by the CPTO at
  approval time. The artifact lives at
  `${user_config.product_home}/identity/naming.md` and is the sole
  member of the Product Identity durable foundation.
- Product Identity has no dedicated inner-cycle gate. The QA Gate
  covers naming consistency (capitalization, short forms, forbidden
  variants) as part of its terminology checks. Human CPTO approval
  at artifact creation is the primary check; QA Gate catches drift
  during feature execution.
- `architecture-record-review` validates the architecture record
  artifact (structural completeness, fitness, brief alignment).
  `architecture-gate` is a separate inner-cycle skill that validates
  implementation specs against the architecture record during the
  Superpowers execution loop.
- SKILL.md files that exceed the 500-line cap use supporting files
  (guides, templates) per the shipped `architecture-record` pattern
  (`survey-guide.md`, `record-guide.md`). Expect design-family skills
  to need supporting files — the scope is substantially broader than
  product-brief or architecture-record.

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
technique per skill.

The **Status** column reflects how much the methodology has been
validated:

- **Validated** — skill is shipped and tested; methodology proven
  in practice.
- **Designed** — spec exists with methodology grounded in research;
  implementation pending.
- **Hypothesis** — pre-spec working notes; expect material changes
  when the skill is actually designed. The brainstorm-and-research
  process may invalidate or replace these techniques entirely. Do
  not treat hypothesis-status methodologies as authoritative — they
  are placeholders to be revisited per skill.

| Skill | Status | Primary Technique |
|-------|--------|------------------|
| `product-brief` | Validated | MITRE 3-phase canvas + JTBD + Shape Up appetite |
| `product-backlog` | Hypothesis | Epic hypothesis + Given/When/Then + ICE scoring |
| `architecture-record` | Validated | C4 Model L1+L2 + Nygard ADR |
| `architecture-gate` | Hypothesis | Fitness functions + boundary checklist |
| `product-naming` | Designed | Igor 4-category taxonomy (functional / invented / experiential / evocative) + Watkins SMILE/SCRATCH rubric + Meyerson 7-stage pipeline + parallel subagent generation (4 differentiated lenses, Lexicon decoy-brief analogue) |
| `design-system` | Validated | Consultant-posture synthesis into a 7-category adaptive doc (principles, voice, terminology, IA, interaction, visual, surface conventions). Inline research via WebFetch/WebSearch (peer lookups, platform/CLI/API/docs standards, JTBD-traced audience). SAFE/RISK framing on visual language + voice/tone; plain one-line rationale on other decisions. Companion HTML preview from single adaptive template. |
| `design-gate` | Hypothesis | Confidence-tier checklist + WCAG essentials + per-surface routing (GUI, CLI, docs, API error voice) |
| `qa-gate` | Hypothesis | BDD scenarios + exploratory testing charters |
| `delivery-record` | Hypothesis | Delta changelog + narrative arc demo |
| `knowledge-log` | Hypothesis | Typed entries + staleness pruning |
| `health-register` | Hypothesis | DORA metrics + impact/effort debt scoring |

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
