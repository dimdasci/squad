# GSD-2 Framework Analysis

Baseline assessment for building an adopted derivative framework.
Based on GSD-2 v2.64.0 (commit aedf853), MIT License, (c) 2026 Lex Christopherson.

---

## 1. The Promise (GSD's Own Words)

> "The orchestration layer between you and AI coding agents. It handles
> planning, execution, verification, and shipping so you can focus on what
> to build, not how to wrangle the tools."

The marketed value proposition:
- Autonomous execution: "One command. Walk away. Come back to a built project
  with clean git history."
- State machine orchestration: deterministic phase progression, not prompt hopes
- Fresh context per unit: 200k-token window, no context pollution across tasks
- Crash recovery: resume from any interruption with full context reconstruction
- Cost tracking: per-unit token/cost metrics, budget ceilings, model selection
- Parallel milestones: multiple workers on independent milestones via worktrees
- Provider-agnostic: Anthropic, OpenAI, Google, Mistral, Ollama, OpenRouter
- 23 bundled extensions: browser automation, web search, background jobs, etc.
- Headless mode: CI/automation without interactive TUI

The framework positions itself as a "real coding agent" — implying it moved
beyond prompt injection (v1) into a system that controls the execution
environment rather than persuading the LLM to follow instructions.

---

## 2. What It Actually Is

GSD-2 is **three things** packaged together:

**A TypeScript orchestrator** — ~93,000 lines of non-test TypeScript (287,000
total including tests) built on top of "Pi SDK" (an agent harness). The
orchestrator derives state from disk, selects the next unit of work via
declarative dispatch rules, constructs focused prompts with pre-inlined
context, launches fresh LLM sessions per unit, and persists results back
to disk. This is real engineering — state machines, SQLite, git worktree
management, crash recovery, cost tracking.

**A prompt library** — 35 markdown prompt templates (~2,655 lines) defining
what the LLM sees at each phase (discuss, research, plan, execute, complete,
validate). Unlike Gstack or Superpowers, these prompts are not user-invoked
skills — they are internal dispatch targets assembled programmatically by the
orchestrator. The LLM never chooses which prompt to load.

**An extension ecosystem** — 23 bundled extensions (browser-tools, web search,
background shell, subagent dispatch, GitHub sync, voice input, MCP client,
etc.) loaded via manifest-driven registry with dependency resolution.
Extensions register tools, hooks, and commands into the Pi SDK runtime.

The "walk away and come back" claim is architecturally real. The state machine
on disk + fresh context per unit + crash recovery means the system can
genuinely operate without human presence for extended periods. Whether the
*output quality* justifies that autonomy is a separate question.

---

## 3. Top-Level Architecture

### Installation layout

```
gsd-pi (npm global)
├── src/
│   ├── cli.ts                    # CLI entry (after env setup)
│   ├── loader.ts                 # Two-stage boot (env vars before imports)
│   ├── resource-loader.ts        # Extension discovery, sync, loading
│   ├── resources/extensions/
│   │   ├── gsd/                  # Core extension (93K lines)
│   │   │   ├── auto.ts           # Main auto-mode loop (1,550 lines)
│   │   │   ├── auto-dispatch.ts  # Declarative dispatch rules (785 lines)
│   │   │   ├── auto-prompts.ts   # Prompt builders (1,950 lines)
│   │   │   ├── auto-worktree.ts  # Git worktree lifecycle (2,000 lines)
│   │   │   ├── auto-post-unit.ts # Verification gates (988 lines)
│   │   │   ├── auto-recovery.ts  # Crash recovery (615 lines)
│   │   │   ├── state.ts          # State derivation (1,627 lines)
│   │   │   ├── gsd-db.ts         # SQLite schema + queries (2,250 lines)
│   │   │   ├── prompts/          # 35 markdown templates (2,655 lines)
│   │   │   └── tools/            # 11 LLM-callable tools (2,510 lines)
│   │   ├── browser-tools/        # Playwright automation (13K lines)
│   │   ├── search-the-web/       # Web search + Jina reader (3K lines)
│   │   ├── bg-shell/             # Background process management (3.5K lines)
│   │   └── ... (20 more extensions)
│   └── native/                   # Rust N-API bindings (grep, glob, ast, etc.)
├── dist/                         # Compiled output
└── package.json                  # gsd-pi on npm
```

### State machine

GSD's core innovation: a **disk-driven state machine** where no state lives
in memory across units.

```
.gsd/
├── STATE.md                 # Phase snapshot (derived, not source of truth)
├── PROJECT.md               # Living project description
├── DECISIONS.md             # Append-only architectural decisions
├── KNOWLEDGE.md             # Cross-session learned rules
├── PREFERENCES.md           # Model selection, budget, verification config
├── .gsd.db                  # SQLite (milestones/slices/tasks/evidence)
├── milestones/
│   └── M001/
│       ├── M001-CONTEXT.md  # Requirements from discuss phase
│       ├── M001-RESEARCH.md # Codebase + ecosystem findings
│       ├── M001-ROADMAP.md  # Slice decomposition with checkboxes
│       ├── M001-VALIDATION.md
│       └── slices/
│           └── S01/
│               ├── S01-PLAN.md     # Task decomposition
│               ├── S01-SUMMARY.md  # Completion narrative
│               ├── S01-UAT.md      # Acceptance test script
│               └── tasks/
│                   ├── T01-PLAN.md
│                   └── T01-SUMMARY.md
├── parallel/                # Multi-worker heartbeat/signal files
└── worktrees/M001/          # Git worktree per milestone
```

### Dispatch cycle

```
1. deriveState()           — Read .gsd/ files + SQLite, determine phase
2. DISPATCH_RULES.match()  — First matching rule selects unit type + prompt
3. buildPrompt()           — Inline all relevant context into prompt
4. createSession()         — Fresh 200K-token agent session
5. injectPrompt()          — LLM executes with 11 specialized tools
6. postUnit()              — Verify artifacts, run quality gates
7. invalidateCache()       — Loop back to step 1
```

The LLM never decides what to do next. Dispatch rules make that decision based
on disk state. The LLM's job is to fill in one artifact per session.

### Dual-path state derivation

```typescript
deriveState() {
  if (isDbAvailable() && getAllMilestones().length > 0) {
    return deriveStateFromDb(basePath);   // Primary: SQLite
  }
  return deriveStateFromFiles(basePath);  // Fallback: markdown parsing
}
```

Ghost milestone detection skips directories with only metadata files and no
substantive content. 100ms memoization cache prevents re-parsing within a
single dispatch cycle.

---

## 4. The Real Value: Orchestration vs Persuasion

### The core insight

GSD-2 solves a fundamentally different problem than Gstack or Superpowers.
Those frameworks persuade the LLM to follow discipline through carefully
written instructions. GSD-2 doesn't persuade — it controls. The LLM gets
a focused prompt, 11 specialized tools, and no choice about what to work on
next.

This is a genuine architectural shift:

| Concern | Gstack/Superpowers | GSD-2 |
|---------|-------------------|-------|
| What to do next | LLM decides (with guidance) | Dispatch rules decide |
| Context management | Session accumulates | Fresh per unit |
| State persistence | Filesystem protocols (partial) | SQLite + markdown (dual-path) |
| Crash recovery | None / git history | Full context reconstruction |
| Verification | Prompt asks LLM to verify | System runs commands post-unit |
| Cost tracking | None | Per-unit metrics + budget ceiling |
| Model selection | Fixed | Complexity-based (Haiku/Sonnet/Opus) |

### What each component contributes

**The orchestrator** — the primary value. State derivation, dispatch rules,
prompt construction, verification gates, crash recovery, cost tracking. This
is infrastructure that no prompt library can replicate. ~15,500 lines of
auto-mode code alone.

**The prompt templates** — surprisingly restrained (2,655 lines total, average
76 lines per template). They focus on the task contract, not behavioral
discipline. The system prompt (system.md, 218 lines) establishes a
"craftsman-engineer" persona with anti-sycophancy rules and hard constraints,
but the heavy lifting is structural, not persuasive.

**The extension ecosystem** — genuine capabilities (Playwright browser, web
search, background processes, GitHub sync) but bolted on rather than
integrated into the workflow. Extensions register tools; the LLM decides when
to use them. No skill-activation discipline comparable to Superpowers.

**The tools** — 11 structured tools (plan-milestone, plan-slice, complete-task,
etc.) that write to SQLite + markdown atomically. The LLM calls
`gsd_complete_task` with structured parameters; the tool handles DB writes,
checkbox rendering, cache invalidation, and event logging. This prevents the
LLM from writing inconsistent state.

---

## 5. What Works Well

### Pattern: fresh context per unit

Each task gets a fresh 200K-token session with only relevant context
pre-inlined. No pollution from prior tasks. No "I already considered this"
bias. The prompt builder decides what the LLM sees, not the LLM's
accumulated conversation history.

This directly addresses the context degradation problem that Gstack and
Superpowers can't solve — both operate within a single expanding session.

### Pattern: structured tool completion

The LLM doesn't write raw markdown files. It calls `gsd_complete_task` with
typed parameters (oneLiner, narrative, verification, keyFiles, keyDecisions,
blockerDiscovered). The tool handles:
- DB transaction (milestone, slice, task, verification evidence)
- Summary rendering from template
- Plan checkbox toggling
- Cache invalidation
- Projection/manifest updates
- Event logging

State can't be inconsistent because the LLM never touches it directly.

### Pattern: declarative dispatch rules

19 rules evaluated in order, first match wins. Each rule is a pure function
of disk state — inspectable, testable, extensible without modifying
orchestration code. Safety gates (rewrite circuit breaker, missing artifact
guards, UAT verdict blocking) are built into the rules, not post-hoc checks.

### Pattern: crash recovery with context reconstruction

On crash: session lock persists with PID. On restart: detect stale lock,
read session file for tool call history, synthesize recovery briefing with
what completed, what failed, and what to do next. The LLM resumes with
full context rather than starting blind.

### Pattern: complexity-based model selection

Light tasks (docs, simple refactors) → Haiku. Standard tasks → Sonnet.
Heavy tasks (architectural, novel) → Opus. Fallback chains per phase.
Budget ceiling enforcement. This is cost optimization that prompt
frameworks can't do — they don't control which model runs.

### Pattern: git worktree isolation

One worktree per milestone. All slices commit on the milestone branch.
Squash-merge back to main gives one revertable commit per milestone.
Clean history, easy bisect, no merge conflicts between parallel milestones.

### Pattern: verification gates

Post-unit verification runs configured commands (lint, test). Auto-fix
retries (max 2) re-invoke the LLM to fix failures. If still failing,
auto-mode pauses for human review. This is platform-level enforcement,
not prompt-level asking.

---

## 6. What to Avoid

### Architectural gaps

**The LLM is a black box between dispatch and completion.** The orchestrator
controls what goes in (prompt) and validates what comes out (artifacts), but
has no visibility into what happens during execution. If the LLM wanders
off-plan, produces low-quality code, or takes a wrong approach, the system
only catches it if the verification commands fail. Code quality beyond
"tests pass" is unverified.

**No behavioral discipline for the LLM.** The system prompt says "finish
what you start" and "no sycophantic filler" but there are no rationalization
counters, no pressure-tested guardrails, no explicit failure mode prevention.
Superpowers' insight — that LLMs need active resistance to their failure
modes — is absent. GSD trusts the LLM to execute well when given focused
context, which is an improvement over accumulated context but not a
substitute for behavioral discipline.

**Extension activation is unstructured.** The system prompt lists bundled
skills in a table and says "Load the relevant skill file with the read tool
when the task matches." This is the same "LLM decides" problem that
Superpowers solves with its meta-skill. No guaranteed activation, no
structured routing.

**Reviews are absent.** There is no code review phase. The pipeline goes
discuss → research → plan → execute → complete → validate. Validation checks
that success criteria from the roadmap match actual results, but nobody
reviews the code itself. Gstack has specialist dispatch for review;
Superpowers has two-stage review (spec compliance + code quality). GSD has
verification commands (lint/test) and nothing more.

**Planning quality is unvalidated.** The planner decomposes a milestone into
slices and slices into tasks, but there's no review of the plan itself. Bad
decomposition (wrong boundaries, missing cases, incorrect dependency order)
propagates through all downstream execution. The blocker mechanism can catch
plan-invalidating problems during execution, but only reactively.

**UAT is optional and narrow.** User acceptance testing runs automated
scripts, not actual user validation. The name implies human testing but
the implementation is automated command execution. Good for regression
checks, misleading as "acceptance."

### Complexity concerns

**93,000 lines of core extension code** for a workflow orchestrator is
substantial. The auto-mode subsystem alone (auto*.ts) is 15,500 lines.
This is production-grade infrastructure but also production-grade maintenance
burden. Compare: Superpowers achieves its entire value in 3,700 lines of
SKILL.md.

**Dual-path state derivation** (SQLite + markdown fallback) means two
codepaths for every state query. Ghost milestone detection, missing summary
guards, and various edge cases add defensive complexity. The migration from
markdown-only to DB-primary is incomplete — both paths must be maintained.

**23 bundled extensions** with dependency resolution, manifest validation,
registry state, and version syncing is a plugin system. Plugin systems
accrete complexity and compatibility constraints over time. The current
2,641 commits and frequent releases (v2.52 → v2.64 in ~6 weeks) suggest
active churn.

### Design tensions

**Autonomy vs quality.** "Walk away" mode optimizes for throughput — complete
units and advance. But code quality requires judgment that verification
commands can't capture. Is this function well-designed? Is this the right
abstraction? Is this API surface correct? These questions need review, which
breaks the autonomous loop.

**Fresh context vs accumulated knowledge.** Fresh context per unit prevents
pollution but also prevents learning. If task T03 hits a pattern that T01
already solved, the T03 session starts from scratch. The KNOWLEDGE.md and
DECISIONS.md files are the workaround, but they require the LLM to
explicitly write useful entries (an unreliable expectation).

**Deterministic dispatch vs adaptive planning.** The state machine advances
linearly through phases. If execution reveals that the plan was wrong, the
blocker mechanism triggers a replan — but only for the current slice.
There's no mechanism for "this milestone's approach is fundamentally wrong,
we need to rethink." The reassess phase checks roadmap progress but can't
challenge the roadmap's premises.

---

## 7. Extractable Techniques

Genuinely novel patterns worth preserving in a derivative work:

### Disk-driven state machine

All state on filesystem (SQLite + markdown). No in-memory state across units.
Dispatch rules are pure functions of disk state. This enables crash recovery,
multi-worker coordination, and human intervention between any two units.

### Pre-inlined context injection

Prompts are constructed with all relevant content inline — no "read this
file" tool calls. The LLM starts working immediately rather than spending
tokens on orientation. The prompt builder decides what's relevant, not the
LLM.

### Structured tool completion

LLM calls typed tools (gsd_complete_task, gsd_plan_slice) instead of
writing raw files. Tools handle DB transactions, markdown rendering, cache
invalidation, and event logging atomically. State consistency is enforced
by the tool, not by LLM discipline.

### Declarative dispatch rules

19 named rules in evaluation order. Each rule: name + match function →
dispatch/stop/skip. Safety gates are rules (rewrite circuit breaker, UAT
verdict gate). Inspectable, testable, extensible without touching
orchestration code.

### Complexity-based model routing

Task complexity score → model tier mapping. Light/Standard/Heavy →
Haiku/Sonnet/Opus with fallback chains. Budget ceiling enforcement.
Cost tracking per unit with projections.

### Crash recovery with context reconstruction

Session lock + tool call history → recovery briefing. On restart, the new
session gets a synthetic context: what completed, what failed, what to
do next. No lost work, no blind restart.

### Verification evidence table

Post-task verification produces structured evidence: command, exit code,
verdict (pass/fail), duration. Stored in SQLite (verification_evidence
table) and rendered into task summaries. Auditable, queryable.

### Blocker escalation with automatic replan

During execution, if the LLM sets `blocker_discovered: true` in the task
summary, the dispatch system automatically enters replan-slice phase. The
blocker description becomes input to the replanning prompt. Systematic
escalation rather than silent failure.

---

## 8. Comparison with Gstack and Superpowers

| Dimension                    | Gstack v0.15.13.0              | Superpowers v5.0.7            | GSD-2 v2.64.0                 |
|------------------------------|--------------------------------|-------------------------------|-------------------------------|
| **Architecture**             | Prompt library + browser daemon| Prompt library                | TypeScript orchestrator + prompts + extensions |
| **Core codebase**            | ~15,000 lines SKILL.md         | ~3,700 lines SKILL.md         | ~93,000 lines TypeScript      |
| **Prompts**                  | 36 skills (user-invoked)       | 14 skills (auto-triggered)    | 35 templates (system-dispatched) |
| **Execution model**          | LLM follows instructions       | LLM follows instructions      | System dispatches, LLM executes |
| **Context management**       | Session accumulates             | Session accumulates            | Fresh per unit (200K window)  |
| **State persistence**        | Filesystem protocols (partial) | Plan files + git               | SQLite + markdown (dual-path) |
| **Review**                   | Specialist dispatch + cross-model | Two-stage (spec + quality)  | None (verification commands only) |
| **TDD enforcement**          | Mentioned, not enforced        | Iron Law with rationalization counters | Prompt instruction only |
| **Debugging methodology**    | Ad hoc                         | 4-phase systematic             | Prompt-embedded (5-point discipline) |
| **Behavioral discipline**    | Checklists + some anti-sycophancy | Rationalization counters, pressure testing | System prompt persona only |
| **Cost tracking**            | None                           | None                           | Per-unit metrics + budget ceiling |
| **Crash recovery**           | None                           | None                           | Full context reconstruction    |
| **Model selection**          | Fixed                          | Fixed                          | Complexity-based (Haiku/Sonnet/Opus) |
| **Autonomy level**           | Human-supervised per skill     | Human-supervised per skill     | "Walk away" auto-mode          |
| **Verification**             | Trust-the-LLM                  | Evidence-before-claims gate    | Post-unit command execution    |
| **Skill activation**         | User types /skill              | Meta-skill auto-triggers       | Orchestrator dispatches        |
| **Platforms**                | Claude Code, Codex, Cursor     | 6 platforms                    | Own runtime (Pi SDK)           |
| **Infrastructure**           | Browser daemon (9.7K lines TS) | Visual companion (Node.js)     | Rust N-API, SQLite, Playwright |
| **Token efficiency**         | 2.5-5x over recommended        | 1-3x over recommended          | N/A (not Claude Code skills)   |
| **License**                  | MIT                            | MIT                            | MIT                            |

### Key philosophical differences

**Gstack** is breadth-first: 36 specialists covering product, design, QA,
shipping, ops. It builds personas and hopes the LLM inhabits them faithfully.
The browser daemon is its strongest engineering contribution.

**Superpowers** is depth-first: 14 skills focused on development discipline.
It invests in making each skill resilient to LLM rationalization and pressure.
Behavioral discipline is the product.

**GSD-2** is control-first: instead of persuading the LLM to be disciplined,
it controls what the LLM sees, what it can do, and what happens next. The
system, not the LLM, manages workflow state. This is architecturally superior
for autonomy but blind to code quality beyond test results.

### What each gets right that the others miss

**Gstack's unique strength:** Specialist dispatch with fresh context for
review. Independent subagents with different checklists find different
classes of bugs. Nobody else does multi-specialist parallel review.

**Superpowers' unique strength:** Rationalization prevention. Explicit
counter-tables for every excuse the LLM uses to skip discipline. Pressure-
tested skills. The insight that LLMs need active resistance to their failure
modes is absent from both Gstack and GSD-2.

**GSD-2's unique strength:** Execution infrastructure. State machines, crash
recovery, cost tracking, complexity-based model routing, structured tool
completion. The insight that you can control the LLM's environment rather
than persuading it is absent from both Gstack and Superpowers.

### The combined picture

An ideal framework would combine:
1. GSD-2's orchestration (state machine, fresh context, structured tools)
2. Superpowers' behavioral discipline (rationalization counters, TDD enforcement)
3. Gstack's specialist review (multi-specialist parallel dispatch)

Currently, GSD-2 has the strongest infrastructure but the weakest quality
assurance. Superpowers has the strongest discipline but no orchestration.
Gstack has the broadest coverage but the weakest architecture.

---

## 9. Promise vs Reality Assessment

### What the promise gets right

- **"Walk away" autonomy** — architecturally real. The state machine + crash
  recovery + fresh context per unit genuinely enables unattended operation.
- **"Clean git history"** — worktree isolation + squash merge delivers this.
- **"Cost tracking"** — per-unit metrics, budget ceilings, projections work.
- **"Fresh context per task"** — 200K-token sessions with pre-inlined context.
- **Provider-agnostic** — Anthropic, OpenAI, Google, Mistral, Ollama supported.

### What the promise overstates

- **"Handles verification and shipping"** — verification is running lint/test
  commands. If tests are weak, verification is weak. No code review, no design
  review, no architectural assessment. "Shipping" means committing and
  optionally pushing — no deploy pipeline, no canary, no rollback.
- **"Focus on what to build, not how to wrangle tools"** — the discuss phase
  captures requirements, but there's no product-level management (backlog,
  priorities, grooming). You still decide what to build and in what order.
  GSD handles how, not what.
- **"A real coding agent"** — it's a real orchestrator for LLM coding sessions.
  The LLM is still doing the coding. The quality of the code depends on the
  LLM's capabilities and the prompt quality, not on GSD's infrastructure.
  GSD makes the LLM more productive but doesn't make it more skilled.

### What the promise doesn't mention

- **No review phase.** Code goes from execution to completion without any
  review. This is a significant gap for production code.
- **No behavioral discipline.** The system prompt says "finish what you start"
  but there are no Superpowers-style guardrails against LLM failure modes.
- **93K lines of core code** is a significant dependency. Bugs in the
  orchestrator affect every project. The release cadence (v2.52 → v2.64
  in ~6 weeks) suggests active development but also active instability.
- **Pi SDK dependency.** GSD runs on its own agent runtime, not Claude Code's.
  This means you don't get Claude Code's ecosystem (plugins, MCP servers,
  hooks) — you get GSD's extensions instead. Migration cost is high.

---

## 10. What We Should Adopt

### Definitely adopt (infrastructure patterns)

1. **Disk-driven state machine** — state on filesystem, dispatch from state,
   no in-memory persistence across units. Enables crash recovery and human
   intervention.
2. **Pre-inlined context injection** — prompt builder includes relevant files,
   LLM starts working immediately.
3. **Structured tool completion** — typed tools handle state writes atomically,
   preventing inconsistency.
4. **Verification evidence table** — structured pass/fail evidence, auditable.

### Consider adopting (operational patterns)

5. **Complexity-based model routing** — if we support multi-model scenarios.
6. **Blocker escalation → automatic replan** — systematic handling of
   plan-invalidating discoveries during execution.
7. **Crash recovery briefing** — context reconstruction from tool call history.
8. **Git worktree isolation** — clean history via squash-merge per milestone.

### Don't adopt

9. **The full orchestrator** — 93K lines of TypeScript is a product, not a
   pattern. We build on Claude Code's platform, not a parallel runtime.
10. **"Walk away" autonomy without review** — autonomous execution without
    code review produces code that passes tests but may be poorly designed,
    over-engineered, or subtly wrong.
11. **Dual-path state derivation** — SQLite + markdown fallback is migration
    debt. Pick one source of truth.
12. **The extension ecosystem** — 23 bundled extensions duplicate Claude Code's
    native capabilities (MCP servers, tools, hooks). Don't rebuild the platform.

---

## 11. Summary

GSD-2 is a production-grade TypeScript orchestrator that genuinely delivers
on its core promise: autonomous, crash-recoverable, cost-tracked execution
of multi-step development work. Its state-machine architecture is an
architectural leap beyond prompt-only frameworks — it controls the LLM's
environment rather than persuading it to be disciplined.

The structural weakness is the gap between execution and quality. Tests pass
≠ code is good. GSD-2 has no review phase, no behavioral discipline for the
LLM, and no mechanism to catch design problems that don't manifest as test
failures. It optimizes for throughput (units completed per dollar) at the
expense of judgment (is this the right code?).

For our framework, GSD-2 contributes the insight that **orchestration
infrastructure matters** — state machines, structured tools, fresh context,
and crash recovery are not luxuries. But this infrastructure must be combined
with the **behavioral discipline** that Superpowers provides and the
**review rigor** that Gstack attempts.

The product-level gap we target (backlog → groom → brainstorm) sits above
all three frameworks. GSD-2's discuss phase captures requirements for a
single milestone but has no concept of a product backlog, component
decomposition, or priority management. The gap remains:

```
Product vision                                              Feature shipped
     |                                                           |
     |       [OUR FRAMEWORK]        [Superpowers discipline      |
     |                               + GSD-2 orchestration       |
     |                               + Gstack review]            |
     |                                                           |
  "Build X"  →  backlog  →  groom  →  brainstorm → plan → execute → review → ship
```
