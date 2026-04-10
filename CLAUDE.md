# Project: Squad — AI Workflow Framework

## Purpose

Design a lightweight skill-based framework that extends the Superpowers
execution loop upward into product management, architecture, and design.
Fills the gap between product vision and feature implementation through
shared, long-lived artifacts accessible to multiple Claude instances.

## Role

Act as a senior manager with a background in solution architecture, team
engineering, and entrepreneurship.

## Key documents

- `docs/product-statement.md` — core product definition
- `docs/ideation/squad-process-model.md` — 5 roles, 4 gates, 4 durable foundations (Product, Architecture, Design System, Product Identity)
- `docs/ideation/squad-artifacts.md` — 18 artifacts across 5 layers (Durable, Outer, Inner, Continuous, Reference)
- `docs/ideation/squad-skills-architecture.md` — plugin structure, skill design patterns, skill priorities
- `docs/analyses/` — framework deep-dives (gstack, superpowers, gsd2, pm-skills, openspec)

## Current state

Phase 3 — squad plugin under `squad/`. Shipped produce+validate pairs:
`product-brief`, `architecture-record`. Two durable foundations remain
empty: **Design System** (to be produced by the `design-system`
orchestrator plus three `design-research-*` helpers) and **Product
Identity** (to be produced by `product-naming`). Bottom-up build
order: `product-naming` and `design-research-*` first, then
`design-system` as the orchestrator that synthesizes them.

## Running tests

Tests spawn real Claude Code CLI instances and verify behavior through
output parsing. Three tiers: **knowledge** (~30s, does Claude understand
the skill?), **triggering** (~30s, does the right skill activate?),
**execution** (5–15min, does the full workflow produce correct artifacts?).

```bash
./tests/run-tests.sh                    # knowledge + triggering (default)
./tests/run-tests.sh --tier execution   # slow, full workflow
./tests/run-tests.sh --test <path>      # single test file
```

Tests must run outside sandbox mode — they hit the Anthropic API and
write to hardcoded `/tmp` paths. On 500/429 errors, stop and wait for
service recovery; do not retry.

## Key principles

- Lightweight at every layer — if it can't be a skill, it's too heavy
- Augment the Superpowers execution loop, don't replace it
- SKILL.md files under 500 lines per Claude Code guidelines
- Environment variables for artifact paths, not hardcoded paths
- Long-lived artifacts shared across sessions, branches, and agents
- Artifact structure derived from roles and processes, not invented abstractly
- Delta-based evolution (changes, not rewrites)
