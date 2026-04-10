# Shared Knowledge Layer

> **Status: design rationale.** This doc explains *why* squad
> artifacts live outside the working tree in a shared directory —
> the motivation and design decision. The current implementation
> uses `${user_config.product_home}` (not `${user_config.product_home}`), and the
> artifact taxonomy has evolved into five layers with four durable
> foundations. See `squad-artifacts.md` and `squad-skills-architecture.md`
> for the current state. Preserved here because the rationale
> remains load-bearing for anyone questioning *why* the shared
> external path exists at all.

The critical design constraint: artifacts must be accessible to multiple
Claude Code instances working on independent branches simultaneously.

## The Problem

Every framework we analyzed stores artifacts inside the repository:
- Superpowers: `docs/superpowers/plans/`
- OpenSpec: `openspec/specs/`
- GSD-2: `.gsd/milestones/`

When multiple Claude Code instances work on independent branches (via git
worktrees or separate clones), each branch gets its own copy of these
artifacts. They diverge immediately. Instance A's architecture decisions
are invisible to Instance B.

## The Solution: External Artifact Root

Artifacts live at a path defined by an environment variable (e.g.,
`${user_config.product_home}`). This path is:
- **Outside the repository working tree** — not affected by branch switches
- **Shared across all Claude Code instances** for the same project
- **Readable by any session** without checkout or merge
- **Configurable per project** — different projects, different roots

## Access Patterns

```
Instance A (branch: feature-auth)     Instance B (branch: feature-payments)
         │                                        │
         ├── reads ${user_config.product_home}/product/brief.md │
         ├── reads ${user_config.product_home}/arch/components.md
         ├── reads ${user_config.product_home}/specs/auth/       │
         │                                        ├── reads ${user_config.product_home}/specs/payments/
         │                                        │
         ├── WRITES ${user_config.product_home}/specs/auth/     │ (after feature ships)
         │                                        ├── WRITES ${user_config.product_home}/specs/payments/
```

**Read:** Any instance reads any artifact at any time.
**Write:** Controlled by convention — one writer per artifact scope at a time.
Architecture-level artifacts (component map, ADRs) are append-only or
updated by a designated session.

## Open Questions

1. **File format:** Plain markdown? YAML frontmatter + markdown? JSON for
   structured data (backlog items)?
2. **Concurrency:** Is convention (one writer per scope) sufficient, or do
   we need advisory locks?
3. **Discovery:** How does a skill find what artifacts exist? Directory
   scan? Index file? Convention-based paths?
4. **Bootstrapping:** What's the minimal set of artifacts to start? Can
   layers be added incrementally?
5. **Cleanup:** How do stale artifacts get updated or removed? Who owns
   artifact lifecycle?
