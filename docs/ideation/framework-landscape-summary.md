# Framework Landscape Summary

What we learned from analyzing five frameworks and the broader ecosystem.

## Frameworks Analyzed

| Framework | Version | Type | Best At | License |
|-----------|---------|------|---------|---------|
| [Gstack](../analyses/gstack-analysis.md) | v0.15.13.0 | Prompt library + browser daemon | Specialist review breadth | MIT |
| [Superpowers](../analyses/superpowers-analysis.md) | v5.0.7 | Prompt library (skills) | Behavioral discipline | MIT |
| [GSD-2](../analyses/gsd2-analysis.md) | v2.64.0 | TypeScript orchestrator | Execution infrastructure | MIT |
| [PM Skills](../analyses/pm-skills-analysis.md) | v0.75 | Domain-specific prompt library | Skill architecture | CC BY-NC-SA 4.0 |
| [OpenSpec](../analyses/openspec-analysis.md) | v1.2.0 | CLI + skill generation | Artifact management | MIT |

## Key Finding: Two Missing Layers

The ecosystem has a strong execution layer (Superpowers handles brainstorm →
ship reliably) but nothing above it. Between "product vision" and "brainstorm
this feature" there are two distinct translation gaps:

**Gap 1: Product → Technical Architecture.** Decomposing a product into
components, making technology choices, defining boundaries, data models,
API surfaces. Done once per product, constrains everything downstream.

**Gap 2: Technical Architecture → Feature Specification.** Translating
architectural decisions into executable feature work within the constraints
the architecture sets.

No framework bridges both. OpenSpec comes closest with its spec layer but
doesn't maintain system-level architecture.

## What We Adopt From Each

**From Superpowers (execution base — unchanged):**
- The entire brainstorm → plan → implement → review → ship loop
- Rationalization counters, TDD enforcement, evidence-before-claims
- Platform-native approach: skills that augment Claude Code, not replace it

**From OpenSpec (artifact patterns):**
- Specs as living source of truth with delta-based evolution
- Change isolation (parallel progress without conflicts)
- Archive as decision log
- Schema-driven artifact sequences

**From GSD-2 (infrastructure techniques):**
- Pre-inlined context injection (prompt builder decides what LLM sees)
- Structured tool completion (typed tools handle state writes)
- Verification evidence tables

**From Gstack (review techniques):**
- Specialist dispatch with fresh context
- Anti-sycophancy enforcement
- Confidence calibration with display rules

**From PM Skills (architecture patterns — study only, CC BY-NC-SA):**
- Three-tier skill hierarchy with dependency rules
- Canonical interaction protocols
- Validation infrastructure as governance

## What We Don't Adopt

- GSD-2's full orchestrator (93K lines, own runtime — too heavy)
- Gstack's token bloat (2.5-5x over platform recommendation)
- Any framework's hardcoded artifact paths
- PM Skills content (license restricts commercial derivatives)
- Session-bound execution models (need shared knowledge across instances)

## The Ecosystem Gap

Nobody has built: persistent product knowledge + architecture decisions +
system specs in a shared layer accessible to multiple Claude Code instances
working on independent branches. This is what we build.
