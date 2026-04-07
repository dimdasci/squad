# Project: AI Workflow Framework Research & Design

## Purpose

Design a lightweight skill-based framework that extends the Superpowers
execution loop upward into product management, technical architecture, and
system specification. The framework fills the gaps between product vision
and feature implementation through shared, long-lived artifacts accessible
to multiple Claude Code instances.

Core product statement: `docs/product-statement.md`

## Role

Act as a senior manager with a background in solution architecture, team
engineering, and entrepreneurship.

## Project structure

```
docs/
├── product-statement.md              # Core product definition
├── analyses/                         # Framework deep-dive analyses
│   ├── gstack-analysis.md            # Gstack v0.15.13.0
│   ├── superpowers-analysis.md       # Superpowers v5.0.7
│   ├── gsd2-analysis.md              # GSD-2 v2.64.0
│   ├── pm-skills-analysis.md         # PM Skills v0.75
│   ├── openspec-analysis.md          # OpenSpec v1.2.0
│   └── skill-implementation-comparison.md
└── ideation/                         # Design thinking and observations
    ├── framework-landscape-summary.md # What we learned from 5 frameworks
    ├── design-principles.md           # Guiding principles for our framework
    ├── three-layer-model.md           # Product → Architecture → Spec layers
    └── shared-knowledge-layer.md      # External artifact root via env vars
repos/                                # Cloned sources (gitignored, reference only)
├── gstack/                           # Gstack v0.15.13.0
├── superpowers/                      # Superpowers v5.0.7
├── gsd2/                             # GSD-2 v2.64.0
├── pm-skills/                        # PM Skills v0.75
└── openspec/                         # OpenSpec v1.2.0
```

## Completed work

### Phase 1: Framework analysis (docs/analyses/)

Five frameworks analyzed at full codebase depth:

- **Gstack** — 36 skills, browser daemon. Specialist review breadth. MIT.
- **Superpowers** — 14 skills. Behavioral discipline, platform-native. MIT.
  Trusted execution base after a month of daily use.
- **GSD-2** — 93K lines TS orchestrator. Strongest infrastructure, weakest
  quality assurance. MIT.
- **PM Skills** — 47 skills, 3-tier hierarchy. Best skill architecture.
  CC BY-NC-SA 4.0 (restricts commercial derivatives).
- **OpenSpec** — 22K lines TS CLI. Best artifact management (specs + delta
  changes + archive). MIT.

### Phase 2: Design ideation (docs/ideation/)

Key observations crystallized:
- Two missing layers between product and execution (architecture + specification)
- Three-layer model: Product → Architecture → Specification → Execution
- Shared knowledge layer via environment variables (not repo-local)
- Lightweight at every layer — skills that augment Superpowers, not replace it

## Current focus

Define roles, processes, and the artifact structure that supports them.
Starting from: what roles interact with the system, what processes do they
follow, and what artifacts must exist to support those processes.

## Key principles

- Lightweight at every layer — if it can't be a skill, it's too heavy
- Augment Superpowers execution loop, don't replace it
- Follow Claude Code platform guidelines (< 500 lines per SKILL.md)
- Environment variables for artifact paths, not hardcoded paths
- Long-lived artifacts shared across sessions, branches, and agents
- Artifact structure derived from roles and processes, not invented abstractly
- Delta-based evolution (changes, not rewrites)
- Concurrent read access by design
