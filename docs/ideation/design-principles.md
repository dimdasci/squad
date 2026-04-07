# Design Principles

Principles guiding the framework design, derived from analysis and experience.

## 1. Lightweight at every layer

No orchestrators, no parallel runtimes, no compiled binaries. Each layer is
a skill (or small set of skills) that produces and consumes markdown artifacts.
If it can't be a skill, it's too heavy.

## 2. Augment Superpowers, don't replace it

Superpowers handles brainstorm → ship reliably. The framework adds layers
above it (product, architecture, specification) and connects them through
shared artifacts. The execution loop is unchanged.

## 3. Follow Claude Code platform conventions

Skills under 500 lines. Supporting files for reference material. Conditional
loading. Hooks for enforcement. No fighting the platform — the platform is
the execution environment.

## 4. Shared knowledge layer via environment variables

Artifacts live at `$PRODUCT_HOME` (or similar env var), not hardcoded paths
inside the repository. Multiple Claude Code instances on independent branches
share this knowledge layer. Structure is discoverable, not prescribed.

## 5. Long-lived artifacts, not session artifacts

Artifacts must outlive sessions, branches, and individual features. Product
briefs, architecture decisions, and system specs are persistent documents
that evolve over the product's lifetime — not throwaway planning files.

## 6. Artifacts serve roles and processes

The artifact structure must be derived from the roles (product owner,
architect, developer, reviewer) and processes (grooming, architecture review,
feature specification, implementation, review) it supports. Structure follows
function.

## 7. Delta-based evolution

Artifacts evolve through changes, not rewrites. OpenSpec's ADDED/MODIFIED/
REMOVED pattern for specs is the right model. Architecture decisions are
append-only (ADRs). Product backlog items change status, not content.

## 8. Concurrent access by design

Multiple agents may read the same artifacts simultaneously. Write conflicts
are managed by convention (one writer per artifact type at a time) not by
locking. The knowledge layer is a shared read surface with controlled writes.
