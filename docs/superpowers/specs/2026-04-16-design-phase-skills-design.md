# Design Phase Skills — Design Spec

**Status:** Approved 2026-04-16
**Scope:** Design-phase goal + five skills (`design-system`, `design-system-review`, `design-research-references`, `design-research-audience`, `design-research-standards`) + handoff briefs for per-skill follow-up brainstorms.
**Supersedes:** Init notes at `docs/superpowers/specs/2026-04-160desing-skill-init.md` (gstack port-notes that fed this brainstorm).

## 1. Purpose of This Spec

Establishes the phase-level architecture for the Design System foundation in squad, plus a handoff brief per skill. Each of the five skills will get its own per-skill design spec in a follow-up brainstorm; this spec pins the shared decisions so those follow-ups don't re-litigate them. Out-of-scope items enumerated in §11.

## 2. Design Phase Goal

**What the phase exists to do.** Establish the durable **Design System Doc** as the standard the inner-cycle Design Gate reads during feature implementation, plus three Reference-layer research briefs that fed its synthesis.

**When it fires.** Once per product, after `product-brief` is approved and `architecture-record` exists (surfaces must be declared). Re-invoked on rebrands, new-surface additions, major repositioning. Not per-feature, not per-cycle.

**What "done" means.** A Design System Doc at `${product_home}/design/system.md` that:

- Covers all seven content categories (principles, voice and tone, terminology, information architecture, interaction patterns, visual language, surface conventions) adaptively scoped to the product's declared surfaces.
- Carries SAFE vs RISK framing on visual language and voice/tone decisions.
- Carries plain one-line rationale on every other decision.
- Cites the research briefs that shaped it, and explicitly declares research gaps where helpers were skipped.
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

Adaptive scope (Section 6) means each product populates only the surfaces declared in its `architecture-record`. A CLI-only product gets no typography sub-section; its visual language covers terminal palette, Unicode set, layout rhythm, and faux-terminal previews. A headless API gets no visual language at all; its design work concentrates on error voice, versioning voice, and terminology.

## 4. Decisions (What This Brainstorm Pinned)

Each decision carries a one-line "because" reflecting the reason from the Q&A loop.

1. **Posture: hybrid consultant** *(new vocabulary pinned in this spec — not inherited from foundation docs).* Research helpers use open-ended evidence-gathering; orchestrator uses consultant-style synthesis (proposes the whole package with rationale, invites pushback). *Because research is facts and synthesis is taste, and assembling a design system piece by piece from user answers produces incoherence.*

2. **Adaptive surface scope.** Orchestrator reads declared surfaces from `architecture-record` and populates only the categories/sub-sections that apply. Missing categories don't appear at all; no "N/A" placeholders. *Because thin "N/A" sections signal absent taste, same as sloppy output does. The consultant posture requires that what's in the doc matters.*

3. **MCP deprioritized toward CLI.** LLM-facing surface is a CLI output-mode variant, not a distinct surface. *Because MCP adds server abstraction cost without matching payoff, and LLM-readable CLI output is the cheaper, more composable path.*

4. **Offer-once dependency handling.** When research briefs are missing, orchestrator prompts CPTO once with `(a) run all | (p) pick which | (s) skip and synthesize from built-in knowledge | or chat about this`. *Because research helpers are substantial work (5–15 min each of Claude time); CPTO should consent to the cost, but shouldn't face a checkpoint gauntlet.*

5. **Research helper shape: shared header, domain body.** All three helpers emit identical front-matter (purpose, surfaces, confidence, sources cited, research gaps, "Decisions for Design System Doc"). Bodies differ by domain. *Because forcing three genuinely different research activities into one template tortures at least two of them; but the orchestrator needs a predictable consumption pattern.*

6. **SAFE vs RISK framing for visual language + voice/tone only.** Other categories use plain one-line rationale. *Because SAFE/RISK earns its keep where there's a recognizable category expectation and room for signal via deliberate departure. Terminology and IA aren't "SAFE vs RISK"; they're consistent or not. Interaction patterns are mostly platform-determined.*

7. **Two-pass synthesis: taste direction → detailed draft.** Taste direction is a short artifact (principles, aesthetic posture, SAFE/RISK calls) plus an HTML preview; CPTO aligns cheaply before orchestrator commits the full draft. *Because the full doc is substantial and first-draft surprises are expensive to undo; but the full draft must be reviewed as one piece — category-by-category approvals fragment taste.*

8. **Anti-slop blacklists baked into both produce and validate skills.** Named anti-patterns in support files; produce avoids them upfront, validate flags them in review. *Because design is where "generic" is most detectable and most harmful, and named patterns work better than "feels generic" hand-waving for both producer and reviewer.*

9. **Pre-check existing-doc: update/fresh/cancel.** Orchestrator detects existing `system.md` on entry and asks CPTO intent explicitly. On update, the Decisions Log grows by one row. On fresh start, the existing doc is archived to `system.<date>.md.bak` *and* the new doc's Decisions Log opens with a `replaced` row referencing the `.bak` path — so the fresh start is itself a logged decision, not a silent rename. *Because durable artifacts need explicit intent — CPTO shouldn't accidentally rewrite months of accumulated taste by re-invoking, and even a deliberate replacement should leave a visible audit trail.*

10. **HTML preview as load-bearing taste signal.** Taste-direction pass emits a viewable HTML preview (swatches, type specimens, faux-terminal output for CLI surfaces, component samples for GUI surfaces) alongside the prose taste direction. Non-durable but reproducible from the Doc. *Because visual decisions are hard to judge from text and preview is a taste accountability signal; pattern validated in gstack and superpowers practice.*

### Defaults carried forward (not new decisions)

- `product-naming` invoked as a sub-skill when brief has no name (cross-foundation orchestration per existing contract in `docs/ideation/squad-skills-architecture.md`).
- No outside-voices parallel-proposal pattern for v1 (fork-context review is outside-voices enough; additional parallel layer is too heavy).
- No separate preview-only artifact beyond the taste-direction HTML — the Doc itself is the durable output; regenerating the preview from the Doc is cheap.
- Reference-layer helpers are self-validated; no fork-context validators for them (per `docs/ideation/squad-artifacts.md`).
- All artifacts under `${product_home}/`; plugin-wide user config principle.

## 5. Skill Family Structure

Five skills in the `design-system` family:

| Skill | Role | Type | Validator? |
|---|---|---|---|
| `design-system` | Designer | Produce (orchestrator) | Yes — `design-system-review` |
| `design-system-review` | QA / Reviewer | Validate (fork-context) | — |
| `design-research-references` | Designer | Produce (Reference layer) | Self-validated |
| `design-research-audience` | Designer | Produce (Reference layer) | Self-validated |
| `design-research-standards` | Designer | Produce (Reference layer) | Self-validated |

**Cross-foundation dependency.** `product-naming` (shipped, Product Identity foundation) is invoked by `design-system` as a sub-skill when the brief has no name. Not part of the family but part of the orchestrator's prereq chain.

**Required read-only inputs for the orchestrator:**

- `${product_home}/product/brief.md` (must be approved)
- `${product_home}/architecture/record.md` (must exist — declares surfaces)
- `${product_home}/identity/naming.md` (invoked via `product-naming` if missing)

**Optional inputs (offer-once handling):**

- `${product_home}/design/research/references.md`
- `${product_home}/design/research/audience.md`
- `${product_home}/design/research/standards.md`

**Artifact paths:**

```
${product_home}/
├── design/
│   ├── system.md                       # Durable Design System Doc
│   ├── preview/<date>.html             # HTML preview (non-durable, reproducible)
│   ├── research/
│   │   ├── references.md               # Reference layer, self-validated
│   │   ├── audience.md
│   │   └── standards.md
│   └── reviews/<date>.md               # Fork validator reports (audit trail)
└── identity/
    └── naming.md                       # Product Identity (separate foundation)
```

**Invocation patterns (all skills independently invocable):**

| CPTO intent | Invocation |
|---|---|
| Full phase end-to-end | `/design-system` (orchestrator handles prereqs) |
| Peer-product research only | `/design-research-references` |
| Audience analysis only | `/design-research-audience` |
| Standards survey only | `/design-research-standards` |
| Synthesize from existing research | `/design-system` (skips helpers; detects existing briefs) |
| Update existing Doc | `/design-system` (pre-check prompts update/fresh/cancel) |
| Audit existing Doc standalone | `/design-system-review` |

## 6. Orchestrator Flow (`design-system`)

Ten phases in order. Each phase has a clear termination condition; escalation rules spelled out at the bottom.

**Phase 1 — Prerequisite check (hard gate).** Read `product-brief` (required, must be approved) and `architecture-record` (required, must declare surfaces). Missing → stop with an instruction for CPTO to run the prereq skill first. Never proceed with synthetic values.

**Phase 2 — Existing-doc detection.** If `${product_home}/design/system.md` exists, summarize (last-modified date, categories covered, last Decisions Log entry) and prompt CPTO: `(u) update specific categories | (f) fresh start | (c) cancel | or chat about this`. On update, CPTO names the scope (category list and/or surface list) and the synthesis runs scoped to that set. On fresh, archive the existing doc to `system.<date>.md.bak`, proceed clean, and open the new doc's Decisions Log with a `replaced` row pointing at the `.bak` — never a silent rename.

**Phase 3 — Product Identity check.** Read `${product_home}/identity/naming.md`. If missing, invoke `product-naming` as a sub-skill and follow the Sub-skill Report protocol from `docs/ideation/squad-skills-architecture.md` (DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED). BLOCKED or NEEDS_CONTEXT from the sub-skill halts the orchestrator and surfaces to CPTO.

**Phase 4 — Research dependency handling.** Check for all three briefs in `${product_home}/design/research/`. Any missing → prompt CPTO once: "Missing: `<list>`. `(a) run all | (p) pick which | (s) skip and synthesize from brief + built-in knowledge | or chat about this`." Run selected helpers sequentially via the Sub-skill Report protocol.

Two failure modes to distinguish — the foundation doc (`squad-artifacts.md`) says "fall through, degrade gracefully" for Reference artifacts, and that applies to the missing-brief case. The BLOCKED case is different:

- **Missing brief (CPTO opted to skip, or helper was never invoked)** → fall through; synthesize with reduced evidence and mark thin sections as `research-gap`. This is the degrade-gracefully path the foundation doc permits.
- **Helper invoked and returned BLOCKED** → halt, surface the reason verbatim to CPTO. Never silently substitute built-in knowledge; CPTO explicitly asked the helper to run, so a silent swap violates agency.

**Phase 5 — Taste direction.** Write a short artifact (roughly one page) with:

- Product context (one paragraph from brief).
- Declared surfaces (from architecture-record) and adaptive scope decision for this doc.
- Three to five principles — crisp, not aspirational; each anchored in a brief reference or research citation.
- Aesthetic and voice posture — where this product sits on the category map.
- Two to three SAFE calls and two to three RISK calls for visual language and voice/tone; each with explicit cost/gain reasoning.
- One-line "because" on every decision.
- Companion HTML preview at `${product_home}/design/preview/<date>-direction.html` — swatches, type specimens, and (for CLI surfaces) faux-terminal rendering of the proposed palette and Unicode set. For GUI surfaces, a small set of rendered component samples applying the proposed tokens.

Present both to CPTO. Loop revisions on pushback until CPTO approves the direction. Cheap iteration here is the point of the two-pass design.

**Phase 6 — Detailed draft.** Produce the full Design System Doc covering the seven categories, adaptively scoped to declared surfaces. SAFE/RISK framing on visual language and voice/tone; plain one-line rationale everywhere else. Cite research briefs inline where they shaped a decision. Mark thin sections honestly where research was skipped (`*research-gap: run /design-research-standards to deepen*`). Lands as a whole, not category by category — coherence is preserved by the two-pass structure, not by incremental category approvals.

**Phase 7 — Fork-context validation.** Invoke `design-system-review` with `context: fork`. Validator returns a findings report with verdict (PASS / PASS_WITH_NOTES / FAIL), per-category statuses, impact-triaged findings (High / Medium / Polish), and a dual grade (design quality + slop grade). Orchestrator addresses all High findings and re-validates; Medium findings addressed or rationaled; Polish findings logged.

**Phase 8 — CPTO approval.** Present full draft plus review report. CPTO options: approve, request changes (loops back to Phase 5 if taste shifts; Phase 6 if category-level; re-validates), or chat.

**Phase 9 — Finalize.** On approval: write `system.md`, append the Decisions Log row, regenerate the preview HTML from the final state (so preview matches doc, not just taste direction), record the review report path. Completion criteria per §2 "What 'done' means".

**Phase 10 — Optional chain.** No default next skill; CPTO picks. The chain target (candidates: CPTO picks next foundation, `product-backlog`, inner-cycle entry) is resolved in the `design-system` per-skill follow-up brainstorm, not here.

**Decisions Log row shape:**

| Date | Scope | Summary | Rationale | Trigger |
|---|---|---|---|---|
| 2026-04-16 | initial | First Design System Doc created | — | product-brief approved |
| 2026-07-02 | CLI surface added | Terminal palette, clig.dev verbs codified | new surface declared in architecture-record | arch update |

**Escalation and failure modes:**

- **Prereq missing** → stop, instruct CPTO to run prereq first.
- **Sub-skill BLOCKED** → surface reason verbatim; never fall through silently.
- **Validator FAIL after 3 iterations on the same High findings** → escalate to CPTO with a recurrence note.
- **CPTO requests changes 5+ times** → ask whether taste direction is still right or research needs revisit.

**Idempotency.** Re-running `/design-system` after approval goes through Phase 2 again; no silent overwrites. Update mode can scope to a subset of categories/surfaces and may skip the taste-direction pass (Phase 5) when scope is narrow (a per-skill follow-up decision — noted in Section 9).

## 7. Research Helper Shape

All three helpers share a header; bodies differ by domain. Self-validated (Reference layer) per `docs/ideation/squad-artifacts.md`.

### Shared header (front-matter for all three)

```markdown
# Design Research — <References | Audience | Standards>

**Product:** <name from product-naming or brief>
**Surfaces in scope:** <GUI | CLI | API | docs — from architecture-record>
**Produced:** <date>
**Confidence:** <overall — high | medium | low; per-section confidence in body>
**Sources cited:** <bulleted list of URLs, tool docs, standards refs>
**Research gaps:** <what we couldn't resolve, why — honesty beats padding>

## Decisions for Design System Doc
<bulleted list — what the orchestrator should take into synthesis.>
```

Orchestrator reads "Decisions for Design System Doc" first; body provides the evidence.

### `design-research-references` (peer-product landscape)

- **Peer-product cards** — 5 to 8 products in or near the category, with 2 to 3 cross-category references for signal. Each card: what it is, why referenced, specific design moves worth noting, what it gets wrong.
- **Category-baseline analysis** — patterns that are table stakes (the SAFE ground).
- **Trending analysis** — current discourse with short shelf life, marked as such.
- **First-principles departures** — where a peer broke category rules, with outcome. Source material for SAFE/RISK calls.
- **Anti-slop flags** — peers exhibiting AI-generic patterns, named so synthesis can avoid them.

**Methodology:** WebFetch + WebSearch for peer products (URLs from search results or user — never from generated content, per the adversarial-input rule). Graceful fallback: WebFetch+browse → WebSearch → built-in knowledge. Each peer card marks which fallback it used.

### `design-research-audience` (JTBD-traced user analysis)

- **Audience trace** — concrete user populations derived directly from brief's JTBD statements. No invented personas.
- **Tool-and-convention inventory** — tools these users already use, mental models they hold, what "just works" means in this category.
- **Accessibility needs** — derived from audience trace, not boilerplate WCAG. Screen reader prevalence, color-blindness, motor constraints, low-bandwidth contexts — only where evidenced.
- **Voice and tone signals** — what register lands, backed by community evidence (how this audience talks, tools they like).
- **Accessibility level recommendation** — proposed WCAG target (A / AA / AAA) with rationale.

**Methodology:** Read brief deeply. Optional WebSearch for community evidence. No primary user research in v1 (no interviews, no surveys); v2 could support CPTO-supplied transcripts.

### `design-research-standards` (applicable rules)

- **WCAG target** — A / AA / AAA with justification from audience brief (if present) and category norms.
- **Platform HIGs** — applicable only (Apple HIG for macOS/iOS, Material Design for Android or Material-following web, Fluent for Windows). Skip platforms the product doesn't run on.
- **Industry regulations** — GDPR / HIPAA / PCI / COPPA etc. only when brief indicates applicability.
- **CLI norms** — clig.dev, POSIX, 12-factor CLI, ecosystem-specific conventions. Only if CLI surface declared.
- **API error voice conventions** — RFC 7807, Stripe-style envelopes, etc. Only if API surface declared.
- **Docs style references** — diátaxis, Google dev docs style, Microsoft style guide. Only if docs surface declared.

**Methodology:** WebFetch for public spec documents; Context7 for library-specific conventions. Fallback: WebSearch → built-in knowledge. Each cited standard carries its source URL.

### Self-validation rules (all three)

Before writing output, producer checks:

1. **Sources** — every "decision for design system doc" is traceable to a cited source OR explicitly marked `inferred from built-in knowledge`.
2. **Coverage** — declared sections are populated; empty sections dropped (not padded).
3. **Anti-slop** — no filler, no uncited assertions dressed as facts, no generic "users want simplicity" padding.
4. **Confidence labeling** — each decision carries high/med/low confidence.

No fork validator. If a helper's output is thin, orchestrator catches it at synthesis ("this brief is too thin to use") and surfaces to CPTO.

## 8. Validator Shape (`design-system-review`)

Fork-context validator for the Design System Doc. Invoked by `design-system` after the detailed-draft pass; invocable standalone by CPTO for audit.

**Inputs read:** `design/system.md`, `design/preview/<latest>.html`, all three research briefs (if present), `product/brief.md`, `architecture/record.md`, `identity/naming.md`.

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
- Decisions Log row present
- Preview alignment (HTML matches doc)
- SAFE/RISK discipline (real risk vs fake rebellion)

## Findings (impact-triaged)
### High — must fix before approval
### Medium — should fix, not blocking
### Polish — note only
```

Each finding: what, where (section + quoted span), why it matters, suggested fix direction (not a rewrite).

**Impact triage:**

- **High** — material deviation that would produce confused feature-work downstream (missing surface coverage, principles contradict brief, anti-slop pattern named in catalog, no research citations where briefs exist).
- **Medium** — weakens the doc but doesn't break it (thin rationale, confidence not declared, minor coherence drift).
- **Polish** — note-only (phrasing, ordering, typos).

**Depth over breadth.** Target 5 to 12 well-documented findings, not 30 vague observations.

**Anti-slop catalog** (content produced in `design-system-review`'s follow-up brainstorm; shared with `design-system/anti-slop.md`):

- **Doc-prose slop** — vague principles ("be delightful"), generic voice ("friendly but professional"), unanchored adjectives, fake SAFE/RISK (RISK that's cosmetic, e.g. "use #007acc instead of #0066cc"), undefined concept mentions, filler without evidence.
- **Visual/content slop (preview HTML)** — purple gradients, 3-col icon grids, decorative blobs, emoji-as-design, colored-left-border cards, uniform bubbly radii, centered-everything layouts, generic hero copy, overused display fonts (Inter/Roboto/Poppins) without rationale.

Each named pattern carries a one-line "why it's slop" so the validator applies specific craft rules, not fashion judgments.

**Evidence requirement.** Every finding cites a section and quoted span. No "feels generic" without a pointer. Matches shipped pairs' prose-first, evidence-backed style.

**Recurrence handling.** If orchestrator re-runs validator 3 times on the same High findings, validator includes a recurrence note to escalate to CPTO.

**What this validator does NOT do:**

- Does not validate product UI code — that's `design-gate` (inner-cycle skill, separate scope).
- Does not re-run research — flags "research gap" and suggests the helper, doesn't invoke.
- Does not second-guess CPTO-approved SAFE/RISK calls — flags fake rebellion or inconsistency, not taste disagreement. ("Fake rebellion" = a RISK choice that departs from category norm without earning the departure; e.g., a contrarian color with no brand reason, a swapped hex value dressed as a bold move.)

## 9. Per-Skill Init Briefs (Handoffs)

Short handoff briefs for the follow-up per-skill brainstorms. Each carries scope, I/O, methodology pointers, and the open items the follow-up brainstorm needs to resolve.

### `design-system`

- **Role:** Designer. Foundation: Design System. Posture: consultant (hybrid per Decision 1).
- **Inputs:** `product-brief` (required), `architecture-record` (required), `identity/naming.md` (required; invokes `product-naming` if missing), `design/research/*.md` (optional, offer-once), existing `design/system.md` (for update detection).
- **Outputs:** `design/system.md` (durable, 7-category adaptive), `design/preview/<date>.html` (companion, non-durable), Decisions Log row.
- **Methodology pointers:** consultant posture, propose-whole, one-line "because" per decision, SAFE vs RISK for visual language + voice/tone, two-pass synthesis (taste direction → detailed draft), adaptive scope, offer-once dependency handling, gstack DESIGN.md as structural template for visual-language section.
- **Anticipated support files:** `SKILL.md` (process + checklist), `synthesis-guide.md` (consultant posture + SAFE/RISK framing), `anti-slop.md` (shared with `-review`), `preview-template.html` (adaptive skeletal HTML).
- **Chains:** TBD — candidates: CPTO-led next-foundation pick, `product-backlog`, inner-cycle entry. Optional chain.
- **Open for follow-up brainstorm:**
  - Surface-detection logic (strict read of arch-record vs CPTO confirmation prompt).
  - Preview HTML template component set per surface (GUI vs CLI vs hybrid vs docs-only vs API-only).
  - Whether update-mode with narrow scope can skip the taste-direction pass.
  - Decisions Log exact schema (columns, triggers, what changes warrant a row).
  - What chains to what on approval.

### `design-system-review`

- **Role:** QA / Reviewer. Fork-context validator.
- **Inputs:** `design/system.md`, `design/preview/<latest>.html`, `design/research/*.md`, `product/brief.md`, `architecture/record.md`, `identity/naming.md`.
- **Outputs:** findings report at `design/reviews/<date>.md`.
- **Methodology pointers:** per-category + cross-cutting checklist, impact triage, dual scoring, evidence-per-finding, depth over breadth, shared anti-slop catalog.
- **Anticipated support files:** `SKILL.md` (process + verdict taxonomy), `checklist.md` (per-category + cross-cutting), `anti-slop.md` (shared with `design-system`).
- **Chains:** reports back to orchestrator or to standalone CPTO caller; no forward chain.
- **Open for follow-up brainstorm:**
  - Exact checklist items per category (what makes a principle specific vs generic; what makes a voice register concrete vs vague).
  - First-draft anti-slop catalog content — named patterns with why-it's-slop lines.
  - Preview-alignment check mechanics (HTML parse vs sanity-read).
  - SAFE vs RISK discipline check — how to distinguish real RISK from fake rebellion.
  - Recurrence escalation threshold (3 iterations — confirm or tune).

### `design-research-references`

- **Role:** Designer. Reference layer, self-validated.
- **Inputs:** `product/brief.md` (required), `architecture/record.md` (required, for surface context).
- **Outputs:** `design/research/references.md`.
- **Methodology pointers:** three-layer synthesis (table-stakes / trending / first-principles departures), peer-product cards (5–8 in/near category + 2–3 cross-category), explicit anti-slop flags on peers exhibiting AI-generic patterns, graceful fallback (WebFetch+browse → WebSearch → built-in knowledge), WebFetch only on URLs from search results or user (adversarial-input rule).
- **Anticipated support files:** `SKILL.md` (process + shared header), `method-guide.md` (peer selection criteria, three-layer synthesis how-to, fallback rules).
- **Chains:** none (reports DONE; orchestrator consumes output if called from there).
- **Open for follow-up brainstorm:**
  - Peer selection rubric — pick 5–8 peers that illuminate the category, avoiding "famous products" slop.
  - Trending-layer sourcing — which watering holes, with recency requirements.
  - Cross-category reference count — where signal becomes noise.
  - Evidence format for peer moves (screenshot link, URL, quoted rationale).
  - Self-validation pass criteria.

### `design-research-audience`

- **Role:** Designer. Reference layer, self-validated.
- **Inputs:** `product/brief.md` (required, for JTBD trace), `architecture/record.md` (for surface context).
- **Outputs:** `design/research/audience.md`.
- **Methodology pointers:** audience trace from brief JTBD (no invented personas), tool-and-convention inventory, accessibility needs derived from trace (not WCAG boilerplate), voice/tone register signals from community evidence, proposed WCAG target with rationale.
- **Anticipated support files:** `SKILL.md` (process + shared header), `method-guide.md` (trace technique, community evidence sourcing, WCAG target heuristic).
- **Chains:** none.
- **Open for follow-up brainstorm:**
  - Trace rigor — how to resist inventing persona details not in the brief.
  - Community-evidence sourcing criteria (valuable vs cargo-cult).
  - Handling audience drift (brief says one thing, signals say another — flag vs produce for stated).
  - Accessibility-level justification depth.
  - v1 handling of CPTO-supplied user transcripts (recommendation: defer to v2).

### `design-research-standards`

- **Role:** Designer. Reference layer, self-validated.
- **Inputs:** `product/brief.md` (required), `architecture/record.md` (required, drives surface-to-standards routing), optionally `design/research/audience.md` (for WCAG target input).
- **Outputs:** `design/research/standards.md`.
- **Methodology pointers:** WCAG target with justification; platform HIGs only where applicable; industry regulations only when brief indicates; CLI norms only when CLI surface declared; API error voice only when API surface; docs style refs only when docs surface. Skip-what-doesn't-apply is the discipline.
- **Anticipated support files:** `SKILL.md` (process + shared header), `standards-map.md` (surface-to-standards routing table, citable spec URLs, quick-ref extracts).
- **Chains:** none.
- **Open for follow-up brainstorm:**
  - Exact surface-to-standards routing table.
  - WCAG target heuristic (audience × category × surface → A / AA / AAA).
  - Regulation detection — when to flag vs skip silently.
  - Obsolete/deprecated standards handling.
  - Emergent-standards policy (e.g., WCAG 3 drafts — include or wait).

### Cross-cutting notes for all five follow-ups

- Every per-skill brainstorm produces numbered checklist items and between-phase handoff prompts for its SKILL.md — implicit deliverable, not a per-skill open item.
- All skills write to `${product_home}/` per shared-artifact-layer principle.
- All produce skills follow checklist-driven shape (TaskCreate per step).
- All research helpers self-validate; only `design-system` has a fork validator.
- Anti-slop catalog is shared between `design-system/anti-slop.md` and `design-system-review/anti-slop.md`. First-draft content is itself a deliverable of `design-system-review`'s follow-up brainstorm (since reviewer uses it most actively).
- HTML preview behavior and templates scoped to `design-system`, not the helpers.

## 10. Build Order and Dependencies

Per `docs/ideation/squad-skills-architecture.md`, the bottom-up build order for design-family skills is:

1. `design-research-references`, `design-research-audience`, `design-research-standards` (any order among the three; they don't depend on each other).
2. `design-system` (depends on the helpers being independently invocable so it can invoke them as sub-skills).
3. `design-system-review` (depends on `design-system` producing artifacts to validate).

Each follow-up brainstorm should produce: a design spec (like this one, scoped to that skill), then a writing-plans handoff, then the SKILL.md + support files, then tests at knowledge and triggering tiers, then manual execution test on a playground product.

## 11. What's Out of Scope for This Spec

- Exact SKILL.md checklist item wording.
- First-draft anti-slop catalog content (deferred to `design-system-review` follow-up).
- Preview HTML template implementation (deferred to `design-system` follow-up).
- Methodology deep-dives per helper (each follow-up's work).
- The inner-cycle `design-gate` skill — spec'd separately, not in this family.
- Test tier strategy per skill — follows framework's three-tier pattern, but cost budget decisions pending from `docs/superpowers/specs/2026-04-11-test-cost-model.md`.

## 12. References

- `docs/ideation/squad-process-model.md` — 5 roles, 4 gates, 4 durable foundations; design as a durable concern.
- `docs/ideation/squad-artifacts.md` — 18 artifacts across 5 layers; Design System Doc scope and Reference-layer definition.
- `docs/ideation/squad-skills-architecture.md` — produce/validate pattern, orchestration contract, sub-skill report protocol, build order.
- `docs/superpowers/specs/2026-04-160desing-skill-init.md` — gstack port-notes that fed this brainstorm (input, not output).
- `docs/superpowers/specs/2026-04-11-product-naming-design.md` — neighboring Designer-role foundation skill, shipped pattern.
- `squad/skills/product-brief/` and `squad/skills/architecture-record/` — shipped produce/validate pairs; shape reference for this family.
