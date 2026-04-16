# OpenSpec Framework Analysis

Baseline assessment for building an adopted derivative framework.
Based on OpenSpec v1.2.0 (541 commits), MIT License, (c) 2024 OpenSpec Contributors.

---

## 1. The Promise (OpenSpec's Own Words)

> "AI-native system for spec-driven development."

The marketed value proposition:
- Agree on what to build (specs) before writing code
- Fluid, iterative, brownfield-first — no phase gates, learn as you build
- Dual-directory model: specs (source of truth) + changes (proposals)
- Delta specs for existing codebases: ADDED/MODIFIED/REMOVED requirements
- Dynamic instruction generation from project context + schema + rules
- 26 AI tool adapters: Claude Code, Cursor, Windsurf, Copilot, Gemini, etc.
- Custom schemas: define your own artifact sequences and workflows
- Archive with spec merge: changes become history, specs stay current

The framework positions itself as a **contract engine** — making human-AI
agreement explicit before implementation begins, and keeping the shared
understanding (specs) current as changes complete.

---

## 2. What It Actually Is

OpenSpec is **two things** packaged together:

**A CLI tool** — ~22,000 lines of TypeScript (non-test) that manages specs,
changes, schemas, and artifact state. The CLI provides commands for status
queries, instruction generation, spec validation, archive with delta merge,
and multi-tool skill installation. This is real engineering with proper
parsing, validation, and file management.

**A skill generation system** — 12 workflow templates (~3,690 lines) that
produce tool-specific instruction files for 26 AI coding assistants. Each
template is a TypeScript module exporting structured LLM instructions. The
CLI dynamically enriches these instructions with project context, per-artifact
rules, and template structures at runtime.

There is no orchestrator, no state machine, no compiled binary, no database.
All state is on the filesystem — artifact existence is the progress tracker.
The LLM is the executor; the CLI is the query layer.

### What distinguishes it from other frameworks

**Specs as source of truth.** Unlike every other framework in our analysis,
OpenSpec maintains a persistent, structured description of system behavior
(`openspec/specs/`) that evolves as changes complete. This is the closest
thing to a living product specification in the landscape.

**Delta-based change model.** Changes don't modify specs directly. They
propose deltas (ADDED/MODIFIED/REMOVED requirements) in an isolated
directory. Multiple changes can progress in parallel. On archive, deltas
merge into main specs cleanly.

**Dynamic instruction enrichment.** Instead of hardcoded SKILL.md files,
instructions are assembled at runtime from three layers: project context
(from config.yaml), per-artifact rules, and schema templates. Edit the
config, and every AI skill immediately sees updated context.

---

## 3. Top-Level Architecture

### Installation layout

```
project/
├── openspec/                          # OpenSpec workspace
│   ├── config.yaml                    # Project context + rules + schema selection
│   ├── specs/                         # Source of truth: current system behavior
│   │   ├── auth/spec.md              # Structured requirements + scenarios
│   │   ├── payments/spec.md
│   │   └── ui/spec.md
│   └── changes/                       # Proposed modifications (one folder per change)
│       ├── add-dark-mode/
│       │   ├── .openspec.yaml        # Metadata (schema, created date)
│       │   ├── proposal.md           # Why: intent, scope, impact
│       │   ├── design.md             # How: architecture, decisions, risks
│       │   ├── tasks.md              # Steps: implementation checklist
│       │   └── specs/                # What: delta specs
│       │       └── ui/spec.md        # ADDED/MODIFIED/REMOVED requirements
│       └── archive/                   # Completed changes (full context preserved)
│           └── 2025-01-24-add-dark-mode/
│
├── .claude/skills/                    # Generated skills (Claude Code)
│   ├── openspec-propose/SKILL.md
│   ├── openspec-apply-change/SKILL.md
│   ├── openspec-explore/SKILL.md
│   └── openspec-archive-change/SKILL.md
├── .cursor/skills/                    # Generated skills (Cursor)
└── .windsurf/workflows/               # Generated skills (Windsurf)
```

### CLI architecture (~22K lines TypeScript)

```
src/
├── cli/index.ts              # Command registration (commander.js)
├── commands/
│   ├── change.ts             # Change CRUD operations
│   ├── spec.ts               # Spec operations
│   ├── validate.ts           # Spec validation engine
│   ├── workflow/
│   │   ├── status.ts         # State detection → JSON
│   │   └── instructions.ts   # Dynamic instruction assembly
│   └── ...
├── core/
│   ├── artifact-graph/
│   │   ├── graph.ts          # Kahn's algorithm for build order
│   │   ├── state.ts          # File-existence state detection
│   │   ├── schema.ts         # Schema validation (Zod)
│   │   └── instruction-loader.ts  # Context + rules + template assembly
│   ├── archive.ts            # Delta merge logic
│   ├── project-config.ts     # config.yaml parsing
│   ├── templates/workflows/  # 12 skill templates (3,690 lines)
│   ├── command-generation/   # 26 tool adapters
│   └── validation/           # Spec format validation
└── utils/                    # File system, matching, parsing
```

### Artifact dependency graph

```
         proposal
        (root node)
             │
   ┌─────────┴─────────┐
   │                    │
   ▼                    ▼
 specs               design
(requires:          (requires:
 proposal)           proposal)
   │                    │
   └─────────┬──────────┘
             │
             ▼
           tasks
        (requires:
        specs, design)
```

Dependencies are **enablers, not gates**. You can create artifacts in any
order (specs and design both depend only on proposal), but the graph shows
what's possible to create given current state.

### State detection

No database. State is derived from filesystem:

```typescript
// state.ts — completion detection
detectCompleted(changePath): CompletedArtifact[] {
  // For each artifact in schema:
  //   Check if `generates` pattern matches existing files
  //   e.g., "proposal.md" → exists? → done
  //   e.g., "specs/**/*.md" → any matches? → done
}

// graph.ts — next-step computation (Kahn's algorithm)
getNextArtifacts(completed): Artifact[] {
  // Return artifacts whose dependencies are all in completed set
}
```

Progress is: artifact exists → done. Task-level progress tracked via
checkbox parsing in tasks.md (`- [ ]` vs `- [x]`).

### Dynamic instruction assembly

When a skill invokes `openspec instructions <artifact> --change <name>`:

```
1. Load schema → artifact definition (template, instruction, requires)
2. Load config.yaml → project context + per-artifact rules
3. Load dependency artifacts → read completed files for context
4. Assemble instruction:
   <context> project context from config </context>
   <rules> artifact-specific rules from config </rules>
   <template> artifact template from schema </template>
   <dependencies> content of completed prerequisite artifacts </dependencies>
5. Return as JSON → skill parses and follows
```

The LLM never sees hardcoded instructions — they're assembled from
project-specific configuration every time.

---

## 4. The Real Value: Contracts Before Code

### The core insight

OpenSpec solves a problem that the other frameworks don't address:
**explicit agreement on what to build before building it.** The spec is
a contract between human and AI — structured requirements with testable
scenarios that define system behavior.

This is fundamentally different from Superpowers' brainstorming (which
produces a design doc) or GSD-2's discuss phase (which captures context).
OpenSpec's specs are formal: requirements use SHALL/MUST, scenarios use
GIVEN/WHEN/THEN, and a validation engine checks structural compliance.

### What each component contributes

**Specs** — persistent, structured, evolving descriptions of system behavior.
Organized by domain (auth, payments, UI). Each requirement has testable
scenarios. This is the artifact that no other framework produces or maintains.

**Changes** — isolated proposals with four interdependent artifacts. The
separation of why (proposal), what (delta specs), how (design), and steps
(tasks) prevents the common failure where implementation starts before
requirements are clear.

**Delta specs** — the brownfield innovation. Instead of rewriting full specs,
you describe what's changing. ADDED requirements get appended, MODIFIED
replace existing, REMOVED get deleted. This makes spec evolution tractable
for existing codebases.

**Archive** — completed changes with full context (proposal, specs, design,
tasks) preserved as history. Delta specs merge into main specs. The archive
is a decision log — you can trace why any requirement exists.

**Dynamic instructions** — project context and per-artifact rules injected
at runtime. Every team gets customized instructions without modifying
templates. This eliminates the "one skill for all projects" problem.

---

## 5. What Works Well

### Pattern: specs as living source of truth

The dual-directory model (specs/ vs changes/) with delta merge is
architecturally elegant. Specs are always current. Changes are isolated
proposals. Archive preserves history. Multiple changes can progress in
parallel without conflicts.

This is the artifact graph that Gstack lacks and that GSD-2 approximates
with its ROADMAP/PLAN/SUMMARY files. OpenSpec makes it first-class.

### Pattern: schema-driven workflow

The artifact dependency graph (proposal → specs + design → tasks) is
defined in a YAML schema, not hardcoded. Teams can create custom schemas
(e.g., research-first: research → proposal → tasks, skipping specs/design).
Kahn's algorithm computes build order. State detection is filesystem-based.

This is composable and extensible without touching code.

### Pattern: dynamic instruction enrichment

Three-layer instruction assembly (context + rules + template) means skills
adapt to the project. A TypeScript/React project gets different instructions
than a Python/Django project — same schema, different context in config.yaml.

This solves the "generic skill" problem that plagues Gstack and Superpowers,
where every skill says the same thing regardless of project context.

### Pattern: delta-based spec evolution

ADDED/MODIFIED/REMOVED/RENAMED as structured operations on specs is the
key innovation for brownfield work. The archive process applies these
operations to merge deltas into main specs. This is version control for
requirements, not just code.

### Pattern: change isolation with parallel progress

Each change is a directory with independent artifacts. Changes don't
conflict until archive time. Multiple features can be designed and
specified simultaneously. Bulk-archive handles conflicts when two changes
touch the same spec.

### Pattern: tool-agnostic skill generation

One template, 26 tool adapters. OpenSpec generates Claude Code skills,
Cursor commands, Windsurf workflows, and 23 other formats from the same
TypeScript source. This is the widest tool support in our analysis.

---

## 6. What to Avoid

### Architectural gaps

**No execution orchestration.** OpenSpec's apply phase says "work through
tasks, mark complete as you go" — but the LLM decides how. There's no
fresh context per task, no model selection, no verification gates, no
crash recovery. The entire apply phase runs in a single LLM session with
accumulating context. GSD-2's per-unit dispatch is architecturally superior
for execution.

**No behavioral discipline.** The skill templates provide step-by-step
instructions and guardrails ("Do NOT copy context blocks into artifacts")
but no rationalization counters, no pressure testing, no anti-sycophancy
enforcement. Superpowers' insight about preventing LLM failure modes is
absent.

**No code review.** The verify-change skill checks completeness,
correctness, and coherence through heuristics, but this is a self-review —
the same agent evaluating its own work. No specialist dispatch, no
cross-model review, no two-stage review.

**No backlog or prioritization.** OpenSpec manages individual changes
but has no concept of a product backlog, feature priorities, or a grooming
cycle. You decide what changes to create. OpenSpec manages the lifecycle
of each change independently.

**Spec quality depends on the LLM.** The validation engine checks
structural compliance (GIVEN/WHEN/THEN format, requirement headings,
scenario nesting) but can't validate semantic quality. A spec that says
"The system SHALL work correctly" passes validation but is useless.

**Archive merge is fragile for complex changes.** MODIFIED requirements
must include the full updated content — partial content "loses detail at
archive time." The schema warns about this but the system can't prevent
it. A poorly written MODIFIED delta silently overwrites a good existing
requirement. [Updated 2026-04-16: as of v1.3.0, two specific
silent-corruption paths are now caught by structural validation
(commit c8e2072) — delta headers leaking into main specs, and
requirement blocks outside the Requirements section. Semantic
fragility still remains.]

### Design tensions

**Fluid vs. traceable.** "Work on what makes sense" means artifacts can be
created in any order. But if design.md is written before specs, the design
may not match the requirements. The dependency graph marks what's possible,
not what's recommended.

**Brownfield vs. formal.** Delta specs are powerful for existing codebases
but require the base specs to exist. For projects without prior specs,
there's no efficient way to bootstrap — you'd need to write full specs
for every existing capability before delta-based changes work.

**Dynamic instructions vs. debuggability.** Instructions assembled at
runtime from three layers are powerful but hard to debug. When the LLM
does the wrong thing, which layer caused it? The context? The rules? The
template? The instruction loader? Hardcoded skills are less flexible but
easier to inspect.

---

## 7. Extractable Techniques

### Specs as living source of truth

Persistent, structured, evolving description of system behavior. Organized
by domain. Requirements with testable scenarios. Maintained through delta
merges from completed changes. This is the artifact pattern our framework
needs.

### Delta-based spec evolution

ADDED/MODIFIED/REMOVED/RENAMED as structured operations on specs. Changes
are isolated proposals. Archive applies deltas to merge into main specs.
Version control for requirements, not just code.

### Schema-driven artifact sequences

Artifact dependency graph defined in YAML. Kahn's algorithm for build
order. File-existence for state detection. Custom schemas for different
workflow types. Composable, extensible, no hardcoded sequences.

### Dynamic instruction enrichment

Three-layer assembly: project context (config.yaml) + per-artifact rules +
schema templates. Skills adapt to project without code changes. Every team
gets customized instructions.

### Change isolation with parallel progress

Each change is a directory with independent artifacts. Multiple changes
progress simultaneously. Conflict detection at archive time when changes
touch the same spec.

### Archive as decision log

Completed changes preserved with full context (proposal, specs, design,
tasks). Traceable history: you can answer "why does this requirement exist?"
by reading the archived change that introduced it.

### Tool-agnostic skill generation

One source template, multiple tool adapters. TypeScript modules export
structured data (name, description, instructions), adapters serialize to
tool-specific formats. Widest tool support pattern.

---

## 8. Comparison with Other Frameworks

| Dimension                    | Gstack              | Superpowers         | GSD-2               | PM Skills           | OpenSpec             |
|------------------------------|----------------------|---------------------|----------------------|---------------------|----------------------|
| **Architecture**             | Prompts + browser    | Prompts             | TS orchestrator      | Prompts + validators | CLI + skill gen      |
| **Core codebase**            | ~15K SKILL.md        | ~3.7K SKILL.md      | ~93K TypeScript      | ~20K SKILL.md       | ~22K TypeScript      |
| **Domain**                   | Software eng         | Dev discipline       | Execution            | Product mgmt        | Specification        |
| **Persistent artifacts**     | Partial filesystem   | Plan files + git     | SQLite + markdown    | None                | Specs + changes + archive |
| **Artifact graph**           | None                 | None                 | State machine phases | Three-tier hierarchy | Schema-driven DAG    |
| **Execution model**          | LLM follows prompts  | LLM follows prompts  | System dispatches    | LLM follows prompts | LLM follows dynamic instructions |
| **Context management**       | Session accumulates   | Session accumulates  | Fresh per unit       | Session accumulates | Session accumulates  |
| **State tracking**           | Filesystem protocols  | Git checkboxes      | SQLite + dual-path   | None                | File existence + checkboxes |
| **Spec management**          | None                 | None                | CONTEXT.md per milestone | None             | Living specs with delta merge |
| **Change isolation**         | None                 | None                | Git worktrees        | None                | Change directories   |
| **Review**                   | Specialist dispatch   | Two-stage review    | Verification cmds    | Human only          | Self-review (verify) |
| **Behavioral discipline**    | Checklists           | Rationalization counters | System prompt    | Pedagogy            | Guardrails only      |
| **Backlog management**       | None                 | None                | None                 | Skills only (no state) | None              |
| **Tool support**             | 3 platforms          | 6 platforms         | Own runtime          | 16+ platforms       | 26 tool adapters     |
| **License**                  | MIT                  | MIT                 | MIT                  | CC BY-NC-SA 4.0    | MIT                  |

### Key philosophical differences

**Gstack** builds specialist personas to enforce quality checklists.
**Superpowers** prevents the LLM from rationalizing past discipline.
**GSD-2** controls the LLM's execution environment deterministically.
**PM Skills** teaches humans while structuring AI's questions.
**OpenSpec** makes human-AI agreement explicit through formal specifications.

Each framework optimizes for a different failure mode:
- Gstack: "Claude skips checks" → enforce checks
- Superpowers: "Claude rationalizes past discipline" → block rationalizations
- GSD-2: "Claude drifts without control" → control the environment
- PM Skills: "The PM doesn't know which framework" → guide the choice
- OpenSpec: "Human and AI disagree on what to build" → formalize the contract

---

## 9. Promise vs Reality Assessment

### What the promise gets right

- **"Spec-driven development"** — the spec system is real and well-designed.
  Structured requirements with scenarios, delta operations, archive merge.
- **"Brownfield-first"** — delta specs are genuinely useful for existing
  codebases. ADDED/MODIFIED/REMOVED is the right model.
- **"Fluid not rigid"** — artifacts can be created in any order. No phase
  gates. Schema-driven, not hardcoded.
- **"26 AI tools"** — tool adapters exist and generate correct formats.
- **Dynamic instructions** — config.yaml changes immediately affect skill
  behavior. This is a real improvement over static skills.

### What the promise overstates

- **"AI-native"** — the CLI is a traditional tool. The "AI-native" part is
  skill generation, which is a build step, not a runtime feature. The actual
  workflow runs in whatever AI tool you choose.
- **Execution quality** — "apply" is "work through tasks" with no
  orchestration, no verification gates, no cost tracking. The planning
  artifacts are excellent; the execution infrastructure is absent.
- **Spec bootstrapping** — for projects without existing specs, there's
  significant upfront cost. The framework assumes you'll create specs
  incrementally through changes, but the first change for an existing
  system still requires describing current behavior.

### What the promise doesn't mention

- **No backlog or prioritization.** Changes are independent units with no
  product-level management.
- **No execution orchestration.** The apply phase has no per-task dispatch,
  fresh context, model selection, or verification beyond checkbox parsing.
- **No behavioral discipline.** Guardrails in skills but no rationalization
  prevention or pressure testing.
- **Session-bound execution.** Unlike GSD-2, the entire apply phase runs
  in one session with accumulating context.

---

## 10. Relevance to Our Framework

### The critical contribution

OpenSpec provides the **artifact model** our framework needs. The pattern
of specs (living truth) + changes (isolated proposals) + archive (decision
history) is the most mature artifact management system in our analysis.
None of the other four frameworks maintain structured, evolving system
specifications.

### The integration opportunity

OpenSpec's spec layer sits naturally between PM Skills' product artifacts
(PRDs, roadmaps) and the execution loop (Superpowers/GSD-2):

```
Product vision                                                  Feature shipped
     |                                                               |
     |  [PM Skills]    [OpenSpec]           [Execution]              |
     |  discovery,     specs, changes,      brainstorm→ship          |
     |  strategy,      delta merge,         Superpowers discipline   |
     |  prioritization proposal→design→task GSD-2 orchestration      |
     |                                                               |
  "Build X" → discover → prioritize → propose → spec → design → plan → execute → review → ship → archive
```

### What we adopt

1. **Specs as living truth** — persistent, structured system behavior
   descriptions that evolve through delta merges
2. **Change isolation** — proposals with interdependent artifacts in
   separate directories, mergeable at completion
3. **Schema-driven workflows** — YAML-defined artifact sequences with
   dependency graphs
4. **Dynamic instruction enrichment** — project context + rules injected
   at runtime, not hardcoded
5. **Archive as decision log** — completed changes preserved with full
   context for traceability

### What we don't adopt

6. **The CLI as the orchestration layer** — our framework runs on Claude
   Code's platform, not a separate CLI
7. **Session-bound execution** — we need GSD-2's fresh context per unit,
   not OpenSpec's single-session apply
8. **Verification by checkbox only** — we need Superpowers' evidence-based
   verification and Gstack's specialist review

---

## 11. Summary

OpenSpec is the most architecturally interesting framework in our analysis
for the artifact management problem. Its dual-directory model (specs +
changes), delta-based spec evolution, and schema-driven workflows provide
a robust foundation for managing what to build before building it.

The framework's weakness is everything after the spec is written. The apply
phase is a single LLM session with no orchestration, no verification
gates, and no behavioral discipline. OpenSpec is excellent at the contract
layer but absent at the execution layer.

For our framework, OpenSpec fills a critical gap: **how to maintain a
living description of the system that evolves as features ship.** This is
the artifact layer between the product backlog (what to build next) and
the execution loop (how to build it). Combined with GSD-2's orchestration,
Superpowers' discipline, and Gstack's review patterns, it forms the
complete picture:

```
Backlog → Groom → Propose → Spec → Design → Plan → Execute → Review → Ship → Archive
   |                  |                              |                          |
   |           [OpenSpec artifacts]           [Superpowers discipline]          |
   |           [Schema-driven flow]          [GSD-2 orchestration]             |
   |                                         [Gstack review]                   |
   |                                                                           |
   [OUR FRAMEWORK: persistent backlog + grooming cycle + handoff]              |
   └───────────────────────────── specs updated on archive ────────────────────┘
```

MIT licensed — derivative works permitted with attribution.

---

## Update 2026-04-16 (two weeks after baseline)

Baseline was v1.2.0 at 541 commits. Repo has since shipped **v1.3.0**
(tag `9b5007d`, Apr 12) plus follow-up fixes through Apr 15. Activity
falls into three buckets: cross-platform CLI stabilization, tooling
breadth, and a substantial design exploration of workspace / multi-repo
planning that is **not yet implemented**.

### Weaknesses from prior analysis: what moved

**Partially addressed — "Spec quality depends on the LLM" / "Archive
merge is fragile for complex changes."**
Originally (§6): *"The validation engine checks structural compliance
... but can't validate semantic quality"* and *"A poorly written
MODIFIED delta silently overwrites a good existing requirement."*
Commit `c8e2072` (fix: detect hidden requirements in main specs) adds
`src/core/parsers/spec-structure.ts` — a new validator that flags two
previously-silent failure modes in main specs: delta headers
(`## ADDED/MODIFIED/REMOVED Requirements`) leaking into canonical
specs, and `### Requirement:` blocks outside the `## Requirements`
section. The validation runs during `archive` and `specs-apply`, so a
malformed merge now raises an issue instead of silently corrupting the
main spec (+463 lines of code and tests; 11 files touched). This does
not validate *semantic* quality ("SHALL work correctly" still passes),
but it closes one specific archive-merge fragility path called out in
the baseline. **Partial**, not complete.

**Partially addressed — "No backlog or prioritization" at the
cross-boundary level.**
Originally (§6 and §9): *"Changes are independent units with no
product-level management."* Commits `cd5e493` and `c0f2904` add
~3,200 lines of exploration docs under `openspec/explorations/`
(workspace-architecture, workspace-roadmap, workspace-user-journeys,
workspace-ux-simplification, explore-workflow-ux). They introduce the
**initiative** primitive — a shared planning object above per-repo
changes, with stable project identifiers linking initiative-level
plans to repo-local `changes/`. This is explicitly exploratory; no
code ships for it yet. The roadmap is staged (Phase 1: nested spec
paths; Phase 2: thin cross-repo coordination; Phase 3: team-shared
coordination; Phase 4: governance). It signals where the project is
heading, not where it is. **Exploration only.**

**Not addressed — execution / discipline / review gaps.**
The baseline's core critique (§6) — no execution orchestration, no
behavioral discipline, no code review beyond self-verify, session-bound
apply — remains untouched. Nothing in the two-week window shifts the
execution story. OpenSpec continues to be strong at the contract layer
and absent at the execution layer, exactly as summarized in §11.

### Stale or imprecise claims corrected inline

No factual claim in the baseline is wrong as of 2026-04-16, but one is
incomplete and has been annotated inline above in §6 ("Archive merge is
fragile for complex changes") with an `[Updated 2026-04-16: ...]` note
acknowledging that two specific silent-corruption paths are now caught
by commit `c8e2072`. The `openspec/` tree in §3 does not include the
`explorations/` subdirectory, but that is a **local convention inside
OpenSpec's self-hosted workspace**, not a framework primitive, so §3 is
left as-is.

### New observations from the two-week window

**Cross-platform hardening is the dominant theme.**
Six of the shipped fixes are platform/IO correctness: `1445282`
(PowerShell UTF-16 BOM preservation, opt-in shell completion),
`4df6a48` (firewalled-env telemetry suppression with 1s timeout and
synthetic 204), `a18d992` (ora spinner leaks to stderr under `--json`,
breaking AI agents that combine streams), `caafd7c` (pi.dev
colon→hyphen command transforms), `7d07101` + `93f7b79` (canonical
path handling via native realpath), `765df47` (bare `.github/` no
longer misdetects Copilot). These are the signs of a CLI moving from
"works on my machine" to "works in CI, Windows, locked-down
enterprise, and AI-agent stdout pipes." Relevant to Squad only as a
warning: any CLI we ship eats this cost later; better to avoid
shipping one.

**Tool coverage continues expanding.**
Four new AI tool integrations in this window: IBM Bob (`94d651d`),
JetBrains Junie (`af0b341`), Lingma (`5ac1e12`), ForgeCode
(`ea6f380`). Baseline table (§8) says "26 tool adapters" — that
number is now higher. Pattern holds: one TypeScript adapter per tool,
registered in `CommandAdapterRegistry`. Reinforces the baseline
observation that tool-agnostic skill generation is OpenSpec's widest
moat.

**Apply instructions got a real fix, not just a cosmetic one.**
Commit `7fe45ca` (Fix apply instructions for glob artifact outputs)
moves artifact-output resolution into a dedicated
`src/core/artifact-graph/outputs.ts` module and enforces "file-only
literal artifact outputs." This is a meaningful cleanup of the
instruction-assembly layer described in §3. Doesn't close the
execution-orchestration gap but does suggest the apply workflow is
getting incremental attention.

### Signal for Squad

Two useful data points:

1. **OpenSpec itself is acknowledging the gap between single-repo and
   cross-boundary planning.** The initiative + linked-change primitive
   they are exploring is almost exactly the multi-artifact coordination
   problem Squad's durable foundations (Product, Architecture, Design
   System, Product Identity) are meant to solve. The OpenSpec team is
   reaching for a **coordination workspace** as a neutral home for
   cross-repo plans. Squad's "long-lived artifacts shared across
   sessions, branches, and agents" is the same intuition arriving from
   a different angle. Worth watching whether their Phase 2 coordination
   layer ships — it's a natural reference for how Squad's shared
   artifact layer might be addressable by stable IDs.

2. **The baseline recommendation to adopt the artifact model but not
   the CLI still holds.** Nothing in this window changes the split
   identified in §10: adopt specs-as-living-truth, delta evolution,
   change isolation, schema-driven workflows, dynamic instruction
   enrichment, and archive-as-decision-log. Skip the
   CLI-as-orchestration-layer, session-bound execution, and
   verify-by-checkbox. The v1.3.0 direction (more tools, more
   platforms, more specification ergonomics) is consistent with the
   baseline positioning — OpenSpec is doubling down on being the
   contract engine, not becoming an execution harness.
