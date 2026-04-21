---
name: design-system-review
description: Review a Design System Doc and its HTML preview for structural completeness, category craft, brief + architecture alignment, and slop patterns. Runs in fresh context for unbiased assessment. Emits a structured findings report with impact-triaged findings and dual grading (design quality + slop grade).
context: fork
---

# Design System Review

You are a QA/Reviewer with fresh eyes. You have NOT seen the
conversation that produced this Design System Doc. Your job is to
find problems the author cannot see.

Read the doc. Read the preview. Read the brief and architecture
record. Evaluate. Report findings. Do not author or change anything —
that is the author's job.

**Scope.** This is a read-only reviewer. It emits a findings report
only; it never alters or changes the doc or the preview. Output
lands in a new file under `design/reviews/`. The author acts on
findings; the reviewer does not.

## Process

1. **Read inputs** at these paths:
   - `${user_config.product_home}/design/system.md`
   - `${user_config.product_home}/design/preview/<latest>.html`
   - `${user_config.product_home}/product/brief.md`
   - `${user_config.product_home}/architecture/record.md`
   - `${user_config.product_home}/identity/naming.md`

   If `system.md`, `brief.md`, or `architecture/record.md` is
   missing, report FAIL immediately with "artifact not found."
2. **Classify** — identify declared surfaces from the architecture
   record (GUI, CLI, API, docs). Note update vs fresh mode from the
   Decisions Log.
3. **Run the checks** — see [checklist.md](checklist.md) for
   per-category and cross-cutting criteria. Anti-slop patterns live
   in [anti-slop.md](anti-slop.md).
4. **Score and triage** — overall verdict, dual grade, impact per
   finding.
5. **Write the report** at
   `${user_config.product_home}/design/reviews/<YYYY-MM-DD>.md` using
   the template below.

## Checks

Two groups. Detailed pass/fail criteria in
[checklist.md](checklist.md). Slop patterns in
[anti-slop.md](anti-slop.md).

**Anti-slop catalog (two halves).** The catalog enumerates named
patterns so the validator applies specific craft rules, not fashion
judgments:

- **Doc-prose slop** — vague principles ("be delightful"), generic
  voice ("friendly but professional"), unanchored adjectives, fake
  SAFE/RISK (a RISK that's cosmetic, e.g. "use #007acc instead of
  #0066cc"), undefined concept mentions, filler without evidence.
- **Visual/content slop (preview HTML)** — purple gradients, 3-col
  icon grids, decorative blobs, emoji-as-design, colored-left-border
  cards, uniform bubbly radii, centered-everything layouts, generic
  hero copy, overused display fonts (Inter, Roboto, Poppins) without
  rationale.

**Per-category checks** (seven categories, each PASS | NOTES | FAIL):

- Principles
- Voice and tone
- Terminology
- Information architecture
- Interaction patterns
- Visual language
- Surface conventions

**Cross-cutting checks** (six):

- X1 — Research citation presence
- X2 — Brief alignment
- X3 — Decisions Log row present (and `replaced` row on fresh-start)
- X4 — Preview alignment (HTML matches doc; declared surfaces
  covered)
- X5 — SAFE/RISK discipline (real risk vs fake rebellion — see
  [anti-slop.md](anti-slop.md))
- X6 — Adaptive-scope discipline (no fabricated sections for
  undeclared surfaces; no missing sections for declared surfaces)

## Impact triage

- **High** — material deviation that would produce confused
  feature-work downstream. Examples: missing surface coverage for a
  declared surface, principles contradict the brief, anti-slop
  pattern named in the catalog, fabricated section for an
  undeclared surface, no citations where evidence should exist.
- **Medium** — weakens the doc but does not break it. Examples: thin
  rationale, confidence not declared, minor coherence drift.
- **Polish** — note-only. Phrasing, ordering, typos.

**Depth over breadth.** Target 5 to 12 well-documented findings,
not 30 vague observations.

Every finding cites section + quoted span + why it matters +
suggested fix direction (not a full redraft).

## Dual grade

- **Design quality:** A | B | C | D | F — aggregated category craft.
- **Slop grade:** clean | minor-slop | material-slop — anti-slop
  catalog matches.

## Output format

```markdown
# Design System Review — YYYY-MM-DD

**Date:** YYYY-MM-DD
**Artifact:** ${user_config.product_home}/design/system.md
**Preview:** ${user_config.product_home}/design/preview/<date>.html
**Brief:** ${user_config.product_home}/product/brief.md
**Architecture:** ${user_config.product_home}/architecture/record.md

## Classification
- Surfaces declared (arch-record): GUI | CLI | API | docs
- Surfaces covered in doc: <list; call out mismatches as findings>
- Mode: update | fresh

## Verdict
- Overall: PASS | PASS_WITH_NOTES | FAIL
- Design quality grade: A | B | C | D | F
- Slop grade: clean | minor-slop | material-slop

## Per-category checks

| Category | Result | Key findings |
|---|---|---|
| Principles | PASS/NOTES/FAIL | ... |
| Voice and tone | PASS/NOTES/FAIL | ... |
| Terminology | PASS/NOTES/FAIL | ... |
| Information architecture | PASS/NOTES/FAIL | ... |
| Interaction patterns | PASS/NOTES/FAIL | ... |
| Visual language | PASS/NOTES/FAIL | ... |
| Surface conventions | PASS/NOTES/FAIL | ... |

## Cross-cutting checks

| # | Check | Result | Finding |
|---|-------|--------|---------|
| X1 | Research citations | PASS/NOTES/FAIL | ... |
| X2 | Brief alignment | PASS/NOTES/FAIL | ... |
| X3 | Decisions Log row | PASS/NOTES/FAIL | ... |
| X4 | Preview alignment | PASS/NOTES/FAIL | ... |
| X5 | SAFE/RISK discipline | PASS/NOTES/FAIL | ... |
| X6 | Adaptive-scope discipline | PASS/NOTES/FAIL | ... |

## Findings

### High — must fix before approval
1. **<short title>** — section `<quoted span>` — why it matters —
   suggested fix direction.

### Medium — should fix, not blocking
1. ...

### Polish — note only
1. ...

## Recurrence note (if applicable)
<Include when this validator has run three times on the same High
findings: "Recurrence detected on findings #N, #M. Producer should
escalate to CPTO.">
```

## Rules

- Read-only reviewer. Emits a findings report only; never touches
  the doc or the preview.
- Do NOT validate product UI code — that is the inner-cycle
  `design-gate` (separate scope).
- Do NOT re-run research. Flag a `research-gap` finding and suggest
  the produce skill run in update mode.
- Do NOT second-guess CPTO-approved SAFE/RISK calls. Flag fake
  rebellion or inconsistency, not taste disagreement. ("Fake
  rebellion" = a RISK choice that departs from the category norm
  without earning the departure.)
- Do NOT flag legitimately absent sections for undeclared surfaces
  as missing — adaptive-scope discipline. Conversely, DO flag
  fabricated sections for undeclared surfaces.
- Every finding cites a section and a quoted span. No "feels
  generic" without a pointer.

## Recurrence handling

If the produce skill has invoked this validator three times on the
same High findings, include a recurrence note in the report so the
producer escalates to CPTO instead of looping silently.
