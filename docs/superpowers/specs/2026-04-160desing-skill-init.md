Goal: Lightweight skill-based framework extending Superpowers upward — bridges product scope (vision, decomposition, backlog) into the feature-scope execution loop Superpowers already handles well.

Methodology:
  - 5 roles (Product Owner, Architect, Designer, Developer, QA/Reviewer), 4 gates (Product = human, Architecture/Design/QA = automated), 4 durable foundations (Product,
  Architecture, Design System, Product Identity).
  - 18 artifacts across 5 layers (Durable 8, Outer 2, Inner 3, Continuous 2, Reference 3+).
  - Produce/validate skill pairs — validator forks context for independent review, never rewrites.

 Current status:
  - Shipped pairs in squad/skills/: product-brief, architecture-record, product-naming (all with -review validators).
  - Remaining: design-system orchestrator + 3 design-research-* helpers (next block), then 5 gate skills, then outer/continuous artifacts.
  - Test-cost rethink pending — docs/superpowers/specs/2026-04-11-test-cost-model.md has 4 options; per-skill filter (Option 1) is the no-regret starting move.

 Information map:
  - CLAUDE.md — charter + key doc pointers
  - docs/product-statement.md — gap + principles
  - docs/ideation/ — process model, artifacts, skills architecture (the three load-bearing specs)
  - docs/analyses/ — framework deep-dives (gstack, superpowers, pm-skills, gsd2, openspec)
  - docs/superpowers/specs/ — active design specs (test-cost, product-naming)
  - squad/skills/ — 3 produce/validate pairs shipped
  - tests/ — 3 tiers (knowledge ~30s, triggering ~30s, execution 5–15min)
  - repos/ — external framework sources for reference

From gstack/design-consultation:
  - Posture: consultant proposes a coherent system, not a form that collects answers — opinionated with rationale, invites pushback, never a menu of pre-sorted choices.
  - Propose whole, not parts: aesthetic, typography, color, spacing, layout, motion land together as one package so coherence is the default, not a post-hoc check.
  - Every recommendation carries a one-line "because" — no decision without rationale attached to the artifact.
  - SAFE vs RISK split: 2-3 category-baseline decisions users expect, plus 2-3 deliberate departures with cost/gain explicit — forces the design to have a face, not just be literate.
  - Three-layer synthesis on research: table stakes (category convergence), current trends, first-principles departures — matches our Layer 1/2/3 ethos, useful for design-research-* helpers.
  - Coherence validator as nudge, not block: flag known mismatches (e.g. brutalist + expressive motion) with a question, accept user's final call — good pattern for design-system validate.
  - Graceful degradation on research tooling: browse+snapshots → WebSearch → built-in knowledge — each design-research-* helper should declare its fallback explicitly.
  - Pre-check for existing artifact: read DESIGN.md if present, ask update/fresh/cancel — delta-friendly, matches our durable-foundation evolution model.
  - Product context as input, not rediscovery: consume upstream artifact (office-hours / product-brief) before asking the user anything.
  - Anti-slop blacklists are load-bearing content: overused fonts (Inter/Roboto/Poppins), AI-slop patterns (purple gradients, 3-col icon grids, bubbly radii) — ship these as explicit negative lists inside the skill.
  - Font guidance by role: display / body / data (tabular-nums) / code — role-indexed, not a flat pool.
  - Preview artifact is a taste signal: whatever the skill emits (HTML, tokens, DESIGN.md) must itself demonstrate the taste it is recommending — sloppy output kills the skill's authority.
  - DESIGN.md shape worth stealing: Product Context, Aesthetic, Typography, Color, Spacing, Layout, Motion, Decisions Log — clean template for our Design System foundation.
  - Decisions Log as living row-per-change table — fits our delta-based evolution better than rewriting the whole artifact.
  - Outside-voices pattern: parallel independent proposal (codex + subagent) run alongside the main agent, surfaced as agree/diverge — reusable for any durable-foundation produce skill, not only design.
  - Skipped: YC/Garry voice, Boil-the-Lake branding, telemetry/proactive/routing preambles, gstack binary harness ($B/$D), AskUserQuestion 4-step ceremony, completeness-score rubric, learnings JSONL plumbing, effort-compression table, clawhub publishing — all gstack-harness, not design substance.

From gstack/design-review:
  - Classifier first: marketing/landing vs app-UI vs hybrid — rule set differs; reviewer must label artifact before judging.
  - Calibrate against the artifact, not universal taste: if DESIGN.md exists, deviations are higher severity; absent, fall back to universal rules and flag the gap.
  - Dual scoring: headline design grade AND a standalone "AI slop" grade — weighted average plus blunt verdict, keeps slop visible instead of averaged away.
  - Per-category letter grades with deterministic drop: each High finding = -1 letter, Medium = -0.5, Polish = note only. Makes validator output reproducible, not vibes.
  - Impact triage on every finding: High / Medium / Polish — validator must tag, not just list.
  - Hard-rejection list (instant-fail patterns) separate from scored checklist — short, categorical, no nuance — good shape for binary gate checks.
  - Litmus checks as YES/NO scorecard — 6-8 crisp questions a forked reviewer can answer without re-reading the whole artifact.
  - AI-slop blacklist as named anti-patterns (purple gradients, 3-col feature grid, icons-in-circles, centered-everything, bubbly uniform radius, decorative blobs, emoji-as-design, colored-left-border cards, generic hero copy, cookie-cutter rhythm). Reviewers need named patterns, not "feels generic".
  - Structured critique verbs: "I notice / I wonder / What if / I think because" — forces observation + question + suggestion + reasoning, not opinion dumps.
  - Squint / trunk / page-area heuristics: blur-still-has-hierarchy, name-each-area-in-2s, answer where-am-I. Apply to the design-system doc itself — does it pass its own tests?
  - Goodwill reservoir as running tally with specific drains/fills — framing for design-research reviewers evaluating user-flow artifacts.
  - Universal hard rules worth stealing verbatim: body >= 16px at 4.5:1 contrast, no placeholder-as-label, preserve visited-link distinction, heading attached to following section — non-negotiable.
  - Evidence requirement: every finding carries a specific referent (element, file:line, quote). Squad equivalent: cite artifact section + quoted span.
  - Depth over breadth: 5-10 well-documented findings with suggestions beat 20 vague observations — matches our prose-first review style.
  - Skipped: ETHOS/voice content, proactive-suggestion harness, telemetry/learnings plumbing, live-browser fix loop (phases 7-10 — Superpowers execution-loop territory), test-framework bootstrap, DESIGN.md auto-generation flow, outside-voices orchestration (fork-context review already covers it), completeness/boil-the-lake framing.
