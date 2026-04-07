# Superpowers Framework Analysis

Baseline assessment for building an adopted derivative framework.
Based on superpowers v5.0.7, MIT License, (c) Jesse Vincent / Prime Radiant.

---

## 1. The Promise (Superpowers' Own Words)

> "A complete software development workflow for your coding agents, built on
> top of a set of composable 'skills' and some initial instructions that make
> sure your agent uses them."

The marketed value proposition:
- Automatic skill activation — agent checks for relevant skills before any task
- Brainstorm → Plan → Implement → Review → Ship lifecycle
- Subagent-driven development with two-stage review (spec compliance + code quality)
- Test-driven development as non-negotiable discipline
- Systematic debugging with root-cause investigation before fixes
- Evidence-based completion claims (no "should work now")
- Multi-platform: Claude Code, Cursor, Codex, OpenCode, Copilot CLI, Gemini CLI

The framework positions itself as "mandatory workflows, not suggestions" — discipline
enforcement through explicit rationalization counters and pressure-tested skill content.

---

## 2. What It Actually Is

Superpowers is **one thing**: a prompt library.

**14 SKILL.md files** (~3,700 lines total) plus ~40 supporting markdown files
containing reviewer prompts, anti-pattern references, debugging techniques,
and a visual brainstorming server.

There is no compiled binary, no SDK, no message bus, no runtime process beyond
the brainstorm visual companion server (a Node.js Express app for browser mockups).

The entire value is in how the skills **shape agent behavior** — preventing
common failure modes like skipping tests, guessing at fixes, and claiming success
without verification. Skills are loaded through Claude Code's native plugin system
and triggered automatically based on context.

### What distinguishes it from raw prompting

The session-start hook injects the `using-superpowers` skill content on every new
session. This skill establishes a meta-rule: **check for relevant skills before
any response or action**, even if there's only a 1% chance one applies. This
creates a skill-discovery loop that makes the entire library self-activating.

---

## 3. Top-Level Architecture

### Installation layout

```
~/.claude/plugins/superpowers/          # Plugin install
├── skills/
│   ├── brainstorming/SKILL.md          # 164 lines — Socratic design refinement
│   ├── writing-plans/SKILL.md          # 152 lines — Bite-sized task decomposition
│   ├── executing-plans/SKILL.md        #  70 lines — Batch execution with checkpoints
│   ├── subagent-driven-development/    # 277 lines — Same-session parallel tasks
│   │   ├── SKILL.md
│   │   ├── implementer-prompt.md       # Task dispatch template
│   │   ├── spec-reviewer-prompt.md     # Spec compliance checker
│   │   └── code-quality-reviewer-prompt.md
│   ├── test-driven-development/        # 371 lines — RED-GREEN-REFACTOR
│   │   ├── SKILL.md
│   │   └── testing-anti-patterns.md    # 298 lines
│   ├── systematic-debugging/           # 296 lines — 4-phase root cause
│   │   ├── SKILL.md
│   │   ├── root-cause-tracing.md
│   │   ├── defense-in-depth.md
│   │   ├── condition-based-waiting.md
│   │   └── find-polluter.sh
│   ├── verification-before-completion/ # 139 lines — Evidence before claims
│   ├── requesting-code-review/         # 105 lines — Dispatch reviewer
│   │   ├── SKILL.md
│   │   └── code-reviewer.md            # Reviewer prompt template
│   ├── receiving-code-review/          # 213 lines — Technical pushback
│   ├── dispatching-parallel-agents/    # 182 lines — Concurrent subagents
│   ├── using-git-worktrees/            # 218 lines — Isolated workspaces
│   ├── finishing-a-development-branch/ # 200 lines — Merge/PR decision
│   ├── using-superpowers/              # 117 lines — Meta: skill discovery
│   │   └── references/                 # Tool mappings per platform
│   └── writing-skills/                 # 655 lines — TDD for skills
│       ├── SKILL.md
│       ├── anthropic-best-practices.md
│       ├── persuasion-principles.md
│       └── testing-skills-with-subagents.md
├── agents/
│   └── code-reviewer.md                # Subagent definition
├── commands/
│   ├── brainstorm.md                   # Deprecated → skill
│   ├── write-plan.md                   # Deprecated → skill
│   └── execute-plan.md                 # Deprecated → skill
├── hooks/
│   ├── session-start                   # Polyglot bash/cmd injection script
│   ├── hooks.json                      # Claude Code hook config
│   ├── hooks-cursor.json               # Cursor hook config
│   └── run-hook.cmd                    # Windows compatibility wrapper
├── .claude-plugin/plugin.json          # Claude Code plugin manifest
├── .cursor-plugin/plugin.json          # Cursor plugin manifest
├── .codex/INSTALL.md                   # Codex install instructions
├── .opencode/                          # OpenCode plugin loader
├── gemini-extension.json               # Gemini CLI extension config
├── tests/                              # Skill trigger tests, brainstorm server tests
└── scripts/bump-version.sh             # Multi-file version sync
```

### Skill invocation flow

1. Session starts → hook injects `using-superpowers` content
2. Agent receives any user message
3. `using-superpowers` rule: check if any skill applies (even 1% chance)
4. Agent invokes relevant skill via `Skill` tool
5. Skill content loads, agent follows instructions

No orchestrator. No routing logic. The agent IS the router, with the
using-superpowers skill acting as the routing instruction.

### Skill dependency graph

```
Using-Superpowers (entry — always loaded)
│
├── Brainstorming ──→ Writing-Plans ──→ Subagent-Driven-Development
│                                       ├── Test-Driven-Development (per task)
│                                       ├── Requesting-Code-Review (between tasks)
│                                       └── Finishing-a-Development-Branch
│
├── Systematic-Debugging (standalone, invoked on bugs)
│   Uses: root-cause-tracing, defense-in-depth, condition-based-waiting
│
├── Verification-Before-Completion (gate skill, used by many)
├── Receiving-Code-Review (standalone)
├── Dispatching-Parallel-Agents (standalone, multiple failures)
├── Using-Git-Worktrees (early in flow, after brainstorming)
├── Executing-Plans (alternative to subagent-driven-development)
└── Writing-Skills (meta, for extending the system)
```

Dependencies are loose references (`superpowers:skill-name`), not hard imports.
Each skill works independently but references others as next steps.

---

## 4. Skill-by-Skill Assessment

### Tier 1: High-discipline skills (strong without-it-vs-with-it delta)

**Test-Driven-Development** (371 lines)
The most aggressive discipline skill. Iron Law: "NO PRODUCTION CODE WITHOUT
A FAILING TEST FIRST." Enforces RED-GREEN-REFACTOR with explicit steps for
each phase, mandatory verification at each transition, and an extensive
rationalization counter table addressing 8 specific excuses. Backed by a
298-line testing anti-patterns reference covering mock abuse, test-only
production methods, and integration test afterthoughts.

Without this skill, Claude consistently writes implementation first and tests
after (if at all). The skill's value is high because TDD requires sustained
discipline that LLMs naturally resist under completion pressure.

**Systematic-Debugging** (296 lines + 4 supporting files)
Four-phase root cause methodology: investigate → analyze patterns → hypothesis
→ implement fix. The skill's core value is preventing the "just try something"
impulse. Three supporting techniques (root-cause-tracing, defense-in-depth,
condition-based-waiting) are genuinely useful standalone patterns.

The "3+ fixes failed → question architecture" escalation rule is particularly
valuable — it prevents the infinite "one more fix" loop.

**Verification-Before-Completion** (139 lines)
Prevents premature success claims. Gate function: IDENTIFY → RUN → READ →
VERIFY → CLAIM. Short, focused, and directly addresses a measurable failure
mode (agent says "all tests pass" without running them).

### Tier 2: Workflow orchestration skills (structural value)

**Brainstorming** (164 lines + visual companion)
Socratic design refinement with progressive disclosure. Forces exploration
of user intent before implementation. The visual companion server (Node.js +
HTML mockups in browser) is genuine infrastructure — not just prompting.

The scope decomposition detection (flagging multi-subsystem specs) is a
valuable technique for preventing scope sprawl.

**Writing-Plans** (152 lines)
Converts approved specs into bite-sized tasks (2-5 min each). Key innovation:
complete code in every step, no placeholders. The "no TBD, no TODO, no
'similar to Task N'" rules directly address a common planning failure mode.

**Subagent-Driven-Development** (277 lines + 3 reviewer prompts)
The centerpiece execution skill. Two-stage review (spec compliance first, code
quality second) is the most architecturally interesting pattern. Fresh subagent
per task with precisely crafted context prevents pollution.

Model selection guidance (mechanical → fast model, integration → standard,
architecture → capable) shows practical production awareness.

**Finishing-a-Development-Branch** (200 lines)
Structured 4-option decision flow for branch completion. Prevents the "what
now?" drift after implementation. The decision table mapping options to
actions (merge/push/keep/cleanup) is clean and complete.

### Tier 3: Supporting skills (valuable but narrower)

**Requesting-Code-Review** (105 lines)
Dispatch template for code reviewer subagent. Straightforward plumbing.

**Receiving-Code-Review** (213 lines)
Anti-sycophancy skill: verify feedback before implementing, pushback when
reviewer lacks context. The YAGNI check ("grep for actual usage before
implementing reviewer suggestion") is a strong technique.

**Dispatching-Parallel-Agents** (182 lines)
Concurrent subagent execution for independent problems. Good agent prompt
structure guidelines but niche — applies only when 3+ independent failures exist.

**Using-Git-Worktrees** (218 lines)
Isolated workspace creation with gitignore safety checks. Solid but mostly
documents standard git worktree usage with safety guardrails.

### Meta skills

**Using-Superpowers** (117 lines)
The routing instruction. Establishes the "check skills before any action"
rule with an extensive rationalization counter table. This is the
bootstrap mechanism — without it, skills are passive documents.

**Writing-Skills** (655 lines + 3 supporting files)
TDD applied to process documentation. The most meta skill: teaches how to
write new skills using pressure scenario testing, Claude Search Optimization,
and persuasion research. This is the self-improvement mechanism.

---

## 5. Extractable Techniques

### 5a. Rationalization counter tables

Every discipline skill includes a table of exact excuses the agent uses under
pressure, paired with direct rebuttals:

```markdown
| Excuse                    | Reality                                    |
|---------------------------|--------------------------------------------|
| "Too simple to test"      | Simple code breaks. Test takes 30 seconds. |
| "I'll test after"         | Tests passing immediately prove nothing.   |
| "TDD is dogmatic"         | TDD IS pragmatic: finds bugs early.        |
```

Backed by research (Meincke et al., 2025): compliance increased 33% → 72%
with explicit persuasion techniques.

### 5b. Two-stage review

Separating "did you build what was specified?" from "is it well-built?"
prevents both under-building (missing requirements) and over-building
(unnecessary features). Each stage uses a focused subagent with a specific
reviewer prompt.

### 5c. Pressure scenario testing for skills

Skills are TDD'd: write scenario → test baseline (agent fails without skill)
→ write skill → test with skill (agent complies) → refine. Pressure types:
time, sunk cost, authority, economic, exhaustion, social, pragmatic.

### 5d. Claude Search Optimization (CSO)

Skill description fields document WHEN to use (triggers), not WHAT the skill
does. Prevents Claude from reading the description instead of loading the full
skill body — a real failure mode where the agent follows a summary instead
of the complete instructions.

### 5e. Evidence-before-claims gate

IDENTIFY → RUN → READ → VERIFY → CLAIM. Simple, enforceable. Prevents the
most common agent lie: "all tests pass" without running them.

### 5f. Context isolation for subagents

Provide full task text inline (never "read file X"). Provide scene-setting
context. Provide ONLY what the subagent needs. Preserves controller context
for coordination.

### 5g. Scope decomposition detection

During brainstorming, flag specs that cover multiple independent subsystems.
Suggest breaking into sub-projects, each getting its own spec → plan → impl
cycle.

### 5h. YAGNI enforcement via grep

Before implementing a reviewer's "implement this properly" suggestion:
grep codebase for actual usage. If unused, remove rather than implement.

### 5i. Architecture escalation rule

If 3+ fix attempts fail, stop trying implementation fixes. The problem is
architectural, not implementational. Escalate to human partner.

### 5j. Bite-sized task decomposition

2-5 minute steps: write failing test → run it → implement → run tests → commit.
No placeholders, no "similar to Task N", no "add appropriate error handling".
Complete code in every step.

---

## 6. Architectural Gaps

### 6a. No persistent state between sessions

Skills reference project state via filesystem, but there's no structured
session artifact — no "what was decided in brainstorming" or "which plan tasks
are complete." The writing-plans skill saves to `docs/superpowers/plans/`,
but there's no protocol for the next session to discover and resume.

Workaround: Git history and plan file checkboxes. Works but fragile.

### 6b. Skill routing relies entirely on LLM judgment

The using-superpowers skill says "check if any skill applies, even 1%
chance." But the LLM decides what matches. There's no structured routing
(event type → skill mapping), which means skill activation depends on
the model's current interpretation of the trigger conditions.

In practice, this works well enough because Claude Code's native skill system
already does keyword matching on the description field. But it means the
framework can't guarantee a specific skill runs for a specific situation.

### 6c. No skill chaining or composition protocol

Skills reference each other by name (`superpowers:writing-plans`) but there's
no structured handoff. The brainstorming skill says "invoke writing-plans"
as its terminal state, but doesn't pass structured data — just the expectation
that a spec document exists on disk.

This limits reliable multi-step workflows. If the spec document wasn't saved
where expected, the chain breaks silently.

### 6d. Rubber-stamp risk in code review

The code-reviewer agent follows a template but has no adversarial pressure
testing against rubber-stamping. The requesting-code-review skill acknowledges
severity levels (Critical blocks progress, Important before proceeding,
Minor for later) but the reviewer prompt doesn't explicitly guard against
"everything looks good" when it isn't.

The receiving-code-review skill IS well-hardened against sycophancy on the
receiving end, but the review-giving side lacks equivalent rigor.

### 6e. Token overhead per session

Every session starts by loading using-superpowers (117 lines), then each
triggered skill loads its full content. A typical brainstorm → plan → implement
flow could load 1,000+ lines of skill content before any actual work begins.
The writing-skills skill notes token efficiency guidelines (<500 words for
frequent skills) but several skills exceed this significantly.

### 6f. Visual companion is infrastructure debt

The brainstorming visual companion (Node.js server + HTML templates) is the
only runtime component. It requires Node.js, manages a PID file, auto-exits
after 30 minutes of inactivity, and has platform-specific behavior. This is
real infrastructure with real failure modes, unlike the rest of the purely
declarative skill library.

### 6g. No product-level work management

Superpowers manages the lifecycle from brainstorming through PR, but has no
concept of a backlog, priorities, or feature grooming. The gap between
"what should we build next?" and "let's brainstorm this feature" is unaddressed.

This is the exact gap our framework targets.

---

## 7. Comparison with Gstack

| Dimension                    | Gstack v0.15.13.0              | Superpowers v5.0.7            |
|------------------------------|--------------------------------|-------------------------------|
| **Skills**                   | 36 skills                      | 14 skills                     |
| **Total SKILL.md lines**     | ~15,000                        | ~3,700                        |
| **Infrastructure**           | Browser daemon (9,700 lines TS)| Visual companion (Node.js)    |
|                              | Design binary (2,900 lines TS) |                               |
| **Platforms**                | Claude Code, Codex, Cursor     | 6 platforms (CC, Cursor, Codex, OpenCode, Copilot CLI, Gemini CLI) |
| **Skill activation**         | User-invoked (`/skill`)        | Auto-triggered via meta-skill |
| **Build system**             | Template → SKILL.md generation | None (hand-written skills)    |
| **Session persistence**      | Some filesystem protocols      | Plan files + git checkboxes   |
| **Review approach**          | Cross-model (Codex second opinion) | Two-stage (spec + quality)  |
| **TDD enforcement**          | Mentioned, not enforced        | Iron Law with rationalization counters |
| **Debugging methodology**    | Ad hoc                         | 4-phase systematic + sub-techniques |
| **Skill testing**            | None documented                | Pressure scenario TDD         |
| **Token efficiency**         | 2.5-5x over recommended        | 1-3x over recommended        |
| **License**                  | MIT                            | MIT                           |

### Key differences in philosophy

**Gstack** is breadth-first: 36 skills covering product planning, design systems,
QA automation, shipping, ops, and browser interaction. It creates specialists
(CEO reviewer, design reviewer, devex reviewer) and invests in infrastructure
(compiled binaries for browser and design).

**Superpowers** is depth-first: 14 skills focused on development discipline.
It invests in making each skill resilient to rationalization and pressure.
The writing-skills meta-skill shows that the framework treats skill quality
as a first-class concern.

**Gstack** trusts the agent more — its skills give instructions and expect
compliance. **Superpowers** trusts the agent less — its skills anticipate
specific failure modes and build explicit guardrails against them.

---

## 8. What We Should Adopt

### Definitely adopt

1. **Rationalization counter tables** — proven compliance improvement, low cost
2. **Evidence-before-claims gate** — prevents the most common agent lie
3. **Two-stage review** (spec compliance then code quality) — structural improvement
4. **CSO for skill descriptions** — prevents real failure mode in Claude
5. **Bite-sized task decomposition** (2-5 min, complete code, no placeholders)
6. **Context isolation for subagents** — inline full text, don't reference files
7. **Architecture escalation rule** (3+ failed fixes → stop, discuss)

### Consider adopting

8. **Pressure scenario testing for skills** — valuable but expensive to implement
9. **Scope decomposition detection** — useful for complex features
10. **YAGNI enforcement via grep** — simple technique, easy to embed
11. **Auto-triggering via meta-skill** — powerful but creates token overhead

### Don't adopt

12. **Visual companion server** — infrastructure debt, narrow use case
13. **655-line meta-skill** — too long; the principles are good but the implementation
    violates its own token efficiency guidelines
14. **Deprecated command stubs** — unnecessary compatibility layer

---

## 9. Summary

Superpowers is a focused discipline-enforcement framework. Its value comes not
from teaching Claude new knowledge, but from preventing specific failure modes
that Claude exhibits under pressure: skipping tests, guessing at fixes, claiming
success without verification, and agreeing with feedback without verifying it.

The framework's investment in **rationalization prevention** (explicit counter
tables, pressure scenario testing, iron laws) is its strongest contribution.
This is the opposite of gstack's approach — where gstack invests in specialist
breadth, Superpowers invests in behavioral depth.

The gap we fill is above both: product-level work management that feeds into
the Superpowers execution loop. Superpowers handles brainstorm → ship.
Our framework handles backlog → brainstorm, making the full cycle:
**backlog → groom → brainstorm → plan → implement → review → ship → retrospect**.
