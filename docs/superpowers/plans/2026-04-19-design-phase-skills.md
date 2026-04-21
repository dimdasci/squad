# Design Phase Skills Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the Design System foundation as a two-skill produce/validate pair (`design-system` + `design-system-review`) following the shipped pattern of `product-brief` and `architecture-record`.

**Architecture:** Two squad skills under `squad/skills/`. The produce skill runs seven phases (prereq gate → existing-doc detection → identity check with `product-naming` sub-skill → inline research → draft doc + preview → fork validation → finalize). The validate skill runs a fork-context checklist review and writes a structured findings report. Anti-slop catalog is single-sourced at the validator and referenced by the producer.

**Tech Stack:** Markdown SKILL.md files; bash test harness (`run_claude_knowledge`, stream-json triggering assertions); HTML5 preview template (no build step — plain `<style>` and semantic blocks, conditionally rendered per declared surface). No new external binaries. WebFetch/WebSearch for inline research.

---

## Source of Truth

**Design spec:** `docs/superpowers/specs/2026-04-19-design-phase-skills-design.md`

The spec is authoritative for behavior. Tasks below reference it by section number (e.g., "spec §6 Phase 4") to avoid duplicating content that would rot. Read the spec before starting each task.

**Shape references (shipped skills to mirror):**
- `squad/skills/product-brief/SKILL.md` + `squad/skills/product-brief-review/SKILL.md` — minimal produce/validate pair
- `squad/skills/architecture-record/SKILL.md` + support files (`survey-guide.md`, `record-guide.md`) + `squad/skills/architecture-record-review/SKILL.md` + `review-checklist.md` — produce/validate with support files (closest structural analogue)
- `squad/skills/product-naming/SKILL.md` — sub-skill that `design-system` invokes; has `HARD-GATE` block with standalone-vs-orchestrated branch and Sub-skill Report protocol

**Orchestration contract:** `docs/ideation/squad-skills-architecture.md` §"Skill Design Patterns" subsection 7 (Sub-skill Report protocol, status vocabulary, handling rules).

---

## File Structure

**New files (9):**

| Path | Responsibility |
|---|---|
| `squad/skills/design-system/SKILL.md` | Produce skill: 7-phase checklist, process, phase details, chains to. ≤500 lines. |
| `squad/skills/design-system/synthesis-guide.md` | Consultant posture + SAFE/RISK framing + inline-research discipline. Referenced from SKILL.md Phase 4-5. |
| `squad/skills/design-system/preview-template.html` | Single adaptive HTML skeleton with conditional blocks per declared surface (GUI, CLI, API, docs). |
| `squad/skills/design-system-review/SKILL.md` | Validator: fork context, process, verdict taxonomy, output format. ≤200 lines. |
| `squad/skills/design-system-review/checklist.md` | Per-category + cross-cutting check criteria with pass/fail rules. |
| `squad/skills/design-system-review/anti-slop.md` | Single-source named-pattern catalog (doc-prose + visual-HTML halves), referenced by produce skill. |
| `tests/skill-knowledge/test-design-system.sh` | Knowledge tier: 4-5 questions about produce skill's phases, SAFE/RISK rule, preview, existing-doc pre-check. |
| `tests/skill-knowledge/test-design-system-review.sh` | Knowledge tier: 3-4 questions about verdict taxonomy, triage, anti-slop, fork context. |
| `tests/skill-triggering/prompts/design-system-explicit.txt` | Explicit invocation prompt. |
| `tests/skill-triggering/prompts/design-system-implicit.txt` | Implicit intent prompt. |
| `tests/skill-triggering/prompts/design-system-negative.txt` | Review-style prompt that must route to `design-system-review`. |

(Prompt files are grouped with the 9 above — counts as three files. Total new files: 11.)

**Modified files (2):**

| Path | Change |
|---|---|
| `tests/skill-triggering/run-all.sh` | Append 3 entries to `TESTS` array (design-system explicit, design-system implicit, design-system-review negative). |
| `docs/ideation/squad-skills-architecture.md` | Move `design-system` and `design-system-review` rows from "Planned" to "Implemented"; strike their rows from the planned table. Remove the three `design-research-*` rows (superseded by spec Decision 4 — no helper skills). Update `## Skill Inventory → ### Implemented` heading count. |

**Out of scope:** automated execution-tier tests. Per spec §10, defer pending `docs/superpowers/specs/2026-04-11-test-cost-model.md`. Manual execution test on skill-playground is the acceptance artifact.

---

## Task Decomposition

Twelve tasks in build order. Task 1 scaffolds. Tasks 2-7 build the producer + its support files. Tasks 8-10 build the validator + its support files (and update the producer's anti-slop reference to point at the real file). Tasks 11-12 wire tests and inventory. Task 13 runs the knowledge + triggering suite. Task 14 is the manual execution test on skill-playground.

### Task 1: Scaffold directories

**Files:**
- Create: `squad/skills/design-system/`
- Create: `squad/skills/design-system-review/`

- [ ] **Step 1: Create the two skill directories**

Run:
```bash
mkdir -p squad/skills/design-system squad/skills/design-system-review
```

Expected: directories exist, empty.

- [ ] **Step 2: Verify with ls**

Run:
```bash
ls -la squad/skills/design-system/ squad/skills/design-system-review/
```

Expected: both dirs present, no files yet.

- [ ] **Step 3: Commit scaffolding**

```bash
git add squad/skills/design-system squad/skills/design-system-review
git commit -m "chore(design-system): scaffold skill directories"
```

Note: empty dirs don't stage — this commit may be a no-op. That's fine; the next task creates files.

---

### Task 2: Write knowledge test for `design-system` (red)

**Files:**
- Create: `tests/skill-knowledge/test-design-system.sh`

The skill's knowledge test comes before the SKILL.md so we see it fail, then build the skill until it passes. Mirror the shape of `tests/skill-knowledge/test-architecture-record.sh`.

- [ ] **Step 1: Write the failing test**

Create `tests/skill-knowledge/test-design-system.sh`:

```bash
#!/usr/bin/env bash
# Test: design-system skill knowledge
# Verifies that Claude loaded the skill and understands its process
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Test: design-system skill knowledge ==="
echo ""

# Test 1: Knows the seven phases and prerequisite gate
echo "Test 1: Seven phases and hard gate..."
output=$(run_claude_knowledge "In the design-system skill, what are the seven phases and which phase is a hard prerequisite gate? List the phases briefly." 60)
assert_contains "$output" "prereq\|prerequisite\|Phase 1\|hard gate\|HARD-GATE" "Mentions prerequisite gate" || exit 1
assert_contains "$output" "existing\|pre-check\|update.*fresh\|archive" "Mentions existing-doc pre-check" || exit 1
assert_contains "$output" "identity\|naming\|product-naming" "Mentions product identity / naming check" || exit 1
assert_contains "$output" "research\|WebFetch\|WebSearch" "Mentions inline research" || exit 1
assert_contains "$output" "draft\|preview\|HTML" "Mentions draft + preview" || exit 1
assert_contains "$output" "validation\|review\|design-system-review" "Mentions fork validation" || exit 1
assert_contains "$output" "finalize\|approval\|Decisions Log" "Mentions finalize" || exit 1
echo ""

# Test 2: Knows SAFE/RISK applies only to visual language + voice/tone
echo "Test 2: SAFE/RISK scope..."
output=$(run_claude_knowledge "In the design-system skill, which categories use SAFE vs RISK framing, and which use plain one-line 'because' rationale instead?" 60)
assert_contains "$output" "visual language\|visual\|typography\|palette" "Mentions visual language for SAFE/RISK" || exit 1
assert_contains "$output" "voice\|tone" "Mentions voice/tone for SAFE/RISK" || exit 1
assert_contains "$output" "because\|rationale\|one.line\|plain" "Mentions plain one-line rationale for others" || exit 1
echo ""

# Test 3: Knows adaptive surface scope from architecture-record
echo "Test 3: Adaptive surface scope..."
output=$(run_claude_knowledge "In the design-system skill, how are surfaces (GUI, CLI, API, docs) determined, and what happens to categories for surfaces a product doesn't declare?" 60)
assert_contains "$output" "architecture\|architecture-record\|arch.record\|declared" "Reads declared surfaces from architecture-record" || exit 1
assert_contains "$output" "skip\|omit\|not included\|adaptive\|don.t appear" "Skips/omits categories for undeclared surfaces" || exit 1
assert_not_contains "$output" "N/A\|not applicable placeholder" "No N/A placeholder sections" || exit 1
echo ""

# Test 4: Knows existing-doc pre-check modes
echo "Test 4: Existing-doc pre-check..."
output=$(run_claude_knowledge "In the design-system skill, if a design/system.md already exists, what does the skill do and what options does it offer?" 60)
assert_contains "$output" "update\|(u)" "Offers update mode" || exit 1
assert_contains "$output" "fresh\|(f)" "Offers fresh start mode" || exit 1
assert_contains "$output" "cancel\|(c)\|chat" "Offers cancel / chat escape" || exit 1
assert_contains "$output" "archive\|\.bak\|replaced" "Archives old doc on fresh start" || exit 1
echo ""

# Test 5: Knows preview is a companion HTML artifact
echo "Test 5: HTML preview..."
output=$(run_claude_knowledge "In the design-system skill, what is the HTML preview, where is it written, and what does it contain?" 60)
assert_contains "$output" "preview\|HTML\|html" "Mentions HTML preview" || exit 1
assert_contains "$output" "design/preview\|preview/.*\.html\|<date>\.html" "Mentions preview path" || exit 1
assert_contains "$output" "swatch\|type\|terminal\|component\|error\|sample" "Lists preview content types" || exit 1
echo ""

echo "=== All design-system knowledge tests passed ==="
```

- [ ] **Step 2: Run the test; verify it fails**

```bash
chmod +x tests/skill-knowledge/test-design-system.sh
./tests/skill-knowledge/test-design-system.sh
```

Expected: FAIL — the skill does not exist yet, so Claude cannot know about its phases. Several `[FAIL]` lines.

- [ ] **Step 3: Commit**

```bash
git add tests/skill-knowledge/test-design-system.sh
git commit -m "test(design-system): add knowledge test (red)"
```

---

### Task 3: Write `design-system/SKILL.md`

**Files:**
- Create: `squad/skills/design-system/SKILL.md`

This is the main produce skill. Target ≤500 lines. Spec §6 describes the seven phases verbatim.

- [ ] **Step 1: Write frontmatter + intro + HARD-GATE**

Frontmatter MUST be exact (copy verbatim):

```yaml
---
name: design-system
description: Create or update the Design System Doc — the durable design foundation covering principles, voice and tone, terminology, information architecture, interaction patterns, visual language, and surface conventions. Use after product-brief and architecture-record are approved, on rebrands, when adding new surfaces, or when major repositioning requires a design reset.
allowed-tools: WebSearch WebFetch
---
```

After the frontmatter, write the intro paragraph and HARD-GATE block. Intro names the role (Designer), the artifact (Design System Doc at `${user_config.product_home}/design/system.md`), and that it is **durable** — outlives sprints, branches, sessions. HARD-GATE blocks execution when `${user_config.product_home}/product/brief.md` is missing or not `Status: approved`, or when `${user_config.product_home}/architecture/record.md` is missing. Tell the user to run `squad:product-brief` or `squad:architecture-record` first. Never proceed with synthetic values. Spec §6 Phase 1 is the reference.

- [ ] **Step 2: Write the Checklist section**

Exact 13 items in this order (each one maps to a task the agent creates via TaskCreate):

1. **Read existing context** — check approved brief, existing architecture record, existing design system doc
2. **Existing-doc pre-check** — if `system.md` exists, prompt update/fresh/cancel
3. **Product Identity check** — read `identity/naming.md`; invoke `product-naming` as sub-skill if missing
4. **Inline research** — peer-product lookups, standards, audience trace for declared surfaces/categories
5. **Draft Design System Doc** — write `design/system.md` covering 7 categories, adaptive scope
6. **Draft HTML preview** — write `design/preview/<date>.html` from single adaptive template
7. **Present to CPTO for inline iteration** — iterate conversationally until direction is accepted
8. **Fork-context validation** — invoke `squad:design-system-review` (context: fork)
9. **Address findings** — High must fix; Medium fix or rationale; Polish log
10. **Regenerate preview from final doc** — preview matches doc, not in-progress draft
11. **Append Decisions Log row** — scope, summary, rationale, trigger
12. **Request CPTO approval** — flip `Status: approved` on yes
13. **Declare chains to** — four foundations check; inner cycle gated on both Design System + Architecture

Match the layout style of `squad/skills/architecture-record/SKILL.md` lines 24-41.

- [ ] **Step 3: Write the Process graphviz block**

Use `dot` digraph matching the style of `architecture-record/SKILL.md` lines 44-81. Nodes for the 13 checklist items, with the inline CPTO-iteration loop at step 7 and the FAIL edge from step 8 back to step 5. Prereq and existing-doc-precheck are both gates at the top; cluster them visually per spec §6.

- [ ] **Step 4: Write Phase 1 — Prerequisite check**

One numbered heading `### 1. Read existing context` (matches architecture-record's "Step Details" layout). Content: read `${user_config.product_home}/product/brief.md` (required, `Status: approved`), `${user_config.product_home}/architecture/record.md` (required, declares surfaces). If either missing or not approved, stop with instruction for user to run the prereq skill first. Also read existing `${user_config.product_home}/design/system.md` if present (for pre-check in next step). If `${user_config.product_home}` not set, ask user to configure it (use same phrasing as architecture-record line 97-99).

- [ ] **Step 5: Write Phase 2 — Existing-doc pre-check**

`### 2. Existing-doc pre-check`. Content verbatim from spec §6 Phase 2: summarize (last-modified date, categories covered, last Decisions Log entry); prompt CPTO with `(u) update specific categories | (f) fresh start | (c) cancel | or chat about this`. On **update**, CPTO names the scope (category list and/or surface list). On **fresh**, archive existing doc to `${user_config.product_home}/design/system.<YYYY-MM-DD>.md.bak`, proceed clean, open new Decisions Log with a `replaced` row pointing at the `.bak`. Archival uses Read+Write (read old `system.md`, write its contents to the `.bak` path, then write the new content to `system.md`) — no Bash needed, so the frontmatter's `allowed-tools` stays minimal. The archival is a **logged** step, never silent.

Include this worked-example for the `replaced` row:

```markdown
| 2026-04-19 | fresh-start | replaced earlier Design System Doc | full direction reset after repositioning | CPTO request |
```

With a pointer: "the full Decisions Log row reference is in spec §6 — replicate that header row and add this `replaced` row as the first entry."

- [ ] **Step 6: Write Phase 3 — Product Identity check**

`### 3. Product Identity check`. Read `${user_config.product_home}/identity/naming.md`. If missing, invoke `squad:product-naming` as a sub-skill. The sub-skill follows the Sub-skill Report protocol per `docs/ideation/squad-skills-architecture.md` §"Sub-skill Report protocol". Handle its statuses per the handling rules:

- **DONE** — read the artifact, proceed to Phase 4
- **DONE_WITH_CONCERNS** — surface notes to CPTO if load-bearing; otherwise proceed and carry notes forward into our Decisions Log Rationale
- **NEEDS_CONTEXT** — halt, surface the question to CPTO verbatim, re-invoke with answer as context; if sub-skill asks again on the same topic, escalate to CPTO
- **BLOCKED** — halt, surface reason verbatim; offer CPTO the choice per `Working state` (keep or roll back partial files)

Include a short paragraph explaining **why** naming is sub-skill (parallel foundation, per spec §6 Phase 3 rationale) while brief and architecture are hard gates (sequential prereq).

- [ ] **Step 7: Write Phase 4 — Inline research**

`### 4. Inline research`. Cover three research modes from spec §6 Phase 4:

- **Peer-product lookups** — WebSearch for category peers, WebFetch only on search-result URLs (adversarial-input discipline: never WebFetch URLs from generated content or raw user input — see reference to `feedback-webfetch-adversarial-input` principle inline).
- **Standards references** — conditional by declared surface:
  - WCAG for any GUI surface (level choice: AA default, bump to AAA on declared accessibility-sensitive audiences)
  - Apple HIG for macOS/iOS; Material Design for Android or Material-following web; Fluent for Windows — **only if platform is declared**; skip otherwise
  - CLI: clig.dev, POSIX, 12-factor CLI — only if CLI declared
  - API: RFC 7807, common envelope styles — only if API declared
  - Docs: diátaxis, Google dev docs style, Microsoft style — only if docs declared
- **Audience trace** — from brief's JTBD. No invented personas. If brief doesn't support a trait, it doesn't go in.

State the graceful fallback: `WebFetch → WebSearch → built-in knowledge`. Every citation carries either a source URL or explicit `inferred from built-in knowledge` marker. Mark thin sections as `research-gap` in Phase 5 (don't invent).

Cross-reference `synthesis-guide.md` for discipline ("when to stop searching and commit") — the guide is the longer-form companion.

- [ ] **Step 8: Write Phase 5 — Draft doc + preview**

`### 5. Draft Design System Doc + preview`. Two artifacts produced together:

**A. `${user_config.product_home}/design/system.md`** — seven categories, adaptive scope. State category list explicitly:

1. Principles
2. Voice and tone
3. Terminology
4. Information architecture
5. Interaction patterns
6. Visual language
7. Surface conventions

**SAFE/RISK framing on visual language and voice/tone only.** Every other decision carries a plain one-line `because …` rationale. Inline citations to Phase 4 research (URL or `inferred`). `research-gap` markers on thin sections.

Reference `synthesis-guide.md` for the consultant posture and SAFE/RISK framing specifics. Reference `../design-system-review/anti-slop.md` for named patterns to avoid during drafting (two halves: doc-prose slop + visual/content slop).

**B. `${user_config.product_home}/design/preview/<YYYY-MM-DD>.html`** — single adaptive template. Use `preview-template.html` in this skill's directory as the starting skeleton. Conditional blocks per declared surface:

- GUI declared → include palette swatches, type specimens, component samples
- CLI declared → include faux-terminal rendering with color tokens rendered as `<span>` color chips
- API declared → include error-voice snippets rendered as formatted JSON envelopes
- Docs declared → include style samples (headings, body, callout, code)

Surfaces NOT declared → omit the block entirely. Never render an empty "N/A" section.

Present both artifacts to CPTO. Iterate conversationally on anything — a principle, a SAFE/RISK call, a swatch, voice register, a component sample — until CPTO accepts the direction.

Include a self-check before invoking the validator: catch thin sections (`research-gap` markers on load-bearing categories), missing citations, fabricated sections for undeclared surfaces. Producer fixes these before handing off to review.

- [ ] **Step 9: Write Phase 6 — Fork validation + Phase 7 — Finalize**

`### 6. Fork-context validation`. Invoke `squad:design-system-review` (context: fork). Wait for findings report at `${user_config.product_home}/design/reviews/<date>.md` with verdict (PASS | PASS_WITH_NOTES | FAIL), per-category statuses, impact-triaged findings (High | Medium | Polish), dual grade (design quality A-F + slop grade clean | minor-slop | material-slop).

Handling:
- **PASS** — proceed to Phase 7
- **PASS_WITH_NOTES** — read suggestions, address what you agree with, proceed (non-blocking)
- **FAIL** — address all High findings first; re-validate. Medium: fix or rationale. Polish: log in Decisions Log only.

Recurrence: if the validator FAILs on the same High findings three times in a row, escalate to CPTO with a recurrence note (do not silently keep looping).

`### 7. Finalize`. On CPTO approval:
- Write final `design/system.md` with `Status: approved`, date, approver
- Append Decisions Log row (schema below)
- Regenerate `design/preview/<YYYY-MM-DD>.html` from the **final** doc so preview matches doc
- Record review report path in the doc footer

Decisions Log row schema (show this table verbatim in the skill):

```markdown
| Date | Scope | Summary | Rationale | Trigger |
|---|---|---|---|---|
| 2026-04-19 | initial | First Design System Doc created | — | product-brief approved |
```

- [ ] **Step 10: Write escalation rules + idempotency + Chains To + Common Rationalizations**

Escalation and failure modes (match spec §6 bottom):
- Prereq missing → stop, instruct CPTO to run prereq first
- Sub-skill BLOCKED → surface reason verbatim; never fall through silently to built-in knowledge
- Validator FAIL after 3 iterations on same High findings → escalate to CPTO
- CPTO requests changes 5+ times → ask whether direction is still right or research needs revisit

Idempotency: re-running `/design-system` goes through Phase 2 (existing-doc pre-check) every time; no silent overwrites. Update mode can scope to category/surface subset. Preview regeneration can be skipped on narrow updates that don't touch visual language.

`## Chains To` section: If Architecture Record is also approved and Product Brief + Product Identity are approved, four foundations complete — next step is outer cycle (`squad:product-backlog`, planned). If Architecture Record not yet approved, declare `squad:architecture-record` as the equal-rank foundation that also gates the inner cycle.

`## Common Rationalizations` table (match the style of architecture-record lines 330-337). Examples:

| Excuse | Reality |
|---|---|
| "The brief + architecture are enough, we can skip design system" | The inner-cycle Design Gate has nothing to validate against. UI work drifts without a standard. |
| "I'll invent personas based on the category" | JTBD trace from the brief is the source. Invented traits corrupt voice decisions downstream. |
| "Let me add a section for surfaces we might have someday" | Fabricated sections for undeclared surfaces are flagged as slop. Adaptive scope exists for a reason. |
| "SAFE/RISK on every decision is more rigorous" | It dilutes signal. Rationale framework earns its keep only where category expectations are real and departure creates signal. |
| "Preview can come later, after the doc is approved" | Visual decisions are hard to judge from prose. The preview is the taste signal. |

- [ ] **Step 11: Update producer's anti-slop reference placeholder**

Inside Phase 5, use a relative-path reference to `../design-system-review/anti-slop.md`. If Claude Code rejects cross-skill relative paths at runtime during manual testing, Task 13 will fall back to `squad/skills/_shared/anti-slop.md` per spec §8 "Cross-cutting notes". Leave a `<!-- note -->` HTML comment in the SKILL.md adjacent to the reference: `<!-- if cross-skill relative path fails at plugin-load, move anti-slop.md to _shared/ and update this reference -->`.

- [ ] **Step 12: Run the knowledge test; verify it now passes**

```bash
./tests/skill-knowledge/test-design-system.sh
```

Expected: all five tests PASS.

- [ ] **Step 13: Check line count and commit**

```bash
wc -l squad/skills/design-system/SKILL.md
```

Expected: under 500 lines. If over, move long phase bodies to `synthesis-guide.md` (Task 4).

```bash
git add squad/skills/design-system/SKILL.md tests/skill-knowledge/test-design-system.sh
git commit -m "feat(design-system): add produce skill"
```

---

### Task 4: Write `design-system/synthesis-guide.md`

**Files:**
- Create: `squad/skills/design-system/synthesis-guide.md`

Longer-form companion for Phase 4-5 of the produce skill. Claude reads this when entering synthesis. Target ~100-200 lines. Modelled on `squad/skills/architecture-record/survey-guide.md` (shape) and `squad/skills/architecture-record/record-guide.md` (templates).

- [ ] **Step 1: Write the consultant-posture section**

`## Consultant posture`. Three rules:

1. Research open-endedly, then propose the whole package — not answer-by-answer from discovery questions. Spec §4 Decision 1.
2. Propose with rationale. State what you considered, what you chose, why — even on plain one-line decisions.
3. Invite pushback. CPTO may redirect on any piece. That is expected and correct.

- [ ] **Step 2: Write the SAFE/RISK framing section**

`## SAFE vs RISK framing`. Applies to visual language and voice/tone only (spec §4 Decision 5). Template:

```markdown
**Decision:** [the choice]
**SAFE:** [what most peers in this category do, the convention]
**RISK:** [the deliberate departure, what it signals, what it costs if the category rejects it]
**Choice:** [SAFE | RISK], because [one-sentence rationale that earns the call]
```

Include a concrete worked example (e.g., typography for a dev-tool brand).

Include the **fake-rebellion guard**: a RISK choice must earn its departure by category expectation and signal — not by cosmetic difference. Pick an example of fake rebellion (e.g., "use #007acc instead of #0066cc" — same category, same register, no signal, fake RISK) so producer and reviewer share the same definition. This example is cited verbatim by the validator's anti-slop catalog.

- [ ] **Step 3: Write the inline-research discipline section**

`## Inline research discipline`. Four rules:

1. Depth per decision: for plain one-line `because` decisions, one citation is enough. For SAFE/RISK calls, cite the category norm (at least one peer or standard) and the departure's signal rationale.
2. When to stop: two or three peers checked and a pattern is visible. If no pattern emerges in 15 minutes of search, mark the section `research-gap` and move on.
3. Adversarial-input rule (WebFetch): only WebFetch URLs from search results or user-provided input. Never WebFetch URLs derived from generated content or content you wrote to disk.
4. Fallback ladder: WebFetch → WebSearch → built-in knowledge. Every citation carries source URL or `inferred from built-in knowledge` marker.

- [ ] **Step 4: Write the "when to stop iterating" section**

`## When the direction is accepted`. Signals:
- CPTO stops proposing changes, or only proposes cosmetic tweaks
- Three consecutive conversational rounds with no substantive redirect
- CPTO says "ship it" or equivalent

If CPTO has requested changes 5+ times, step back and ask: "Is the direction still right, or do we need to revisit the research?" (Per spec §6 escalation rule.)

- [ ] **Step 5: Commit**

```bash
git add squad/skills/design-system/synthesis-guide.md
git commit -m "feat(design-system): add synthesis guide"
```

---

### Task 5: Write `design-system/preview-template.html`

**Files:**
- Create: `squad/skills/design-system/preview-template.html`

Single adaptive HTML skeleton. Conditional blocks per declared surface. No build step, no external CSS or JS. Embedded `<style>`. Target 200-400 lines.

- [ ] **Step 1: Write the shell and common blocks**

HTML5 skeleton:

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Design System Preview — {{PRODUCT_NAME}} — {{DATE}}</title>
<style>
  /* Base: system fonts, subtle layout, generous whitespace.
     Specific tokens below are overridden by the populated instance. */
  body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; margin: 0; padding: 2rem; color: #111; }
  section { margin-bottom: 3rem; border-top: 1px solid #eaeaea; padding-top: 2rem; }
  h1 { font-size: 2rem; margin: 0 0 1rem; }
  h2 { font-size: 1.25rem; margin: 0 0 0.75rem; }
  .swatch { display: inline-block; width: 80px; height: 80px; margin-right: 0.5rem; vertical-align: top; }
  .swatch-label { font-size: 0.8rem; color: #666; display: block; margin-top: 4px; }
  .terminal { background: #1e1e1e; color: #d4d4d4; font-family: "SF Mono", Consolas, monospace; padding: 1rem; border-radius: 4px; font-size: 0.9rem; line-height: 1.4; white-space: pre; }
  .terminal .ok { color: #7ec699; }
  .terminal .err { color: #f28b82; }
  .terminal .warn { color: #f2c677; }
  .terminal .dim { color: #666; }
  pre.api { background: #f6f8fa; padding: 1rem; border-radius: 4px; overflow-x: auto; }
  .component-sample { border: 1px solid #eaeaea; padding: 1rem; border-radius: 4px; margin-bottom: 1rem; }
  .docs-sample { max-width: 720px; line-height: 1.6; }
</style>
</head>
<body>
<header>
  <h1>{{PRODUCT_NAME}} — Design System Preview</h1>
  <p>Generated {{DATE}} · Surfaces: {{DECLARED_SURFACES}}</p>
</header>
<!-- GUI block: include only if GUI surface declared -->
<!-- CLI block: include only if CLI surface declared -->
<!-- API block: include only if API surface declared -->
<!-- Docs block: include only if docs surface declared -->
<footer>
  <p>Source: design/system.md · See decisions log for changes.</p>
</footer>
</body>
</html>
```

- [ ] **Step 2: Write the GUI conditional block**

Between the GUI comment markers, add:

```html
<section id="gui">
  <h2>Visual language — GUI</h2>
  <h3>Palette</h3>
  <div>
    <!-- One .swatch per token; fill-in during generation -->
    <span class="swatch" style="background:{{TOKEN_HEX}}"></span><span class="swatch-label">{{TOKEN_NAME}} · {{TOKEN_HEX}}</span>
  </div>
  <h3>Type specimens</h3>
  <div>
    <p style="font-family:{{DISPLAY_FONT}}; font-size:2rem;">Aa — Display 32 · {{DISPLAY_FONT}}</p>
    <p style="font-family:{{BODY_FONT}}; font-size:1rem;">Aa — Body 16 · {{BODY_FONT}}. The quick brown fox jumps over the lazy dog.</p>
  </div>
  <h3>Component samples</h3>
  <div class="component-sample">
    <!-- Button, input, card samples live here; fill during generation -->
  </div>
</section>
```

- [ ] **Step 3: Write the CLI conditional block**

```html
<section id="cli">
  <h2>Visual language — CLI</h2>
  <h3>Terminal palette</h3>
  <div class="terminal">$ {{PRODUCT_SLUG}} status
<span class="ok">✓</span> ready
<span class="warn">!</span> 2 pending tasks
<span class="err">✗</span> last run failed <span class="dim">(2h ago)</span></div>
  <h3>Output modes (human / json / llm)</h3>
  <!-- Three <pre> blocks showing the same command's three output modes -->
</section>
```

- [ ] **Step 4: Write the API conditional block**

```html
<section id="api">
  <h2>Voice — API</h2>
  <h3>Error envelope sample</h3>
  <pre class="api">{
  "error": {
    "code": "invalid_argument",
    "message": "{{ERROR_VOICE_SAMPLE}}",
    "request_id": "req_..."
  }
}</pre>
  <h3>Versioning voice sample</h3>
  <!-- Release notes / deprecation notice tone sample -->
</section>
```

- [ ] **Step 5: Write the docs conditional block**

```html
<section id="docs">
  <h2>Voice — Docs</h2>
  <div class="docs-sample">
    <h1>{{DOC_H1_SAMPLE}}</h1>
    <p>{{DOC_BODY_SAMPLE}}</p>
    <blockquote><strong>Note</strong> — {{DOC_CALLOUT_SAMPLE}}</blockquote>
    <pre><code>{{DOC_CODE_SAMPLE}}</code></pre>
  </div>
</section>
```

- [ ] **Step 6: Sanity-check the HTML**

Open the template in a browser to confirm it renders cleanly (all blocks visible, no CSS breakage). The template is a **skeleton** — placeholders are intentional. The populated instance generated by the skill will have all `{{…}}` substitutions filled.

- [ ] **Step 7: Commit**

```bash
git add squad/skills/design-system/preview-template.html
git commit -m "feat(design-system): add adaptive preview template"
```

---

### Task 6: Write knowledge test for `design-system-review` (red)

**Files:**
- Create: `tests/skill-knowledge/test-design-system-review.sh`

- [ ] **Step 1: Write the failing test**

```bash
#!/usr/bin/env bash
# Test: design-system-review skill knowledge
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Test: design-system-review skill knowledge ==="
echo ""

# Test 1: Verdict taxonomy and dual grading
echo "Test 1: Verdict + dual grade..."
output=$(run_claude_knowledge "In the design-system-review skill, what verdict values does it emit, and what is the dual grading scheme?" 60)
assert_contains "$output" "PASS\|pass" "Mentions PASS" || exit 1
assert_contains "$output" "PASS_WITH_NOTES\|pass with notes" "Mentions PASS_WITH_NOTES" || exit 1
assert_contains "$output" "FAIL\|fail" "Mentions FAIL" || exit 1
assert_contains "$output" "design quality\|A\|B\|C" "Mentions design-quality grade" || exit 1
assert_contains "$output" "slop\|clean\|minor-slop\|material-slop" "Mentions slop grade" || exit 1
echo ""

# Test 2: Impact triage
echo "Test 2: Impact triage..."
output=$(run_claude_knowledge "In the design-system-review skill, how are findings triaged, and what are the impact categories?" 60)
assert_contains "$output" "High\|high" "Mentions High triage" || exit 1
assert_contains "$output" "Medium\|medium" "Mentions Medium triage" || exit 1
assert_contains "$output" "Polish\|polish" "Mentions Polish triage" || exit 1
echo ""

# Test 3: Anti-slop catalog
echo "Test 3: Anti-slop catalog..."
output=$(run_claude_knowledge "In the design-system-review skill, what is the anti-slop catalog, and what two halves does it cover?" 60)
assert_contains "$output" "doc.prose\|principle\|voice\|vague" "Mentions doc-prose slop half" || exit 1
assert_contains "$output" "visual\|HTML\|preview\|gradient\|emoji" "Mentions visual/content slop half" || exit 1
echo ""

# Test 4: Fork context + does not rewrite
echo "Test 4: Fork context + no rewrite..."
output=$(run_claude_knowledge "Does the design-system-review skill rewrite the Design System Doc, and what context does it run in?" 60)
assert_contains "$output" "fork\|fresh\|isolated\|separate" "Mentions fork/fresh context" || exit 1
assert_not_contains "$output" "rewrite\|rewrites\|edits the doc\|modifies the doc" "Does NOT rewrite" || exit 1
echo ""

# Test 5: Adaptive-scope discipline
echo "Test 5: Adaptive-scope discipline..."
output=$(run_claude_knowledge "In the design-system-review skill, how does it handle sections for surfaces that are or aren't declared in the architecture record?" 60)
assert_contains "$output" "fabricated\|invented\|not declared\|undeclared" "Flags fabricated sections for undeclared surfaces" || exit 1
assert_contains "$output" "legitimately absent\|not required\|skip\|don.t flag" "Does not flag legitimately absent sections" || exit 1
echo ""

echo "=== All design-system-review knowledge tests passed ==="
```

- [ ] **Step 2: Run; verify fail**

```bash
chmod +x tests/skill-knowledge/test-design-system-review.sh
./tests/skill-knowledge/test-design-system-review.sh
```

Expected: FAIL.

- [ ] **Step 3: Commit**

```bash
git add tests/skill-knowledge/test-design-system-review.sh
git commit -m "test(design-system-review): add knowledge test (red)"
```

---

### Task 7: Write `design-system-review/SKILL.md`

**Files:**
- Create: `squad/skills/design-system-review/SKILL.md`

Target ≤200 lines. Model on `squad/skills/architecture-record-review/SKILL.md` (that file is 123 lines — use as shape reference).

- [ ] **Step 1: Write frontmatter**

```yaml
---
name: design-system-review
description: Review a Design System Doc and its HTML preview for structural completeness, category craft, brief + architecture alignment, and slop patterns. Runs in fresh context for unbiased assessment. Emits a structured findings report with impact-triaged findings and dual grading (design quality + slop grade).
context: fork
---
```

Note: no `allowed-tools` needed — Read/Write/Bash defaults are enough (no WebFetch, no WebSearch).

- [ ] **Step 2: Write intro + Process section**

Intro: "You are a QA/Reviewer with fresh eyes. You have NOT seen the conversation that produced this Design System Doc. Your job is to find problems the author cannot see. Read the doc. Read the preview. Read the brief and architecture record. Evaluate. Report findings. Do not fix anything — that is the author's job."

`## Process`:

1. **Read inputs** at these paths (list all five): `${user_config.product_home}/design/system.md`, `${user_config.product_home}/design/preview/<latest>.html`, `${user_config.product_home}/product/brief.md`, `${user_config.product_home}/architecture/record.md`, `${user_config.product_home}/identity/naming.md`. If any of brief, architecture, or system.md is missing, report FAIL with "artifact not found."
2. **Classify** — identify declared surfaces from architecture record; note update vs fresh mode from Decisions Log.
3. **Run the checks** — see `checklist.md` for per-category + cross-cutting criteria.
4. **Score + triage** — verdict, dual grade, impact per finding.
5. **Write report** at `${user_config.product_home}/design/reviews/<YYYY-MM-DD>.md`.

- [ ] **Step 3: Write the Checks section pointing to checklist.md**

`## Checks` section summarizes two groups:

**Per-category checks** (seven categories, each PASS | NOTES | FAIL):
- Principles
- Voice and tone
- Terminology
- Information architecture
- Interaction patterns
- Visual language
- Surface conventions

**Cross-cutting checks**:
- Research citation presence
- Brief alignment
- Decisions Log row present (and `replaced` row on fresh-start)
- Preview alignment (HTML matches doc, declared surfaces covered)
- SAFE/RISK discipline (fake rebellion check — see `anti-slop.md`)
- Adaptive-scope discipline (no fabricated sections for undeclared surfaces; no missing sections for declared surfaces)

Reference `[checklist.md](checklist.md)` for detailed pass/fail criteria per check.

- [ ] **Step 4: Write Triage + Output sections**

`## Impact triage`:
- **High** — material deviation that would produce confused feature-work downstream (missing surface coverage for a declared surface, principles contradict brief, anti-slop pattern named in catalog, fabricated section for undeclared surface, no citations where evidence should exist)
- **Medium** — weakens the doc but doesn't break it (thin rationale, confidence not declared, minor coherence drift)
- **Polish** — note-only (phrasing, ordering, typos)

Depth over breadth: target 5-12 well-documented findings, not 30 vague observations.

Every finding cites section + quoted span + why it matters + suggested fix direction (not a rewrite).

`## Dual grade`:
- **Design quality:** A | B | C | D | F (category craft aggregated)
- **Slop grade:** clean | minor-slop | material-slop (anti-slop catalog matches)

`## Output format`. Embed the full markdown template (match the style in `architecture-record-review/SKILL.md` lines 72-104). Template includes the Classification block (declared vs covered surfaces, update/fresh mode), Verdict block, Per-category table, Cross-cutting table, Findings sections (High / Medium / Polish).

- [ ] **Step 5: Write Rules section**

`## Rules`:
- Do NOT rewrite the doc or preview. Report findings only.
- Do NOT validate product UI code — that's the inner-cycle `design-gate` (separate scope).
- Do NOT re-run research. Flag `research-gap` and suggest the produce skill run update mode.
- Do NOT second-guess CPTO-approved SAFE/RISK calls. Flag fake rebellion or inconsistency, not taste disagreement.
- Do NOT flag legitimately absent sections for undeclared surfaces as missing. Adaptive-scope discipline. Conversely, DO flag fabricated sections for undeclared surfaces.
- Every finding cites a section and a quoted span. No "feels generic" without a pointer.

`## Recurrence handling`: if the produce skill re-runs this validator three times on the same High findings, include a recurrence note in the report so the producer escalates to CPTO.

- [ ] **Step 6: Run knowledge test; verify pass**

```bash
./tests/skill-knowledge/test-design-system-review.sh
```

Expected: all five tests PASS.

- [ ] **Step 7: Commit**

```bash
git add squad/skills/design-system-review/SKILL.md
git commit -m "feat(design-system-review): add validator skill"
```

---

### Task 8: Write `design-system-review/checklist.md`

**Files:**
- Create: `squad/skills/design-system-review/checklist.md`

Detailed pass/fail criteria. Model on `squad/skills/architecture-record-review/review-checklist.md` (184 lines).

- [ ] **Step 1: Write per-category check criteria**

For each of the seven categories (Principles, Voice and tone, Terminology, IA, Interaction patterns, Visual language, Surface conventions), write 2-4 numbered checks with:
- **Check ID** (e.g., P1, V1, T1 — prefixed letter by category)
- **How to check** (concrete procedure the reviewer follows, reading the doc)
- **PASS if / FAIL if** (pass/fail criteria)

Example for Principles:

```markdown
### P1: Principles are specific, not generic

**How to check:** Read each principle. A generic principle could apply to any product ("be delightful", "be fast"). A specific principle names the trade-off or what it rules out.
**PASS if:** Each principle is specific enough to guide a concrete decision.
**FAIL if:** Any principle is generic enough to fit on any product. Cite the specific principle.

### P2: Principles derive from the brief

**How to check:** For each principle, identify which brief element it derives from (JTBD trait, constraint, success criterion).
**PASS if:** Each principle has a visible line to the brief.
**FAIL if:** A principle is invented without brief support. Cite the principle.
```

Write similar pairs of checks for each of the seven categories. Target 2-4 checks per category.

Voice and tone checks MUST include: "V1: Voice register is concrete (names specific registers — e.g., 'technical-direct' with an example sentence — not adjective-only like 'friendly but professional')." That's a common slop pattern.

Visual language checks MUST include: "VL1: SAFE/RISK decisions name the category norm, the departure, and what signal the departure creates. Fake rebellion (cosmetic departure without signal) is a FAIL — see `anti-slop.md`."

- [ ] **Step 2: Write cross-cutting check criteria**

Six cross-cutting checks with the same pass/fail format. Match spec §7 cross-cutting list:

- **X1:** Research citations present on SAFE/RISK calls and on standards-referenced decisions. PASS if every SAFE/RISK decision cites at least one peer or standard. FAIL if a SAFE/RISK call has no citation.
- **X2:** Brief alignment — JTBD traits in voice/tone trace to brief. FAIL if a trait has no brief support.
- **X3:** Decisions Log row present (and `replaced` row on fresh-start). FAIL if no row for the current doc version.
- **X4:** Preview alignment — HTML preview covers same declared surfaces as doc. FAIL if preview missing a declared surface's block, or includes a block for an undeclared surface.
- **X5:** SAFE/RISK discipline — no fake rebellion (cosmetic departures). Cite `anti-slop.md` for definition.
- **X6:** Adaptive-scope discipline — no fabricated sections for undeclared surfaces; no missing sections for declared surfaces.

- [ ] **Step 3: Commit**

```bash
git add squad/skills/design-system-review/checklist.md
git commit -m "docs(design-system-review): add review checklist"
```

---

### Task 9: Write `design-system-review/anti-slop.md`

**Files:**
- Create: `squad/skills/design-system-review/anti-slop.md`

Single-source catalog. Referenced by the producer (Task 3 Step 11) and consumed by the validator. Two halves per spec §7 "Anti-slop catalog". Each named pattern has a one-line "why it's slop" so the validator applies specific craft rules, not fashion judgments.

- [ ] **Step 1: Write the doc-prose slop half**

`## Doc-prose slop`. List named patterns with one-line rationales. Minimum set:

```markdown
### Vague principles
"be delightful", "be fast", "be intuitive" — these fit any product; they guide no decision.

### Generic voice descriptors
"friendly but professional", "casual but polished" — adjective-only, no concrete register or example sentence.

### Unanchored adjectives
"clean", "modern", "minimal" without naming what is being removed or what pattern is being followed.

### Fake SAFE/RISK
RISK choices that depart cosmetically without earning the departure (e.g., "use #007acc instead of #0066cc" — same category, same register, no signal).

### Undefined concept mentions
References to "our tone" or "the aesthetic" without the thing being defined anywhere in the doc.

### Filler without evidence
Sections whose body could be deleted without losing information (rhetorical buildup, restatement of the section title).

### Invented personas
User traits that don't trace to the brief's JTBD. Producer cannot add traits the brief does not support.

### Generic interaction-pattern wording
"Make feedback clear" — describes nothing. Compare: "Errors surface inline next to the input that produced them; never as top-level toasts."
```

Provide 1-2 sentences per pattern explaining **why it's slop** beyond what's in the name.

- [ ] **Step 2: Write the visual/content slop half**

`## Visual / content slop (preview HTML)`. Minimum set:

```markdown
### Purple gradients
Signature of AI-generated hero sections. Indicates the producer defaulted to a well-known "pretty" pattern rather than earning the palette from positioning.

### Three-column icon grids with centered lorem
The most overused landing-page pattern. If it appears in a preview without positioning-specific reasoning, it is slop.

### Decorative blobs / abstract shapes
When they do not encode brand signal; decoration in place of meaning.

### Emoji as design
Emoji standing in for icons or visual accents. Signals lack of icon system; not a taste call.

### Colored-left-border cards
Ubiquitous "callout" pattern from modern docs sites. Include only if earned.

### Uniform bubbly radii
Large border-radius on everything. A register choice, but only a choice if explicit; otherwise default.

### Centered-everything layouts
Centering as default. Looks like a landing page, not a product.

### Generic hero copy
"Ship faster." / "Build better." / "The fastest X for Y." — fits any category.

### Overused display fonts
Inter, Roboto, Poppins used without rationale. Popular ≠ reasoned. Any of these is fine if the rationale names why them over alternatives.
```

Again, 1-2 sentences per pattern explaining **why it's slop**.

- [ ] **Step 3: Commit**

```bash
git add squad/skills/design-system-review/anti-slop.md
git commit -m "docs(design-system-review): add anti-slop catalog"
```

---

### Task 10: Triggering test prompts

**Files:**
- Create: `tests/skill-triggering/prompts/design-system-explicit.txt`
- Create: `tests/skill-triggering/prompts/design-system-implicit.txt`
- Create: `tests/skill-triggering/prompts/design-system-negative.txt`

- [ ] **Step 1: Write explicit prompt**

```
Use the design-system skill to create the Design System Doc for this product.
```

- [ ] **Step 2: Write implicit prompt**

```
We have an approved product brief and architecture record and now need to establish the design foundation — principles, voice, visual language, and so on — that feature work will validate against.
```

- [ ] **Step 3: Write negative (review-style) prompt**

```
Review this Design System Doc and tell me whether the categories are complete, the SAFE/RISK calls are honest, and the preview matches the doc.
```

- [ ] **Step 4: Verify each prompt triggers the right skill**

```bash
./tests/skill-triggering/run-test.sh design-system tests/skill-triggering/prompts/design-system-explicit.txt 3
./tests/skill-triggering/run-test.sh design-system tests/skill-triggering/prompts/design-system-implicit.txt 3
./tests/skill-triggering/run-test.sh design-system-review tests/skill-triggering/prompts/design-system-negative.txt 3
```

Expected: each run PASS (the expected skill is triggered in the stream-json log).

- [ ] **Step 5: Commit**

```bash
git add tests/skill-triggering/prompts/design-system-explicit.txt tests/skill-triggering/prompts/design-system-implicit.txt tests/skill-triggering/prompts/design-system-negative.txt
git commit -m "test(design-system): add triggering prompts"
```

---

### Task 11: Register triggering tests in run-all.sh

**Files:**
- Modify: `tests/skill-triggering/run-all.sh`

- [ ] **Step 1: Read the current file**

```bash
cat tests/skill-triggering/run-all.sh
```

Locate the `TESTS=(...)` array. It currently ends at the `product-naming-review` entry.

- [ ] **Step 2: Append three entries before the closing `)`**

Use Edit to change the `TESTS=(` block. The old block ends with:

```
    "product-naming product-naming-explicit.txt"
    "product-naming product-naming-implicit.txt"
    "product-naming-review product-naming-negative.txt"
)
```

Replace the `)` line with these three entries plus the `)`:

```
    "product-naming product-naming-explicit.txt"
    "product-naming product-naming-implicit.txt"
    "product-naming-review product-naming-negative.txt"
    "design-system design-system-explicit.txt"
    "design-system design-system-implicit.txt"
    "design-system-review design-system-negative.txt"
)
```

- [ ] **Step 3: Run the suite**

```bash
./tests/skill-triggering/run-all.sh
```

Expected: all prior tests PASS, all three new design-system tests PASS.

- [ ] **Step 4: Commit**

```bash
git add tests/skill-triggering/run-all.sh
git commit -m "test(design-system): register triggering tests"
```

---

### Task 12: Update skills-architecture inventory

**Files:**
- Modify: `docs/ideation/squad-skills-architecture.md`

- [ ] **Step 1: Update plugin structure listing (lines ~15-45)**

Remove the `# planned` annotation from `design-system/` and `design-system-review/`:

```diff
-│   ├── design-system/           # planned — orchestrator
-│   ├── design-system-review/    # planned (context: fork)
+│   ├── design-system/           # Shipped v0.3.0
+│   ├── design-system-review/    # Shipped v0.3.0 (context: fork)
```

Also remove the three `design-research-*` lines that describe planned helper skills — per spec Decision 4, those are not built:

```diff
-│   ├── design-research-references/  # planned — Reference layer
-│   ├── design-research-audience/    # planned — Reference layer
-│   ├── design-research-standards/   # planned — Reference layer
```

- [ ] **Step 2: Update Implemented skill inventory table (lines ~292-300)**

Add two rows after the `architecture-record-review` row:

```markdown
| `design-system` | Designer | Produce | TBD | Pending (manual execution test) |
| `design-system-review` | QA/Reviewer | Validate (fork) | TBD | Pending (manual execution test) |
```

Fill in actual line counts once files are final.

- [ ] **Step 3: Update Planned skill inventory table (lines ~330-350)**

Remove the three `design-research-*` rows (no longer planned per Decision 4). Remove the `design-system` and `design-system-review` rows (now shipped). Renumber priorities if needed — or add a note that the Design-skills family description above is superseded by the spec.

Also update the "Design-skills family" paragraph (lines ~313-321) to reflect the shipped-pair shape: "The Design System foundation is produced by a two-skill pair (`design-system` + `design-system-review`) following the shipped produce/validate pattern. Research happens inline inside the produce skill; there are no separate helper skills."

Update the bottom-up build order sentence (lines ~328-330) to: "Bottom-up build order: Product Identity first (shipped), then the `design-system` produce/validate pair (shipped). No helper skills in this family."

- [ ] **Step 4: Update the methodology reference table (~lines 405-416)**

Change the status column for `design-system`:

```diff
-| `design-system` | Hypothesis | Orchestration of `product-naming` + `design-research-*` dependencies, then synthesis into a 7-category durable doc (principles, voice, terminology, IA, interaction, visual, surface conventions). Gstack DESIGN.md template as structural baseline for the visual-language category. SAFE/RISK framing for the creative proposal. |
+| `design-system` | Validated | Consultant-posture synthesis into a 7-category adaptive doc. Inline research (peer lookups, standards, audience trace). SAFE/RISK framing on visual language + voice/tone; plain one-line rationale on other decisions. Companion HTML preview from single adaptive template. |
```

Remove the three `design-research-*` rows.

- [ ] **Step 5: Commit**

```bash
git add docs/ideation/squad-skills-architecture.md
git commit -m "docs(architecture): update inventory for shipped design-system pair"
```

---

### Task 13: Run the full knowledge + triggering suite

**Files:**
- No file changes. Verification only.

- [ ] **Step 1: Run knowledge tier**

```bash
./tests/run-tests.sh --tier knowledge
```

Expected: all knowledge tests pass, including both new design-system* tests and the unchanged tests for product-brief, architecture-record, product-naming, and the skill-dependencies test.

- [ ] **Step 2: Run triggering tier**

```bash
./tests/run-tests.sh --tier triggering
```

Expected: all triggering tests pass, including the three new design-system triggering prompts.

- [ ] **Step 3: Run default (knowledge + triggering)**

```bash
./tests/run-tests.sh
```

Expected: PASS summary.

- [ ] **Step 4: If anything fails**

- Knowledge fail → tighten SKILL.md wording so the asserted substrings appear
- Triggering fail → the `description` frontmatter may be too vague; strengthen the skill's description field so Claude reaches for it
- Do NOT retry on 500/429. Stop and wait for service recovery per CLAUDE.md.

- [ ] **Step 5: Commit any tuning fixes**

```bash
git add squad/skills/design-system/SKILL.md squad/skills/design-system-review/SKILL.md
git commit -m "fix(design-system): tune descriptions for triggering"
```

Only commit if changes were needed.

---

### Task 14: Manual execution test on skill-playground (Audenza)

**Files:**
- No repo changes. Artifacts land in skill-playground.

Target directory: `/Users/dim/contexts/personal/projects/skill-playground/docs/`. Per spec §9 it already has approved `product/brief.md`, approved `architecture/record.md` (declares GUI + API), approved `identity/naming.md` (Audenza).

- [ ] **Step 1: Snapshot skill-playground state before run**

```bash
ls -la /Users/dim/contexts/personal/projects/skill-playground/docs/
ls -la /Users/dim/contexts/personal/projects/skill-playground/docs/design 2>/dev/null || echo "no design dir yet — expected"
```

Expected: `product/`, `architecture/`, `identity/` present; no `design/`.

- [ ] **Step 2: Invoke the skill end-to-end**

In a fresh Claude Code session with the squad plugin loaded and `product_home` pointed at `/Users/dim/contexts/personal/projects/skill-playground/docs/`:

```
/design-system
```

Walk through the seven phases interactively as CPTO. Answer Phase-level prompts with realistic product context.

- [ ] **Step 3: Verify artifact presence and shape**

```bash
ls /Users/dim/contexts/personal/projects/skill-playground/docs/design/
```

Expected files:
- `system.md` with `Status: approved`, 7-category adaptive content (GUI + API sections present; CLI + docs **absent** since undeclared), Decisions Log with one `initial` row
- `preview/<date>.html` with GUI + API blocks rendered, no CLI or docs blocks
- `reviews/<date>.md` with PASS verdict, dual grade, per-category and cross-cutting results

- [ ] **Step 4: Code-review the undeclared-surface paths**

Since Audenza declares GUI + API only, manual verification does not exercise CLI + docs paths. Read through:

- `squad/skills/design-system/SKILL.md` Phase 5 — confirm the CLI + docs conditional logic is present and symmetric with GUI + API
- `squad/skills/design-system/preview-template.html` — confirm all four conditional blocks are structurally parallel
- `squad/skills/design-system-review/checklist.md` — confirm adaptive-scope checks X6 apply symmetrically across all four surface types

This is the "code review substitutes for run" step per spec §9.

- [ ] **Step 5: Resolve the anti-slop cross-skill-path question at runtime**

If the produce skill's reference to `../design-system-review/anti-slop.md` resolved cleanly at plugin-load (no error, file content read), leave the reference as-is.

If it failed, execute the fallback from spec §8:
- `mkdir -p squad/skills/_shared`
- `mv squad/skills/design-system-review/anti-slop.md squad/skills/_shared/anti-slop.md`
- Update produce skill reference to `../_shared/anti-slop.md`
- Update validator skill reference to `../_shared/anti-slop.md`
- Remove the `<!-- if cross-skill relative path fails -->` HTML comment in the produce SKILL.md (Task 3 Step 11)
- Commit: `fix(design-system): fall back to _shared/ for anti-slop catalog`

- [ ] **Step 6: Record result in the plan document**

Append a "Manual execution test result" section at the bottom of this plan file capturing:
- Date run
- Outcome (pass | pass-with-notes | fail)
- Any finding that required skill edits
- Path to the produced `system.md`

- [ ] **Step 7: Final commit**

```bash
git add docs/superpowers/plans/2026-04-19-design-phase-skills.md
git commit -m "docs(plans): record design-system manual execution test result"
```

---

## Self-Review

Before handing off, check:

**Spec coverage:**
- §2 Design Phase Goal → Task 3 (SKILL.md Phase 5-7 produce the artifact matching "done" criteria)
- §3 Surfaces in Scope → Task 3 Phase 4-5 (adaptive scope) + Task 5 (preview template 4 conditional blocks) + Task 8 (adaptive-scope discipline check X6)
- §4 Decisions — all 9 decisions + 4 defaults-carried-forward:
  - D1 consultant posture → Task 4 synthesis-guide
  - D2 adaptive scope → Task 3 Phases 1, 4, 5
  - D3 MCP deprioritized → Task 3 Phase 4 (CLI is the LLM surface mode)
  - D4 research inline → Task 3 Phase 4 + Task 4
  - D5 SAFE/RISK scope → Task 4 synthesis-guide + Task 8 checklist
  - D6 single-pass draft → Task 3 Phase 5 inline iteration
  - D7 anti-slop single source → Task 9
  - D8 pre-check update/fresh/cancel → Task 3 Phase 2
  - D9 HTML preview load-bearing → Task 5 preview-template + Task 3 Phase 5
  - product-naming sub-skill → Task 3 Phase 3
- §5 Skill Family Structure → Tasks 1, 3, 7 (two skills + paths)
- §6 Produce Skill Flow → Task 3 (all 7 phases)
- §7 Validator Shape → Task 7 SKILL.md + Task 8 checklist + Task 9 anti-slop
- §8 Per-Skill Init Briefs → covered across Tasks 3-9
- §9 Build Order → Task order enforces this; Task 14 is the manual execution on skill-playground
- §10 Out of Scope → execution-tier automation deferred (no task); handled by Task 14 manual

**Placeholder scan:** no "TBD", "implement later", or "similar to Task N" references above. The "TBD" in Task 12 Step 2 refers to **line counts to be filled** once files exist — that is an instruction, not a placeholder for unfilled behavior.

**Type consistency:**
- `${user_config.product_home}` used uniformly (matches existing shipped skills' template syntax)
- Artifact paths: `design/system.md`, `design/preview/<date>.html`, `design/reviews/<date>.md` — consistent across producer, validator, and tests
- Review report file named the same in producer Phase 6 and validator Process step 5
- Verdict vocabulary: `PASS | PASS_WITH_NOTES | FAIL` — exact same strings in producer Phase 6, validator Output format, and knowledge test assertions
- Triage vocabulary: `High | Medium | Polish` — consistent across validator SKILL.md, checklist.md, and knowledge test
- Sub-skill Report statuses: exact `DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED` match squad-skills-architecture.md

**Checklist-item ↔ phase mapping:** 13 checklist items → 7 phases per spec §6. The checklist is finer-grained than phases (each phase has 1-2 checklist items). This is consistent with how architecture-record lists 13 checklist items across its two phases.
