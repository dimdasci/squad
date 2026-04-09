# Architecture Record Review Checklist

Detailed pass/fail criteria for each review check. The reviewer
reads this file during the review process.

## Pass 1 — Structural Completeness

### S1: C4 L1 diagram exists and is valid Mermaid

**How to check:** Look for a mermaid code block in the "System Context"
section. Run:
```bash
npx mermaid-validator validate-md ${user_config.product_home}/architecture/record.md --fail-fast
```
**PASS if:** Command exits 0.
**FAIL if:** Command exits non-zero, or no mermaid block found in the
System Context section.

### S2: C4 L1 shows system boundary and at least 1 external actor

**How to check:** Read the L1 diagram. Look for at least two distinct
node types: the system itself and at least one external actor (user,
admin, external service).
**PASS if:** System node and at least 1 external actor are present.
**FAIL if:** Only the system node exists, or diagram shows internal
components instead of system context.

### S3: C4 L2 diagram exists and is valid Mermaid

**How to check:** Same as S1 but for the "Containers" section.
**PASS if:** Valid mermaid block exists in Containers section.
**FAIL if:** Missing or invalid.

### S4: C4 L2 shows containers with short labels

**How to check:** Read each node label in the L2 diagram. Count words.
**PASS if:** All labels are 4 words or fewer.
**FAIL if:** Any label exceeds 4 words. Cite the specific node.

### S5: C4 L2 respects complexity limit

**How to check:** Count distinct container nodes in the L2 diagram.
**PASS if:** 10 or fewer containers in a single diagram, or decomposed into
overview + detail diagrams.
**FAIL if:** More than 10 containers in a single diagram without decomposition.

### S6: Companion tables exist for both diagrams

**How to check:** Look for a markdown table immediately after each
mermaid diagram.
**PASS if:** L1 has Actor/System table, L2 has Container table.
**FAIL if:** Either table is missing.

### S7: At least 1 ADR per non-trivial technology choice

**How to check:** Read the Container table's Technology column. For each
distinct technology, check if an ADR exists. "Non-trivial" means a
realistic alternative exists (don't require an ADR for using HTML).
**PASS if:** Each non-trivial technology has a corresponding ADR.
**FAIL if:** A technology choice has no ADR and a reasonable alternative
exists. Cite the specific technology.

### S8: ADRs follow Nygard format

**How to check:** Each ADR must have: Status, Context, Decision,
Consequences fields.
**PASS if:** All ADRs have all four fields with substantive content.
**FAIL if:** Any field is missing or contains only placeholder text.
Cite the specific ADR.

### S9: No orphan components

**How to check:** For each container node in the L2 diagram, check that
it has at least one edge (incoming or outgoing).
**PASS if:** Every container has at least 1 connection.
**FAIL if:** Any container has zero connections. Cite the specific node.

### S10: Technology Landscape section exists with research links

**How to check:** Look for a "Technology Landscape" section. Check for
at least one URL.
**PASS if:** Section exists with at least 1 external link.
**FAIL if:** Section missing, or present but contains no links.

### S11: No styling directives or nested subgraphs

**How to check:** Scan all mermaid code blocks for: `style`, `class`,
`classDef`, `:::`, or nested `subgraph` (a subgraph inside a subgraph).
**PASS if:** None found.
**FAIL if:** Any found. Cite the specific line.

## Pass 2 — Architectural Fitness

### F1: Separation of concerns

**How to check:** Read the Container table's Responsibility column.
Each responsibility should describe one thing.
**PASS if:** No container has "and" or multiple verbs in its
responsibility, and no two containers share similar responsibilities.
**FAIL if:** A container has compound responsibilities, or two
containers overlap. Cite both.

### F2: API boundary clarity

**How to check:** For each edge between containers in L2, check if the
interaction type is described (the edge label or the companion table).
**PASS if:** Interactions between containers are labeled with their type
(REST, queue, file, shared DB, etc.).
**FAIL if:** Edges exist without labels, or labels are vague
("communicates with"). Cite the specific edge.

### F3: Data flow coherence

**How to check:** Pick the primary user action described in the brief.
Trace it through the L2 diagram from user input to stored output.
**PASS if:** A complete path exists through the containers.
**FAIL if:** The path is broken (data enters a container but has no
visible path to the next step). Cite where the path breaks.

### F4: Technology fit

**How to check:** For each ADR, check if the Context references a brief
constraint or requirement.
**PASS if:** Technology choices reference brief constraints (appetite,
team expertise, deployment environment).
**FAIL if:** An ADR's Context doesn't connect to the brief. Cite the ADR.

### F5: Proportionality

**How to check:** Compare the number of containers and ADRs against
the brief's appetite.
**PASS if:** Complexity is reasonable for the stated appetite.
**FAIL if:** Architecture is clearly over-engineered for the appetite
(e.g., microservices + message queues + multiple databases for a
2-week MVP). Cite the specific over-engineering.

### F6: Simplicity

**How to check:** For each container, ask: "if I removed this, would
the system lose a capability described in the brief?"
**PASS if:** Every container is necessary.
**FAIL if:** A container could be merged into another or eliminated
without losing functionality. Cite which containers and why.

## Pass 3 — Brief Alignment

### B1: Success criteria achievable

**How to check:** For each success criterion in the brief, identify
which containers support it.
**PASS if:** Every criterion has at least one supporting container.
**FAIL if:** A criterion has no clear architectural support. Cite the
criterion and explain what's missing.

### B2: IS NOT boundaries respected

**How to check:** Read the brief's "IS NOT" list. Check that no
container's responsibility matches an excluded capability.
**PASS if:** No container serves an excluded capability.
**FAIL if:** A container's responsibility matches an IS NOT item.
Cite both.

### B3: Brief constraints reflected

**How to check:** Read the brief's Constraints and No-gos. Check that
each is either reflected in an ADR or visible in technology choices.
**PASS if:** All constraints are addressed.
**FAIL if:** A constraint is not reflected anywhere. Cite the constraint.

### B4: No gold-plating

**How to check:** For each container, identify which brief requirement
it serves.
**PASS if:** Every container maps to at least one brief requirement.
**FAIL if:** A container exists without a clear brief requirement.
Cite the container.

### B5: No gaps

**How to check:** For each brief IS item, identify which container
implements it.
**PASS if:** Every IS item has a supporting container.
**FAIL if:** An IS item has no container. Cite the item.
