# Product Statement: Workflow Framework

## Problem

No existing framework bridges product-level work management with AI-assisted
feature execution. Superpowers handles feature scope reliably (brainstorm →
design doc → plan → implement → review → PR). Nothing handles product scope —
decomposing a product into components, maintaining a prioritized backlog, and
feeding the next work item into the execution loop.

## The Gap

```
Product vision                               Feature shipped
     |                                            |
     |        [THIS FRAMEWORK]      [Superpowers]  |
     |                                            |
  "Build a job board"  →  backlog  →  "Implement auth"  →  brainstorm → plan → code → review → PR
```

## Core Concepts

**Product components** — the organizing unit. Examples: auth system, document
repository, job channel discovery agent. A product is a collection of components.

**Backlog** — prioritized features per component. Simple priority (high/normal).
Dependencies between features. Status tracking (planned/in-progress/done/blocked).

**Grooming** — ongoing, not one-time. Refine backlog as implementation reveals
new knowledge. Triggered by context changes: feature ships, blockers appear,
new requirements surface.

**Handoff** — a backlog item becomes the starting context for the Superpowers
execution loop (brainstorm → design doc → plan → implement → review → PR).

**Product brief** — persistent document describing product vision, components,
and success criteria. Referenced by all sessions and agents.

## Consumers

- Solo developer + multiple Claude Code agents (planner, developer, QA working
  in parallel) — needs shared persistent artifacts
- Small human team — same shared artifacts, legible to humans and agents alike

## Technical Constraints

- External persistent artifacts (markdown/JSON), not in-memory
- Environment variable for artifact root (e.g. `$FRAMEWORK_HOME`), not
  hardcoded paths
- Accessible from different Claude Code sessions and different agents
- Must compose with Superpowers execution loop, not replace it
- Skills must follow Claude Code platform guidelines (< 500 lines per SKILL.md,
  supporting files for reference material, conditional loading)

## Approach

Evaluate existing frameworks (Superpowers, gstack, others), extract what works,
and either mix them or create a derivative. Gstack is MIT licensed — extractable
techniques documented in `docs/gstack-analysis.md`.

## What We Keep From Each Source

**From Superpowers:** The entire execution loop. It works. Don't touch it.

**From gstack (extractable techniques):**
- Specialist dispatch with fresh context
- Confidence calibration with display rules
- Anti-sycophancy enforcement
- Hook-based enforcement (freeze/careful/guard)
- Baseline-aware monitoring patterns
- Browser daemon (if QA/design skills needed)

**To build new:** The product-level layer — backlog management, component
decomposition, grooming, handoff to execution loop.

## Research Needed

- Analyze Superpowers in detail (same depth as gstack)
- Research what other people do for AI-assisted product management
- Evaluate other workflow frameworks
- Design the product-level skill(s)
