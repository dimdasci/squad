# Record Guide: C4 Diagrams and ADR Templates

Reference material for Phase 2 of the architecture-record skill.
Claude reads this file when producing the architecture record.

## C4 Level 1: System Context Diagram

Shows the system as a single box surrounded by its users and external
systems. Answers: "what does the system interact with?"

### Mermaid Template

````mermaid
flowchart TD
    User["User Type"]
    System["System Name"]
    ExtA["External System A"]
    ExtB["External System B"]

    User -->|"uses"| System
    System -->|"calls"| ExtA
    System -->|"reads from"| ExtB
````

### Rules
- The system is ONE box — do not decompose it at L1
- Every external actor/system gets its own node
- Edge labels describe the interaction (uses, calls, reads, writes)
- Node labels: 1-3 words. Details go in the companion table.

## C4 Level 2: Container Diagram

Shows the containers (deployable units) inside the system. Answers:
"what is the system made of?"

### Mermaid Template

````mermaid
flowchart TD
    subgraph System["System Name"]
        WebApp["Web App"]
        API["API Server"]
        DB["Database"]
        Worker["Background Worker"]
    end

    User["User"] -->|"browses"| WebApp
    WebApp -->|"API calls"| API
    API -->|"reads/writes"| DB
    API -->|"enqueues"| Worker
    Worker -->|"calls"| ExtService["External Service"]
````

### Rules
- One `subgraph` for the system boundary — no nested subgraphs
- Each container: 1-3 word label describing what it IS (not what it does)
- Container responsibility goes in the companion table, not the diagram
- Edge labels describe data flow direction and type
- If >10 containers, decompose:
  - Overview diagram: container groups as boxes, connections between groups
  - Detail diagrams: one per group, showing individual containers

### Container Table

| Container | Responsibility | Technology | Rationale |
|---|---|---|---|
| Web App | Serves user interface | Next.js | SSR for SEO, React ecosystem |
| API Server | Handles business logic | Python FastAPI | Team expertise, async support |
| Database | Stores application data | PostgreSQL | Relational data, proven at scale |

The "Rationale" column must reference either a brief constraint, team
expertise, or a specific research finding. Never "because it's popular."

## ADR Format (Nygard)

````markdown
### ADR-NNN: [Short Decision Title]

**Status:** proposed | accepted | superseded by ADR-NNN
**Context:** [1-3 sentences: what situation requires a decision?
Reference the brief constraint or requirement that drives this.]
**Decision:** [1-2 sentences: what did we decide?]
**Consequences:** [2-4 bullets: what follows from this decision?
Include both positive and negative consequences.]
````

### ADR Guidelines
- One ADR per non-trivial technology choice
- "Non-trivial" = any choice where a reasonable alternative exists
- Title is the decision, not the question ("Use PostgreSQL" not "Database choice")
- Context must reference the brief or a technical constraint
- Consequences must include at least one downside — every decision has trade-offs
- ADRs are append-only: supersede, never edit

### What Needs an ADR
- Primary language/framework choice
- Database technology
- External service dependencies (APIs, SaaS)
- Hosting/deployment approach
- Any choice that constrains future decisions

### What Does NOT Need an ADR
- Standard library usage
- Development tooling (linter, formatter)
- Test framework (unless unusual)
- Obvious defaults with no realistic alternative

## Artifact Template

The complete architecture record follows this structure:

````markdown
# Architecture Record: [Product Name]

Status: draft | approved
Date: YYYY-MM-DD
Approved by: [name or "pending"]
Brief: product/brief.md

## System Context (C4 L1)

[Mermaid diagram]

| Actor/System | Description | Interaction |
|---|---|---|
| ... | ... | ... |

## Containers (C4 L2)

[Mermaid diagram(s)]

| Container | Responsibility | Technology | Rationale |
|---|---|---|---|
| ... | ... | ... | ... |

## Architecture Decision Records

### ADR-001: [Title]
...

## Technology Landscape

[Summary of research: what was considered, what was chosen, why.
Links to documentation for key technologies.]
````
