# Squad Process Model

Status: draft v6
Date: 2026-04-07

## Overview

A process model for small product teams (1–6 people) where AI agents
fill specialist roles under human oversight. The human acts as a CPTO
(Chief Product & Technology Officer) — an observer who asks questions,
challenges choices, and approves decisions. Agents propose and execute.

## Three Temporal Modes

Activities group by how long their outputs live:

### Durable (long-lived constraints)

Artifacts that survive many execution cycles. Revised on pivots or major
shifts. Every automated gate validates against these.

| Concern       | Agent Role     | Artifacts                                    |
|---------------|----------------|----------------------------------------------|
| Product       | Product Owner  | Product brief, backlog, priorities, criteria  |
| Architecture  | Architect      | Component map, ADRs, API contracts, models    |
| Design System | Designer       | Visual standards, component patterns, DESIGN.md |

All durable changes require **human approval**. Agents draft; CPTO
challenges and approves. This is the foundation — if it drifts, all
downstream gates validate against wrong standards.

### Cyclic (per-feature heartbeat)

Two nested cycles consume durable artifacts and produce increments.

**Outer cycle — product increment:**

1. Pick Feature — Product Owner selects from backlog
2. Shape & Scope — Product Owner defines boundaries, acceptance criteria
3. **Product Gate** — QA/Reviewer validates; **human approves** scope
4. [Enter inner cycle]
5. **QA Gate** — QA/Reviewer runs regression, user scenarios (automated)
6. Verify — Developer runs CI, integration tests (automated)
7. **Merge PR** — Developer requests; **human approves**
8. **Demo & Announce** — Product Owner prepares screenshots, changelog,
   product update; **human approves** before external communication

**Inner cycle — execution (fully automated, Superpowers):**

1. Brainstorm — Architect explores implementation approach
2. Plan — Developer breaks work into tasks
3. **Architecture Gate** — Architect validates against ADRs, boundaries
4. Implement — Developer executes task by task
5. **Design Gate** — Designer validates against design system
6. Code Review — QA/Reviewer checks spec conformance and quality
7. → Rework if needed, otherwise exit to outer cycle

### Continuous (cadence-based)

Process-level activities on a regular cadence (daily, weekly). Not tied
to specific features.

| Activity               | Agent Role | Purpose                              |
|------------------------|------------|--------------------------------------|
| Knowledge collection   | Designer   | Collect learnings, update understanding |
| Operations monitoring  | Developer  | Track metrics, monitor health        |
| Technical backlog      | Architect  | Flag debt, refactoring, infra needs  |

## Five Agent Roles

| Role           | Activities | Share | Key responsibility                    |
|----------------|-----------|-------|----------------------------------------|
| Product Owner  | 4         | 20%   | What to build, scope, demo             |
| Architect      | 4         | 20%   | System structure, tech debt, arch gate |
| Designer       | 3         | 15%   | Design system, design gate, knowledge  |
| Developer      | 5         | 25%   | Plan, implement, verify, merge, ops    |
| QA / Reviewer  | 4         | 20%   | Product gate, QA gate, code review     |

Key constraints:
- No role exceeds 25% of activities
- No role gates its own output (produce ≠ validate)
- Gates read from durable artifacts maintained by domain owners

## Human Approval Points (6 of 20 activities)

The CPTO touches the process at two boundaries:

**Durable artifacts (3):** Product, Architecture, Design System. Agents
propose changes; human approves. These are the inputs that everything
validates against.

**Outer perimeter (3):** Product Gate (before execution), Merge PR
(before shipping), Demo & Announce (before external communication).
These are the outputs that affect users and stakeholders.

**Fully automated (14 of 20):** The entire inner cycle, QA gate, CI
verification, and all continuous activities run without human
intervention.

## Four Gates

Each gate guards its durable concern:

| Gate              | Guards against         | Owned by     | Type      |
|-------------------|------------------------|--------------|-----------|
| Product Gate      | Building wrong thing   | QA/Reviewer  | Human     |
| Architecture Gate | Structural deviation   | Architect    | Automated |
| Design Gate       | UX inconsistency       | Designer     | Automated |
| QA Gate           | Broken user experience | QA/Reviewer  | Automated |

Gates can reject (loop back) or escalate (update durable artifacts when
the standards themselves need revision).

## Escalation Paths

- Architecture Gate → new ADR needed → update Architecture (durable)
- Design Gate → new pattern needed → update Design System (durable)
- Both escalations require human approval on the durable artifact update.

## Constraint Flow

```
DURABLE (human-approved foundation)
  Product ──────┐
  Architecture ─┼──► constraints flow down to every cycle
  Design System ┘
        │
  OUTER CYCLE (product increment)
    Pick → Shape → Product Gate [HUMAN] → Inner Cycle
    Inner Cycle → QA Gate → Verify → Merge [HUMAN] → Demo [HUMAN]
        │
        │  feedback (findings, outcomes)
        ▼
  CONTINUOUS (cadence-based, automated)
    Knowledge ◄──► Operations → Tech Backlog
        │
        └──► update durable layer (with human approval)
```

## Open Questions

- What specific artifacts does each gate check? (checklist format)
- How does the technical backlog feed into feature picking — priority
  rules, ratio of product vs tech work?
- What triggers durable artifact revisions outside of gate escalations?
- How do multiple agents coordinate on shared artifacts concurrently?
- What is the concrete cadence for continuous activities?
