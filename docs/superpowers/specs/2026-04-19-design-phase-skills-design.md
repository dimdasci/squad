# Design Phase Skills — Design Spec

**Status:** Approved 2026-04-19
**Scope:** Design-phase goal + two skills (`design-system` produce + `design-system-review` validate).
**Supersedes:** Init notes at `docs/superpowers/specs/2026-04-160desing-skill-init.md` (gstack port-notes that fed the brainstorm).

## 1. Purpose of This Spec

Establishes the Design System foundation as a shipped produce/validate pair, matching the pattern of `product-brief` and `architecture-record`. Research happens inline inside the produce skill rather than as separate Reference-layer helper skills. The HTML preview is a single adaptive template generated alongside the draft, not a gated taste-direction artifact.

The prior 2026-04-16 version of this spec proposed five skills (`design-system` + three `design-research-*` helpers + `design-system-review`) with two-pass synthesis (taste direction → detailed draft) and per-surface preview template combinatorics. Complexity review on 2026-04-19 judged that the shipped-pair pattern already proven by `product-brief` and `architecture-record` is the right shape for this foundation too — the novel mechanisms (helper skills with shared-header contracts, two-pass synthesis, five preview template combos) stacked coordination cost without proportional payoff for a solo operator. This spec is the rewrite.

## 2. Design Phase Goal

**What the phase exists to do.** Establish the durable **Design System Doc** as the standard the inner-cycle Design Gate reads during feature implementation.

**When it fires.** Once per product, after `product-brief` is approved and `architecture-record` exists (surfaces must be declared). Re-invoked on rebrands, new-surface additions, major repositioning. Not per-feature, not per-cycle.

**What "done" means.** A Design System Doc at `${product_home}/design/system.md` that:

- Covers all seven content categories (principles, voice and tone, terminology, information architecture, interaction patterns, visual language, surface conventions) adaptively scoped to the product's declared surfaces.
- Carries SAFE vs RISK framing on visual language and voice/tone decisions.
- Carries plain one-line rationale on every other decision.
- Cites inline research where applicable; marks thin sections explicitly as `research-gap`.
- Has a companion HTML preview at `${product_home}/design/preview/<date>.html` covering swatches, type specimens, faux-terminal rendering (CLI surfaces), component samples (GUI surfaces), error-voice snippets (API surfaces), style samples (docs surfaces).
- Passes `design-system-review` validation.
- Has CPTO approval recorded in its Decisions Log.

**What the phase is NOT.** Not feature-level design work (inner-cycle territory). Not a tokens file (tokens live in code). Not a UX flow spec (inner-cycle Implementation Spec territory). Not marketing brand (Product Identity + Product Brief territory).

**Role alignment.** Designer role owns Design System and Product Identity foundations. `design-system` is the Designer's primary foundation-building skill. CPTO observes, challenges, approves.

## 3. Surfaces in Scope

The phase covers design for the following product surfaces:

- **GUI** — web, mobile, desktop apps with visual interfaces.
- **CLI** — classic command-line tools, terminal UI (TUI) apps, and LLM-callable CLI tools as an output-mode variant. MCP servers are **not** a distinct surface; LLM-facing design collapses into CLI output modes (alongside human and JSON modes).
- **API** — machine-consumed interfaces; contract lives in architecture, voice/error-language lives in design system.
- **Docs** — reference and narrative documentation as a designed surface (voice, IA, style).

Adaptive scope (Section 4, Decision 2) means each product populates only the surfaces declared in its `architecture-record`. A CLI-only product gets no typography sub-section; its visual language covers terminal palette, Unicode set, layout rhythm, and faux-terminal previews. A headless API gets no visual language at all; its design work concentrates on error voice, versioning voice, and terminology.

## 4. Decisions

Each decision carries a one-line "because" reflecting the reason pinned during brainstorm + complexity review.

1. **Posture: hybrid consultant.** The produce skill researches with open-ended evidence-gathering, then proposes the whole package with rationale and invites CPTO pushback. *Because a design system assembled answer-by-answer from discovery questions produces incoherence; consultant-style synthesis lets taste hold together.*

2. **Adaptive surface scope.** Produce skill reads declared surfaces from `architecture-record` and populates only the categories/sub-sections that apply. Missing categories don't appear at all; no "N/A" placeholders. *Because thin placeholder sections signal absent taste, same as slop does.*

3. **MCP deprioritized toward CLI.** LLM-facing surface is a CLI output-mode variant, not a distinct surface. *Because MCP adds server abstraction cost without matching payoff; LLM-readable CLI output is cheaper and more composable.*

4. **Research inline, not as separate skills.** Produce skill does peer-product lookups, standards checks, and audience tracing inline using WebFetch/WebSearch plus built-in knowledge, citing sources in the doc. No Reference-layer helper skills at this foundation stage. *Because three separate helper skills with a shared-header contract and offer-once dependency handling added coordination cost without proportional payoff for a solo operator; the shipped-pair pattern (`product-brief`, `architecture-record`) already proves inline research works.*

5. **SAFE vs RISK framing for visual language + voice/tone only.** Other categories use plain one-line rationale. *Because SAFE/RISK earns its keep where there's a recognizable category expectation and room for signal via deliberate departure. Terminology, IA, and interaction patterns are mostly consistent-or-not.*

6. **Single-pass draft with inline CPTO iteration.** No gated taste-direction pre-pass. Produce skill writes the whole doc + preview together; CPTO pushes back conversationally; iterate until direction is accepted. *Because the two-pass design traded simplicity for coherence control that inline conversational iteration already provides, at lower process cost.*

7. **Anti-slop catalog baked into both skills, single source at the validator.** Named anti-patterns live in `squad/skills/design-system-review/anti-slop.md`; the produce skill references it by relative path. *Because design is where "generic" is most detectable and most harmful; named patterns work better than "feels generic" hand-waving for both producer and reviewer.*

8. **Pre-check existing-doc: update/fresh/cancel.** Produce skill detects existing `system.md` on entry and asks CPTO intent explicitly. On update, the Decisions Log grows by one row. On fresh start, the existing doc is archived to `system.<date>.md.bak` and the new doc's Decisions Log opens with a `replaced` row pointing at the `.bak` — so the fresh start is itself a logged decision, not a silent rename. *Because durable artifacts need explicit intent; a deliberate replacement should leave a visible audit trail.*

9. **HTML preview as load-bearing taste signal.** Single adaptive template with conditional sections per declared surface (swatches, type specimens, faux-terminal for CLI, component samples for GUI, error-voice snippets for API, style samples for docs). Generated alongside the draft, regenerated from the final doc on approval. Non-durable but reproducible. *Because visual decisions are hard to judge from text; pattern validated in gstack and superpowers practice.*

### Defaults carried forward (not new decisions)

- `product-naming` invoked as a sub-skill when brief has no name (cross-foundation orchestration per existing contract in `docs/ideation/squad-skills-architecture.md`).
- No outside-voices parallel-proposal pattern for v1.
- All artifacts under `${product_home}/`; plugin-wide user config principle.
- Sub-skill Report protocol (DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED) per `squad-skills-architecture.md`.

## 5. Skill Family Structure

Two skills in the `design-system` family:

| Skill | Role | Type | Validator? |
|---|---|---|---|
| `design-system` | Designer | Produce | Yes — `design-system-review` |
| `design-system-review` | QA / Reviewer | Validate (fork-context) | — |

**Cross-foundation dependency.** `product-naming` (shipped, Product Identity foundation) is invoked by `design-system` as a sub-skill when the brief has no name. Not part of the family but part of the produce skill's prereq chain.

**Required read-only inputs for the produce skill:**

- `${product_home}/product/brief.md` (must be approved)
- `${product_home}/architecture/record.md` (must exist — declares surfaces)
- `${product_home}/identity/naming.md` (invoked via `product-naming` if missing)

**Artifact paths:**

```
${product_home}/
├── design/
│   ├── system.md              # Durable Design System Doc
│   ├── preview/<date>.html    # HTML preview (non-durable, reproducible)
│   └── reviews/<date>.md      # Fork validator reports (audit trail)
└── identity/
    └── naming.md              # Product Identity (separate foundation)
```

**Invocation patterns:**

| CPTO intent | Invocation |
|---|---|
| Full phase end-to-end | `/design-system` |
| Update existing Doc | `/design-system` (pre-check prompts update/fresh/cancel) |
| Audit existing Doc standalone | `/design-system-review` |

## 6. Produce Skill Flow (`design-system`)

Seven phases in order. Each has a clear termination condition; escalation rules at the bottom.

**Phase 1 — Prerequisite check (hard gate).** Read `product-brief` (required, must be approved) and `architecture-record` (required, must declare surfaces). Missing → stop with an instruction for CPTO to run the prereq skill first. Never proceed with synthetic values.

**Phase 2 — Existing-doc detection.** If `${product_home}/design/system.md` exists, summarize (last-modified date, categories covered, last Decisions Log entry) and prompt CPTO: `(u) update specific categories | (f) fresh start | (c) cancel | or chat about this`. On update, CPTO names the scope (category list and/or surface list) and the synthesis runs scoped to that set. On fresh, archive the existing doc to `system.<date>.md.bak`, proceed clean, and open the new doc's Decisions Log with a `replaced` row pointing at the `.bak` — never a silent rename.

**Phase 3 — Product Identity check.** Read `${product_home}/identity/naming.md`. If missing, invoke `product-naming` as a sub-skill and follow the Sub-skill Report protocol from `docs/ideation/squad-skills-architecture.md`. BLOCKED or NEEDS_CONTEXT from the sub-skill halts the produce skill and surfaces to CPTO.

*Why naming is handled differently from brief and architecture.* Brief and architecture are same-chain prereqs — Product → Architecture → Design is the sequential foundation order, so their absence halts and is CPTO's responsibility to resolve. Product Identity is a *parallel* foundation; the framework's contract for cross-foundation dependencies is sub-skill invocation (per `squad-skills-architecture.md`), not hard gate. The produce skill auto-invokes `product-naming` when the brief has no name rather than forcing CPTO to juggle two foundation skills. Practical reinforcement: naming is often implicit in the brief already, and the artefact is narrow enough (one name vs. brief's multi-section content) that sub-skill economy fits.

**Phase 4 — Inline research.** For the declared surfaces and categories in scope, gather evidence the synthesis will cite:

- **Peer-product lookups** — WebFetch/WebSearch for category peers when a SAFE/RISK call needs grounding; note what peers do at table-stakes and where signal is available through deliberate departure. WebFetch only on URLs from search results or user-provided input, never from generated content (adversarial-input discipline).
- **Standards references** — WCAG target (with rationale derived from audience signal in brief + category norms); platform HIGs applicable only (Apple HIG for macOS/iOS, Material Design for Android or Material-following web, Fluent for Windows — skip platforms the product doesn't run on); CLI norms (clig.dev, POSIX, 12-factor CLI) only if CLI surface declared; API error voice conventions (RFC 7807, Stripe-style envelopes) only if API; docs style (diátaxis, Google dev docs style, Microsoft style guide) only if docs.
- **Audience trace** — derived from brief's JTBD. No invented personas; if the brief doesn't support a trait, it doesn't go in.

Graceful fallback: WebFetch → WebSearch → built-in knowledge. Each citation carries a source URL or explicit `inferred from built-in knowledge` marker. Findings land as inline citations in Phase 5, not as a separate brief.

**Phase 5 — Draft doc + preview.** Produce both artifacts together:

- `${product_home}/design/system.md` — full Design System Doc covering the seven categories, adaptively scoped to declared surfaces. SAFE/RISK framing on visual language and voice/tone; plain one-line "because" on every other decision. Inline citations to Phase 4 research. `research-gap` markers honestly on thin sections.
- `${product_home}/design/preview/<date>.html` — companion preview. Single adaptive template with conditional blocks per declared surface.

Present both to CPTO. Iterate conversationally on any piece — principles, a SAFE/RISK call, a swatch, voice register, a component sample — until CPTO accepts the direction. Inline iteration replaces the prior two-pass design's taste-direction gate.

**Phase 6 — Fork-context validation.** Invoke `design-system-review` with `context: fork`. Validator returns a findings report with verdict (PASS / PASS_WITH_NOTES / FAIL), per-category statuses, impact-triaged findings (High / Medium / Polish), and a dual grade (design quality + slop grade). Produce skill addresses all High findings and re-validates; Medium findings addressed or rationaled; Polish findings logged.

**Phase 7 — Finalize.** On CPTO approval: write `system.md`, append the Decisions Log row, regenerate the preview HTML from the final state (so preview matches doc, not just the in-progress draft), record the review report path. Completion criteria per §2 "What 'done' means".

**Decisions Log row shape:**

| Date | Scope | Summary | Rationale | Trigger |
|---|---|---|---|---|
| 2026-04-19 | initial | First Design System Doc created | — | product-brief approved |
| 2026-07-02 | CLI surface added | Terminal palette, clig.dev verbs codified | new surface declared in architecture-record | arch update |

**Escalation and failure modes:**

- **Prereq missing** → stop, instruct CPTO to run prereq first.
- **Sub-skill BLOCKED** → surface reason verbatim; never fall through silently.
- **Validator FAIL after 3 iterations on the same High findings** → escalate to CPTO with a recurrence note.
- **CPTO requests changes 5+ times** → ask whether direction is still right or research needs revisit.

**Idempotency.** Re-running `/design-system` after approval goes through Phase 2 again; no silent overwrites. Update mode can scope to a subset of categories/surfaces; preview regen can be skipped on narrow updates that don't touch visual language.

## 7. Validator Shape (`design-system-review`)

Fork-context validator for the Design System Doc. Invoked by `design-system` after the draft lands; invocable standalone by CPTO for audit.

**Inputs read:** `design/system.md`, `design/preview/<latest>.html`, `product/brief.md`, `architecture/record.md`, `identity/naming.md`.

**Output:** a structured findings report at `${product_home}/design/reviews/<date>.md`. Never rewrites the doc.

**Report shape:**

```markdown
# Design System Review — <date>

## Classification
- Surfaces declared (arch-record): GUI | CLI | API | docs
- Surfaces covered in doc: <match? if not — finding>
- Update or fresh: <mode>

## Verdict
- Overall: PASS | PASS_WITH_NOTES | FAIL
- Design quality grade: A | B | C | D | F
- Slop grade: clean | minor-slop | material-slop

## Per-category checks
<Principles, Voice and tone, Terminology, IA, Interaction patterns,
 Visual language, Surface conventions — each with PASS / NOTES / FAIL
 and key findings.>

## Cross-cutting checks
- Research citation presence
- Brief alignment
- Decisions Log row present (and `replaced` row on fresh-start)
- Preview alignment (HTML matches doc)
- SAFE/RISK discipline (real risk vs fake rebellion)

## Findings (impact-triaged)
### High — must fix before approval
### Medium — should fix, not blocking
### Polish — note only
```

Each finding: what, where (section + quoted span), why it matters, suggested fix direction (not a rewrite).

**Impact triage:**

- **High** — material deviation that would produce confused feature-work downstream (missing surface coverage, principles contradict brief, anti-slop pattern named in catalog, fabricated section for undeclared surface, no citations where evidence should exist).
- **Medium** — weakens the doc but doesn't break it (thin rationale, confidence not declared, minor coherence drift).
- **Polish** — note-only (phrasing, ordering, typos).

**Depth over breadth.** Target 5 to 12 well-documented findings, not 30 vague observations.

**Anti-slop catalog.** Single source at `squad/skills/design-system-review/anti-slop.md`; `design-system/SKILL.md` references it by relative path. Two halves:

- **Doc-prose slop** — vague principles ("be delightful"), generic voice ("friendly but professional"), unanchored adjectives, fake SAFE/RISK (RISK that's cosmetic, e.g. "use #007acc instead of #0066cc"), undefined concept mentions, filler without evidence.
- **Visual/content slop (preview HTML)** — purple gradients, 3-col icon grids, decorative blobs, emoji-as-design, colored-left-border cards, uniform bubbly radii, centered-everything layouts, generic hero copy, overused display fonts (Inter/Roboto/Poppins) without rationale.

Each named pattern carries a one-line "why it's slop" so the validator applies specific craft rules, not fashion judgments.

**Evidence requirement.** Every finding cites a section and quoted span. No "feels generic" without a pointer.

**Recurrence handling.** If the produce skill re-runs the validator 3 times on the same High findings, validator includes a recurrence note to escalate to CPTO.

**What this validator does NOT do:**

- Does not validate product UI code — that's `design-gate` (inner-cycle skill, separate scope).
- Does not re-run research — flags "research gap" and suggests the produce skill run update mode.
- Does not second-guess CPTO-approved SAFE/RISK calls — flags fake rebellion or inconsistency, not taste disagreement. ("Fake rebellion" = a RISK choice that departs from category norm without earning the departure.)
- Does not flag legitimately absent sections for undeclared surfaces as missing — adaptive scope discipline. Conversely, flags fabricated sections for undeclared surfaces.

## 8. Per-Skill Init Briefs (Handoffs)

Short handoff briefs for the per-skill brainstorms that produce the shipped SKILL.md + support files.

### `design-system`

- **Role:** Designer. Foundation: Design System. Posture: consultant (hybrid per Decision 1).
- **Inputs:** `product-brief` (required), `architecture-record` (required), `identity/naming.md` (required; invokes `product-naming` if missing), existing `design/system.md` (for update detection).
- **Outputs:** `design/system.md` (durable, 7-category adaptive), `design/preview/<date>.html` (companion, non-durable, single adaptive template), Decisions Log row.
- **Methodology pointers:** consultant posture, propose-whole, one-line "because" per decision, SAFE vs RISK for visual language + voice/tone, inline research (not separate briefs), single-pass synthesis with inline CPTO iteration, adaptive scope, gstack DESIGN.md as structural template for visual-language section, WebFetch adversarial-input discipline.
- **Anticipated support files:** `SKILL.md` (process + checklist), `synthesis-guide.md` (consultant posture + SAFE/RISK framing + inline-research discipline), `preview-template.html` (single adaptive skeletal HTML with conditional sections per surface).
- **References:** anti-slop catalog at `../design-system-review/anti-slop.md` (relative path).
- **Open for per-skill brainstorm:**
  - Surface-detection logic (strict read of arch-record vs CPTO confirmation prompt).
  - Preview HTML component set per declared surface (what exactly renders for GUI vs CLI vs API vs docs, and how conditional blocks compose for multi-surface products).
  - Whether update-mode with narrow scope can skip preview regeneration.
  - Decisions Log exact schema (columns, triggers, what changes warrant a row).
  - Inline-research discipline — how much research depth per decision, when to stop searching and commit to a call.

### `design-system-review`

- **Role:** QA / Reviewer. Fork-context validator.
- **Inputs:** `design/system.md`, `design/preview/<latest>.html`, `product/brief.md`, `architecture/record.md`, `identity/naming.md`.
- **Outputs:** findings report at `design/reviews/<date>.md`.
- **Methodology pointers:** per-category + cross-cutting checklist, impact triage, dual scoring, evidence-per-finding, depth over breadth, owns the single-source anti-slop catalog.
- **Anticipated support files:** `SKILL.md` (process + verdict taxonomy), `checklist.md` (per-category + cross-cutting), `anti-slop.md` (single source, referenced by produce skill).
- **Open for per-skill brainstorm:**
  - Exact checklist items per category (what makes a principle specific vs generic; what makes a voice register concrete vs vague).
  - First-draft anti-slop catalog content — named patterns with why-it's-slop lines.
  - Preview-alignment check mechanics (HTML parse vs sanity-read).
  - SAFE vs RISK discipline check — how to distinguish real RISK from fake rebellion.
  - Recurrence escalation threshold (3 iterations — confirm or tune).
  - Adaptive-scope discipline check — flagging fabricated sections for undeclared surfaces without flagging legitimately absent ones.
  - Existing-doc-audit checks: `system.<date>.md.bak` archival presence on fresh-start, and the `replaced` row in the new doc's Decisions Log pointing at the `.bak` path.

### Cross-cutting notes

- Both skills follow checklist-driven shape (TaskCreate per step).
- Produce skill self-validates before invoking review (catches own thin sections, `research-gap` markers, missing citations).
- Anti-slop catalog single-source at `squad/skills/design-system-review/anti-slop.md`. If Claude Code rejects cross-skill relative paths at runtime, fallback is a `squad/skills/_shared/anti-slop.md` referenced by both; decide at produce-skill brainstorm time via a plugin-load probe.
- HTML preview behavior and templates scoped to `design-system` only.

## 9. Build Order and Dependencies

Two-skill pair, shipped in order:

1. **`design-system`** (produce) — implements Phases 1-7 of Section 6. During development, the anti-slop reference points at §7 by name (the target file doesn't exist yet); when `design-system-review` ships, the SKILL.md reference is updated to point at the real file.
2. **`design-system-review`** (validate) — depends on `design-system` producing artifacts to validate. During development, mocked `system.md` fixtures are acceptable; manual execution test consumes a real doc from a `design-system` run.

Each per-skill brainstorm produces: a design spec (scoped to that skill), a writing-plans handoff, the SKILL.md + support files, tests at knowledge and triggering tiers, and a manual execution test on a playground product.

**Manual execution test target:** skill-playground (Audenza) at `/Users/dim/contexts/personal/projects/skill-playground/docs/`. Already carries approved `product/brief.md`, approved `architecture/record.md` (declares GUI + API surfaces), and approved `identity/naming.md`. GUI + API is the exercised subset; CLI and docs template logic is verified by code review of `preview-template.html`, not by run. The framework must still design for all four surfaces — per-skill brainstorms cannot scope CLI or docs out on the grounds that the playground doesn't exercise them.

## 10. What's Out of Scope for This Spec

- Exact SKILL.md checklist item wording (per-skill brainstorm output).
- First-draft anti-slop catalog content (`design-system-review` brainstorm output).
- Preview HTML template implementation detail (`design-system` brainstorm output).
- The inner-cycle `design-gate` skill — spec'd separately, not in this family.
- Test tier strategy per skill — follows framework's three-tier pattern; execution-tier automated tests deferred pending `docs/superpowers/specs/2026-04-11-test-cost-model.md` resolution. Manual execution test on skill-playground replaces the automated execution tier for phase acceptance.

## 11. References

- `docs/ideation/squad-process-model.md` — 5 roles, 4 gates, 4 durable foundations.
- `docs/ideation/squad-artifacts.md` — 18 artifacts across 5 layers; Design System Doc scope.
- `docs/ideation/squad-skills-architecture.md` — produce/validate pattern, orchestration contract, Sub-skill Report protocol, build order.
- `docs/superpowers/specs/2026-04-160desing-skill-init.md` — gstack port-notes (input).
- `docs/superpowers/specs/2026-04-11-product-naming-design.md` — neighboring shipped Designer-role foundation skill.
- `squad/skills/product-brief/` and `squad/skills/architecture-record/` — shipped produce/validate pairs; shape reference for this family.
