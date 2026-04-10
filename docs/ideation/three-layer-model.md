# Three-Layer Model

> **Status: historical precursor.** This doc describes an early
> conceptual model where the framework added three layers above
> Superpowers (Product, Architecture, Specification). The current
> authoritative model has **four durable foundations** (Product,
> Architecture, Design System, Product Identity) and **five
> artifact layers** (Durable, Outer Cycle, Inner Cycle, Continuous,
> Reference). See `squad-process-model.md` and `squad-artifacts.md`
> for the current state. Preserved here as a decision trail.

The framework adds three layers above the Superpowers execution loop.
Each layer produces persistent artifacts that the layers below consume.

## Layer Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│  PRODUCT LAYER                                                      │
│  What to build and why. Priorities. Success criteria.               │
│  Artifacts: product brief, backlog, product decisions               │
│  Cadence: ongoing grooming as features ship and knowledge grows     │
├─────────────────────────────────────────────────────────────────────┤
│  ARCHITECTURE LAYER                                                 │
│  How the system is structured. Technology choices. Boundaries.      │
│  Artifacts: component map, data model, ADRs, API contracts         │
│  Cadence: updated when new components emerge or boundaries shift    │
├─────────────────────────────────────────────────────────────────────┤
│  SPECIFICATION LAYER                                                │
│  What the system does. Structured requirements. Testable scenarios. │
│  Artifacts: system specs (per component), change proposals          │
│  Cadence: updated when features ship (delta merge on completion)    │
├─────────────────────────────────────────────────────────────────────┤
│  EXECUTION LAYER (Superpowers — unchanged)                          │
│  brainstorm → plan → implement → review → ship                     │
│  Reads from layers above for context and constraints                │
└─────────────────────────────────────────────────────────────────────┘
```

## Information Flow

**Downward (constraints):** Each layer constrains the layer below.
- Product priorities determine which features get brainstormed
- Architecture constraints shape feature design decisions
- Specs define current behavior that features must preserve or modify

**Upward (feedback):** Each layer updates the layer above on completion.
- Shipped features update specs (delta merge)
- Implementation discoveries update architecture (new ADRs, component changes)
- Feature outcomes inform product priorities (backlog grooming)

## Open Questions

These questions must be answered through the roles & processes analysis:

1. **What roles interact with each layer?** (Product owner, architect,
   developer, reviewer — or are some roles the same person?)
2. **What processes operate at each layer?** (Grooming, architecture review,
   spec writing, feature implementation — what triggers each?)
3. **What artifacts does each process produce and consume?**
4. **What's the minimal artifact set per layer?** (Not everything needs to
   exist from day one)
5. **How does the shared knowledge layer handle concurrent reads/writes?**
6. **What's the handoff protocol between layers?** (How does a backlog
   item become a brainstorming input?)
