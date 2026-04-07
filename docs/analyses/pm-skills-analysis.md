# PM Skills Framework Analysis

Baseline assessment for building an adopted derivative framework.
Based on PM Skills v0.75 (73 commits), CC BY-NC-SA 4.0, (c) 2026 Dean Peters.

---

## 1. The Promise (PM Skills' Own Words)

> "Battle-tested PM frameworks that teach both you and your AI agents how to
> do product management work at a professional level."

The marketed value proposition:
- Dual-audience: teaches human PMs the *why* while enabling AI agents to
  execute the *how*
- 47 skills organized into three tiers: Component → Interactive → Workflow
- 6 multi-skill commands that chain skills in the right order
- "ABC — Always Be Coaching" — explanation is load-bearing, not decorative
- Cross-platform: Claude Code, Codex, Cursor, ChatGPT, Gemini, n8n, etc.
- Validation infrastructure: metadata checks, trigger audits, library gates
- Plugin marketplace distribution for Claude Code

The framework positions itself as a pedagogic-first skill library — the
primary goal is making PMs better at their craft, with AI execution as a
secondary benefit.

---

## 2. What It Actually Is

PM Skills is **one thing**: a domain-specific prompt library for product
management.

**47 SKILL.md files** (~20,200 lines) organized into a strict three-tier
hierarchy, plus 6 command files for multi-skill orchestration, 17 scripts
for validation and tooling, and a Streamlit beta playground.

There is no runtime, no orchestrator, no state machine, no compiled binary.
The entire value is in the quality and structure of the prompts, the
pedagogic scaffolding, and the governance system that maintains consistency
across 47 skills.

### What distinguishes it from other prompt libraries

**Three-tier skill architecture** with enforced dependency rules:
- **Component skills** (21) — standalone templates and artifacts. Lowest level.
  Cannot reference interactive or workflow skills.
- **Interactive skills** (21) — multi-turn conversational flows with 3-5
  adaptive questions and enumerated recommendations. Can reference components.
- **Workflow skills** (6) — multi-step processes orchestrating components and
  interactives. Highest level.

**A canonical interaction protocol** — the `workshop-facilitation` skill is
the single source of truth for how all 22 interactive/workshop skills behave.
Session heads-up, progress labels, numbered options, interruption handling,
graceful continuation. One skill defines the pattern; 22 skills follow it.

**Pedagogy as a first-class constraint** — every skill must include "Why This
Works" sections, anti-patterns with consequences, and failure mode
explanations. An edit that strips learning scaffolding to tighten copy is
explicitly defined as a defect.

---

## 3. Top-Level Architecture

### Installation layout

```
~/.claude/skills/pm-skills/       # Or plugin install
├── skills/                       # 47 skills (20,202 lines)
│   ├── {skill-name}/SKILL.md     # Component (21), Interactive (21), Workflow (6)
│   ├── {skill-name}/examples/    # Optional: example outputs
│   ├── {skill-name}/template.md  # Optional: reusable templates
│   └── {skill-name}/scripts/     # Optional: deterministic helpers
├── commands/                     # 6 multi-skill workflows
│   ├── discover.md               # problem-framing → interviews → OST → validation
│   ├── write-prd.md              # problem → personas → PRD → stories
│   ├── plan-roadmap.md           # prioritization → roadmap
│   ├── prioritize.md             # framework selection → scoring
│   ├── strategy.md               # positioning → strategy session
│   └── leadership-transition.md  # readiness → onboarding playbook
├── catalog/                      # Generated navigation indexes
│   ├── skills-index.yaml         # Machine-readable skill metadata
│   └── commands-index.yaml       # Machine-readable command metadata
├── scripts/                      # 17 files (4,542 lines)
│   ├── find-a-skill.sh           # Keyword/trigger search
│   ├── test-library.sh           # Full quality gate
│   ├── test-a-skill.sh           # Single skill validation
│   ├── add-a-skill.sh            # Automated skill generation
│   ├── check-skill-metadata.py   # Frontmatter + structure validator
│   ├── check-skill-triggers.py   # Trigger-readiness auditor
│   └── check-command-metadata.py # Command reference validator
├── research/                     # Source materials (3,305 lines)
├── docs/                         # 39 files (5,858 lines)
├── app/                          # Streamlit beta playground
├── CLAUDE.md                     # Agent collaboration protocol (800+ lines)
├── START_HERE.md                 # 60-second entry point
└── PLANS.md                      # Phase-based development roadmap
```

### Skill invocation

Claude Code's native skill system. User types `/discover` or asks about
prioritization:
1. Claude Code matches skill by description/trigger metadata
2. Loads SKILL.md content as instructions
3. Claude follows the skill's structured process

Commands chain multiple skills: `/write-prd` invokes problem-statement →
proto-persona → prd-development → user-story → user-story-splitting in
sequence.

### Skill anatomy (enforced by validators)

```yaml
---
name: skill-name           # kebab-case, ≤64 chars, matches folder
description: "..."         # trigger-oriented, ≤200 chars, "use this when..."
intent: "..."              # richer purpose (v0.7+)
type: component|interactive|workflow
theme: category            # grouping tag
best_for: [...]            # use cases for discovery
scenarios: [...]           # example situations for discovery
estimated_time: "..."      # duration estimate
---

## Purpose          — what + when, outcome-focused
## Key Concepts     — frameworks, definitions, anti-patterns
## Application      — step-by-step, decision points, templates
## Examples         — real-world, good + bad versions
## Common Pitfalls  — failure modes + consequences + corrections
## References       — related skills, external sources
```

Section order is enforced by `check-skill-metadata.py`.

### Three-tier dependency graph

```
Workflow skills (6)
  ↓ can reference
Interactive skills (21)
  ↓ can reference
Component skills (21)  ← cannot reference up
```

Example chain:
```
/discover (Command)
├── problem-framing-canvas (Interactive)
├── discovery-interview-prep (Interactive)
│   └── problem-statement (Component)
├── opportunity-solution-tree (Interactive)
│   ├── jobs-to-be-done (Component)
│   └── epic-hypothesis (Component)
└── pol-probe-advisor (Interactive)
    └── pol-probe (Component)
```

---

## 4. The Real Value: Pedagogy vs Execution

### The core insight

PM Skills solves a problem that no other framework in our analysis attempts:
**teaching the human while enabling the AI**. The dual-audience model means
every skill must justify its methodology, name failure modes, and show
consequences — not just provide a template.

This is the opposite of Gstack's approach (discipline enforcement on the AI)
and Superpowers' approach (rationalization prevention for the AI). PM Skills
assumes the human needs to learn, not just the AI.

### What each tier contributes

**Component skills** (21) — the building blocks. Each produces a specific
artifact (user story, positioning statement, problem frame, JTBD analysis).
Well-structured templates with quality criteria. These are the output
generators.

**Interactive skills** (21) — the judgment layer. Instead of the user choosing
a framework, the skill asks 3-5 adaptive questions and recommends the right
approach. Prioritization-advisor asks about product stage, team context,
decision need, and data availability — then recommends RICE, ICE, Value/Effort,
or MoSCoW with reasoning. This is where PM methodology becomes actionable.

**Workflow skills** (6) — the orchestrators. Multi-phase processes that chain
components and interactives. Discovery-process runs 6 phases (Frame → Plan →
Research → Synthesize → Generate → Validate) referencing 8 other skills. These
are the closest thing to a product development lifecycle in the library.

### Skill domains

| Domain | Count | Example Skills |
|--------|-------|----------------|
| Discovery & Research | 12 | problem-statement, JTBD, OST, discovery-process |
| Strategy & Positioning | 10 | positioning-workshop, PRD, roadmap-planning |
| Delivery & Execution | 10 | user-story, epic-breakdown, story-mapping |
| Finance & Economics | 7 | SaaS metrics, pricing advisor, health diagnostic |
| Career & Leadership | 5 | director-readiness, VP/CPO readiness, onboarding |
| AI Product Management | 5 | AI readiness, context engineering, PoL probes |

---

## 5. What Works Well

### Pattern: canonical interaction protocol

The `workshop-facilitation` skill defines how all 22 interactive skills
behave: session heads-up, entry modes (guided/context-dump/best-guess),
question pacing (one at a time with progress labels), numbered options with
"Other (specify)", interruption handling ("done"/"bail"/"restart"), and
numbered recommendations at decision points.

One source of truth, 22 consumers. Changes propagate through maintenance
tooling (`docs/maintenance/facilitation-scope.md`). This is the right
pattern for behavioral consistency across a skill library.

### Pattern: trigger-oriented metadata

v0.7 standardized that `description` must answer "use this when..." —
trigger-oriented, not content-oriented. Combined with `best_for` and
`scenarios` fields, this helps Claude Code's skill discovery match the right
skill. Backed by `check-skill-triggers.py` validation.

This is the same insight as Superpowers' Claude Search Optimization (CSO)
— describe WHEN to use, not WHAT it does.

### Pattern: pedagogic-first constraint

"ABC — Always Be Coaching" as a governance rule, not just aspiration. The
CLAUDE.md explicitly lists protected content: "Why This Works" sections,
anti-patterns, consequence chains, educational preambles, failure mode
explanations. The v0.75 release note includes an explicit apology for a
contributor's edits that stripped learning scaffolding.

This is a quality discipline that Gstack and Superpowers lack — they focus
on AI behavior enforcement but never ask whether the human learned anything.

### Pattern: validation infrastructure

Five validators enforce structural consistency:
1. `check-skill-metadata.py` — frontmatter + required sections in order
2. `check-skill-triggers.py` — trigger-readiness scoring
3. `check-command-metadata.py` — command references only existing skills
4. `test-a-skill.sh` — single skill conformance gate
5. `test-library.sh` — full library quality gate

This is significantly more rigorous than Gstack (no validation) and
comparable to Superpowers' pressure scenario testing (different approach,
similar intent).

### Pattern: strict hierarchy with dependency rules

Component → Interactive → Workflow with enforced directionality. Components
can't reference up. This prevents circular dependencies and keeps the
building blocks reusable. Contrast with Gstack where skills freely reference
each other (or don't) and Superpowers where dependencies are loose.

---

## 6. What to Avoid

### Architectural gaps

**No state management or persistence.** Skills produce artifacts (PRDs,
roadmaps, user stories) but there's nowhere to store them between sessions.
No backlog, no artifact registry, no "what was decided last time." Each
session starts fresh. The `/discover` command chains skills in sequence but
the chain state is the conversation, not a persistent artifact.

**No execution handoff.** The pipeline ends at PM artifacts. `/write-prd`
produces a PRD with user stories, but there's no bridge to a coding framework
(Superpowers, GSD-2, or anything else) that would implement those stories.
The gap between "PRD is written" and "code is shipping" is unaddressed.

**No backlog management.** There's a prioritization-advisor and a
roadmap-planning skill, but they produce documents — not a managed backlog.
No priority queue, no status tracking, no grooming cycle. The skills help
you think about what to build but don't maintain a living list of work.

**Commands are shallow orchestration.** The 6 commands declare which skills
to chain and in what order, but the chaining is conversational — there's no
structured data passing between skills. The output of `problem-statement`
flows to `prd-development` through the conversation context, not through a
defined interface. If the context window loses earlier artifacts, the chain
degrades.

**No review or quality gate on outputs.** Skills produce artifacts, but
nothing validates whether the PRD is complete, the user stories have
testable criteria, or the roadmap addresses the strategic goals. The human
is the sole quality gate — which is fine for the pedagogic goal but limits
autonomous execution.

### License constraint

**CC BY-NC-SA 4.0** — this is NOT MIT. NonCommercial means derivative
works cannot be used commercially without separate permission. ShareAlike
means derivatives must use the same license. This is significantly more
restrictive than Gstack (MIT), Superpowers (MIT), and GSD-2 (MIT).

For our framework: we can study the patterns and methodology, but cannot
incorporate substantial portions of PM Skills content into a derivative work
intended for commercial use.

### Scope limitations

**Domain-locked to product management.** The three-tier architecture and
interaction protocol are excellent patterns, but the actual skill content is
PM-specific (positioning, JTBD, PESTEL, SaaS metrics). A workflow framework
needs the structural patterns, not the domain knowledge.

**No behavioral discipline for the AI.** Unlike Superpowers (rationalization
counters, pressure testing) or Gstack (anti-sycophancy, checklists), PM Skills
doesn't address LLM failure modes during execution. The interaction protocol
defines what the AI should do but doesn't guard against what it tends to do
wrong.

**47 skills is broad but uneven.** Finance (7 skills) and career (5 skills)
are well-structured suites. AI product management (5 skills) feels early.
Discovery (12 skills) is the strongest domain. The breadth serves the
"marketplace" positioning but dilutes focus.

---

## 7. Extractable Techniques

Patterns worth studying for a derivative work (respecting CC BY-NC-SA 4.0
constraints on content, but patterns and architecture are not copyrightable):

### Three-tier skill hierarchy with dependency rules

Component → Interactive → Workflow with enforced directionality. Each tier
has clear responsibilities: components produce artifacts, interactives add
judgment, workflows orchestrate sequences. Dependencies only flow downward.

### Canonical interaction protocol

One skill (`workshop-facilitation`) defines the interaction model: session
heads-up, entry modes, question pacing, progress labels, numbered options,
interruption handling. All interactive skills reference this single source
of truth. Changes propagate through maintenance tooling.

### Trigger-oriented metadata

`description` answers "use this when..." not "this skill does..." Combined
with `best_for` and `scenarios` fields for multi-signal discovery.
Validated by automated audit tooling.

### Validation infrastructure as governance

Automated validators enforce structural consistency: metadata checks, section
order, trigger readiness, cross-reference integrity, command-skill linkage.
Quality is mechanical, not dependent on reviewer judgment.

### Multi-skill commands as lightweight orchestration

Commands declare skill sequences with checkpoints between phases. Shallow
but effective for conversational workflows. The pattern of "one command chains
the right skills in the right order" is immediately applicable.

### Pedagogic-first constraint

Protected content types (Why This Works, anti-patterns, consequences, failure
modes) that cannot be stripped during editing. Explanation as a load-bearing
element. This is a governance technique, not a content technique.

### Adaptive questioning with enumerated recommendations

Interactive skills ask 3-5 context-gathering questions with numbered options,
then synthesize a recommendation with reasoning, fit assessment, and
limitations. The pattern of "gather context → recommend → explain why"
applies well beyond PM.

---

## 8. Comparison with Other Frameworks

| Dimension                    | Gstack v0.15.13.0          | Superpowers v5.0.7        | GSD-2 v2.64.0              | PM Skills v0.75             |
|------------------------------|----------------------------|---------------------------|-----------------------------|-----------------------------|
| **Domain**                   | Software engineering       | Development discipline    | Execution orchestration     | Product management          |
| **Architecture**             | Prompt library + browser   | Prompt library            | TS orchestrator + prompts   | Prompt library + validators |
| **Skills**                   | 36 (flat)                  | 14 (loose graph)          | 35 templates (dispatched)   | 47 (three-tier hierarchy)   |
| **Total lines**              | ~15,000 SKILL.md           | ~3,700 SKILL.md           | ~93,000 TypeScript          | ~20,200 SKILL.md            |
| **Skill structure**          | Ad hoc per skill           | Consistent but not enforced | Prompt templates            | Enforced anatomy + validators |
| **Interaction model**        | Static instructions        | Static instructions       | System-dispatched prompts   | Adaptive multi-turn questioning |
| **Behavioral discipline**    | Checklists, anti-sycophancy| Rationalization counters   | System prompt persona       | Pedagogic scaffolding        |
| **State persistence**        | Filesystem (partial)       | Plan files + git          | SQLite + markdown           | None                         |
| **Execution handoff**        | N/A (self-contained)       | brainstorm → ship         | discuss → validate          | None (artifacts only)        |
| **Review**                   | Specialist dispatch        | Two-stage review          | Verification commands       | Human only                   |
| **Validation tooling**       | None                       | Pressure scenario testing | Post-unit verification      | 5 automated validators       |
| **Platform support**         | 3 platforms                | 6 platforms               | Own runtime (Pi SDK)        | 16+ platforms                |
| **License**                  | MIT                        | MIT                       | MIT                         | CC BY-NC-SA 4.0             |

### Key philosophical differences

**Gstack** builds specialist personas and hopes the LLM inhabits them.
**Superpowers** prevents the LLM from rationalizing past discipline.
**GSD-2** controls the LLM's execution environment directly.
**PM Skills** teaches the human while structuring the AI's questions.

Each framework optimizes for a different failure mode:
- Gstack: "Claude doesn't follow checklists" → enforce checklists
- Superpowers: "Claude rationalizes past discipline" → block rationalizations
- GSD-2: "Claude drifts without control" → control the environment
- PM Skills: "The PM doesn't know which framework to use" → guide the choice

---

## 9. Promise vs Reality Assessment

### What the promise gets right

- **"Battle-tested PM frameworks"** — the methodology is genuine (Torres,
  Cagan, Moore, Cohn, Amazon PR/FAQ). Skills cite sources and explain why.
- **"Teach both you and your AI agents"** — the dual-audience model is real.
  Skills include educational scaffolding that would help a junior PM learn.
- **"47 skills"** — all present, validated, and structurally consistent.
- **Validation infrastructure** — automated quality gates work and catch
  structural issues.
- **Cross-platform** — documentation for 16+ platforms is genuinely provided.

### What the promise overstates

- **"Professional level"** — the skills are well-structured but the outputs
  depend on the LLM's synthesis quality, not just the template. A good
  positioning statement still requires human judgment that the skill can
  guide but not guarantee.
- **"Battle-tested"** — 73 commits since Feb 2026, 2 months old. "Tested"
  would be more accurate than "battle-tested."
- **Plugin marketplace** — the infrastructure exists but the ecosystem is
  one author's library, not a marketplace.

### What the promise doesn't mention

- **No execution bridge.** PM artifacts (PRDs, roadmaps, user stories) are
  produced but never handed off to a coding framework.
- **No persistence.** Work doesn't carry over between sessions.
- **CC BY-NC-SA license.** Significantly more restrictive than MIT. Derivative
  commercial works require separate permission.
- **No backlog management.** Skills help you think about priorities but don't
  maintain a living backlog.

---

## 10. Relevance to Our Framework

### The overlap

PM Skills occupies exactly the domain our framework targets: the space
between "what should we build?" and "let's brainstorm this feature." Its
skills for discovery, prioritization, PRD development, and roadmap planning
are the activities that feed a backlog.

### The gap PM Skills doesn't fill

1. **Persistent backlog** — skills produce artifacts but don't maintain state
2. **Grooming cycle** — no mechanism for revisiting and refining priorities
3. **Execution handoff** — no bridge to Superpowers or any coding framework
4. **Status tracking** — no concept of planned/in-progress/done/blocked

### What we learn from it

The three-tier hierarchy (Component → Interactive → Workflow) with enforced
dependency rules is the best skill organization pattern we've seen. The
canonical interaction protocol (one source of truth for 22 skills) solves
the consistency problem elegantly. The validation infrastructure shows how
to maintain quality at scale.

But the structural patterns matter more than the content — and the
CC BY-NC-SA 4.0 license means we can learn from the architecture without
incorporating the actual skill text.

---

## 11. Summary

PM Skills is a well-governed, domain-specific prompt library that brings
genuine product management methodology to AI agents. Its three-tier
architecture, canonical interaction protocol, and validation infrastructure
are the most sophisticated skill organization patterns in our analysis.

The framework's strength — pedagogy-first design for human PMs — is also
its limitation from our perspective. It produces PM artifacts but doesn't
manage them. It guides prioritization but doesn't maintain a backlog. It
structures discovery but doesn't hand off to execution.

For our framework, PM Skills contributes two insights:

1. **The product-level activities are well-defined.** Discovery, prioritization,
   PRD development, roadmap planning — the skills exist. What's missing is the
   glue: persistent state, a grooming cycle, and handoff to execution.

2. **Skill architecture matters.** Three-tier hierarchy with dependency rules,
   canonical interaction protocols, and automated validation produce better
   results than flat skill collections (Gstack) or loose graphs (Superpowers).

The CC BY-NC-SA 4.0 license constrains derivative works but the architectural
patterns — hierarchy, canonical protocols, validation — are applicable
regardless.

```
Product vision                                              Feature shipped
     |                                                           |
     |  [PM Skills domain]   [OUR FRAMEWORK]    [Execution]      |
     |  discovery, strategy  backlog, grooming   brainstorm→ship  |
     |  prioritization, PRD  handoff             Superpowers+     |
     |                                                           |
  "Build X"  →  discover → prioritize → backlog → groom → brainstorm → plan → execute → review → ship
```
