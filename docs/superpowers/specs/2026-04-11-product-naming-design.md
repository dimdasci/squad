# Design: Product Naming Skills

Date: 2026-04-11
Status: draft

## Summary

Two skills following the shipped produce/validate pattern:

- **`product-naming`** (Produce) — Designer role. Generates a wide
  candidate pool via parallel subagent dispatch, filters aggressively
  with cheap automated checks, ranks survivors with SMILE/SCRATCH,
  and walks the CPTO through two judgment gates to reach a final
  name. Writes the `naming.md` artifact with a full validation record.
- **`product-naming-review`** (Validate, `context: fork`) — QA/Reviewer
  role. Independent structural review of `naming.md` — does not second-
  guess taste, only validates completeness, honesty of the validation
  record, and internal consistency.

This is the third skill pair in the squad framework, after
`product-brief` / `product-brief-review` and `architecture-record` /
`architecture-record-review`. It closes the **Product Identity**
durable foundation, leaving only Design System as the remaining empty
foundation.

## Context

The Product Identity foundation contains one artifact:
`${user_config.product_home}/identity/naming.md`. It holds the product
name, naming philosophy, approved short forms and forbidden variants,
capitalization and pronunciation rules, and the validation record
(automated filter results plus human-reported trademark state).

`product-naming` runs in one of three invocation modes:

1. **Standalone greenfield** — approved brief exists, `naming.md`
   does not. Full process runs, writes new artifact, ends with CPTO
   approval.
2. **Standalone rebrand** — approved brief exists, `naming.md` exists.
   Skill reads the existing artifact, asks one open-ended question
   about what's changing, uses the answer as a generation constraint,
   replaces the artifact in place. Git history is the audit trail —
   no "superseded" ceremony.
3. **Orchestrated dependency** — invoked by `squad:design-system` when
   the brief has no chosen name. Runs the same process but terminates
   with a Sub-skill Report per the contract in
   `docs/ideation/squad-skills-architecture.md:211-222` instead of
   handing back to the CPTO directly.

Mode is detected from filesystem state at step 1.

### Methodological grounding

The skill is inspired by three publicly available naming frameworks,
with squad-specific adaptations:

- **Igor Naming Guide** (Jurisich & Manning, Igor International, 2022)
  — 4-category name taxonomy (functional / invented / experiential /
  evocative). Freely available PDF at igorinternational.com.
- **SMILE / SCRATCH** from *Hello, My Name Is Awesome*
  (Alexandra Watkins, 2018) — SMILE rubric for evaluation (Suggestive,
  Meaningful, Imagery, Legs, Emotional), SCRATCH rubric for elimination
  (Spelling-challenged, Copycat, Restrictive, Annoying, Tame, Curse-
  of-knowledge, Hard-to-pronounce).
- **Rob Meyerson's 7-step pipeline** (howbrandsarebuilt.com, 2022) —
  operational stage vocabulary: Brief → Generate → Shortlist → Screen →
  Present → Legal → Select.

The skill does not reproduce these frameworks literally. It embeds
the core concepts (taxonomy, rubric, stage pipeline) and adapts pool
sizes, generation mechanics, and validation checks to what's feasible
for a small team inside Claude Code. The `naming-playbook.md` supporting
file cites sources explicitly.

## Skill: product-naming

### Directory structure

```
squad/skills/product-naming/
├── SKILL.md              # Main skill, ~350 lines
└── naming-playbook.md    # Methodology, taxonomy, rubric, artifact template, ~300 lines
```

Supporting file loaded on-demand via markdown link from `SKILL.md`,
same pattern as shipped `architecture-record` (`survey-guide.md`,
`record-guide.md`). This keeps `SKILL.md` under the 500-line cap.

### Frontmatter

```yaml
---
name: product-naming
description: >
  Produce or revise the product naming artifact — the chosen product
  name plus its supporting system (philosophy, usage rules, forbidden
  variants, validation record). Use when a product brief is approved
  and no name exists yet, when rebranding an existing product, or when
  invoked as a dependency by squad:design-system.
allowed-tools: Task WebSearch WebFetch Bash(sh /tmp/naming-dedup.sh)
---
```

Tool grants:
- **Task** — required for the parallel subagent dispatch in step 3a.
- **WebSearch** — for the brand collision filter (Filter 2).
- **WebFetch** — for RDAP and HTTPS probes in the primary TLD filter
  (Filter 3).
- **Bash(sh /tmp/naming-dedup.sh)** — narrow grant, only the one dedup
  script path. The skill writes the script to `/tmp/` via the Write
  tool before invoking. No wildcard bash access.

### Hard gate

```markdown
<HARD-GATE>
Do NOT start without an approved product brief. Naming without a
defined problem produces marketing fluff.

If no approved brief exists at ${user_config.product_home}/product/brief.md:

- **Standalone mode** — stop and tell the user to run
  `squad:product-brief` first.
- **Orchestrated mode** (invoked by squad:design-system) — emit a
  Sub-skill Report with status BLOCKED and reason "no approved
  product brief". Do not address the user directly.
</HARD-GATE>
```

The mode fork is required because in orchestrated mode, the
orchestrator owns the user-facing channel — the sub-skill speaks to
the orchestrator via the Sub-skill Report contract, not to the CPTO
directly. Mode is detected in step 1 (filesystem state plus
invocation context) and remembered for the entire run.

### Process: Two Stages, 13-Step Checklist

**Stage 1 — Pool to shortlist (autonomous)**

1. **Read existing context** — check approved brief, existing
   `naming.md`, and invocation mode (greenfield / rebrand /
   orchestrated). If hard gate fails, stop.
2. **Positioning brief** — extract from product brief and confirm
   with CPTO.
3. **Generate candidate pool** — dispatch 4 parallel subagents,
   dedupe, ~200 surviving candidates.
4. **Automated filter pass** — apply 3 filters in cheapest-first
   order.
5. **SMILE/SCRATCH ranking** — rank survivors, take top 12.
6. **Present shortlist (CPTO Gate 1)** — CPTO picks 3–5 finalists.

**Stage 2 — Finalists to chosen name**

7. **Trademark search handoff** — optional helper, CPTO reports back.
8. **Brand viability writeup** — per-finalist note.
9. **Present finalists (CPTO Gate 2)** — Claude leans with
   dimensional grounding; CPTO picks winner.
10. **Write `naming.md`** — status `draft`.
11. **Independent review** — invoke `squad:product-naming-review`
    (fresh context fork).
12. **Address findings** — fix FAIL items.
13. **Request CPTO approval** — status flips to `approved`.

### Step detail

#### Step 1 — Read existing context

Check:
- `${user_config.product_home}/product/brief.md` exists and has
  `Status: approved`. If not, hard-gate failure: stop and tell the
  user to run `squad:product-brief`.
- `${user_config.product_home}/identity/naming.md` exists. If yes,
  this is a rebrand; read it as context.
- Invocation mode: if the skill was invoked from `squad:design-system`
  (orchestrator), remember this — it affects how step 13 behaves.

If `${user_config.product_home}` is not set, ask the user to
configure it (same message pattern as shipped skills).

#### Step 2 — Positioning brief

Extract five inputs from the approved brief, present as a table, and
ask the CPTO to confirm:

| Input | Source in brief | Constrains |
|---|---|---|
| Target users | JTBD job stories | Register, languages, reading level |
| Category | Solution Boundary IS | Brand collision search category |
| Tone | Derived from problem framing and user descriptions | Register: playful / technical / stoic / warm / clinical |
| Appetite / maturity | Appetite section | Bias toward functional (short-horizon) vs invented/evocative (long-horizon) |
| Must-avoid | IS NOT + explicit CPTO constraints | Words, metaphors, competitors to steer clear of |

For any input the brief doesn't support cleanly (typically tone and
must-avoid), ask the CPTO **one open-ended question per gap** — not
a menu. The positioning paragraph is carried forward in the
conversation, not persisted as its own file.

For **rebrand mode**, additionally ask one open-ended question:
"What's changing, and why?" The answer becomes a must-avoid
constraint (don't regenerate candidates that repeat the problem the
rebrand is solving).

#### Step 3 — Generate candidate pool

Two sub-steps:

**3a — Parallel subagent dispatch.** The skill uses the `Task` tool
to dispatch 4 parallel subagents in a single message (the platform
runs them concurrently when called in one assistant turn). It follows
the pattern documented in `superpowers:dispatching-parallel-agents`
— that skill is a behavioral pattern guide for fan-out via the Task
tool, not a callable entry point. The skill is responsible for
constructing each subagent's prompt and pooling the outputs.

Each subagent receives the confirmed positioning brief plus one
distinct generative lens and writes its output to a lens-tagged temp
file. Each subagent targets ~60 names. Total raw output ~240 before
dedupe.

| Lens | Role | Prior source |
|---|---|---|
| 1 | Functional / descriptive | Literal to the category |
| 2 | Evocative / metaphorical | One adjacent domain selected at the start of step 3a from a fixed list of 8–10 domains documented in `naming-playbook.md` (e.g., nature, craft, mythology, food, geology, music, architecture, weaving) |
| 3 | Invented / coined | Morpheme play, Latin/Greek/Romance roots, phonetic fit |
| 4 | Experiential / verb-forward | What the user does or feels, not what the product is |

**Lens 2 domain selection.** Claude has no RNG. The skill picks the
adjacent domain by index `(day-of-month % len(domain_list))` computed
from the system date, deterministic and rerun-stable for the day. If
the CPTO triggers a regeneration (Gate 1), the skill rotates to the
next index instead of repicking the same domain. The chosen domain
is recorded in the validation record (`Generation context` section)
so the CPTO can see which prior seeded lens 2.

Each subagent writes its output to `/tmp/naming-pool-lens<N>.txt`,
one candidate per line in the format `Name|<N>`. Lens 2's subagent
prompt places the adjacent-domain anchor **before** the positioning
brief in the prompt text, instructing the subagent to first immerse
in the domain's associative field, then read the brief and generate
names that bridge the two — this is the decoy-analogue, the
deliberate prior shift.

**3b — Dedupe pipeline.** Skill writes a shell script to
`/tmp/naming-dedup.sh`:

```bash
#!/bin/sh
cat /tmp/naming-pool-lens*.txt | \
  awk -F'|' '
    {
      gsub(/\r/, "", $0)
      gsub(/^[ \t]+|[ \t]+$/, "", $1)
      gsub(/^[ \t]+|[ \t]+$/, "", $2)
      if ($1 == "" || $2 == "") next
      key = tolower($1)
      if (!(key in seen)) {
        seen[key] = 1
        display[key] = $1
        lens_set[key, $2] = 1
        lens_order[key] = $2
      } else if (!((key, $2) in lens_set)) {
        lens_set[key, $2] = 1
        lens_order[key] = lens_order[key] "," $2
      }
    }
    END {
      for (key in seen) print display[key] "|" lens_order[key]
    }
  ' | sort -f > /tmp/naming-pool-deduped.txt
```

The script:
- Strips carriage returns (subagent files may have them)
- Trims whitespace on both fields
- Skips empty lines (defensive)
- Uses a 2D associative array (`lens_set[key, lens]`) to deduplicate
  lens identifiers per name — if lens 1 happens to emit "Sprig" twice,
  the lens list still reads `1`, not `1,1`
- Preserves first-seen casing as the display form
- Sorts case-insensitive for human reading

Invokes via `sh /tmp/naming-dedup.sh`. Reads
`/tmp/naming-pool-deduped.txt` back for the next step. Output
format: `DisplayName|lens1,lens3` — each surviving candidate carries
its source-lens attribution. Cross-lens hits (same name in 2+ lenses
independently) are preserved as a minor quality signal for Step 5.

Expected pool size after dedupe: ~180–220 candidates.

#### Step 4 — Automated filter pass

Three filters in cheapest-first order. Each candidate is tagged
`eliminated` or `kept` with the reason recorded internally.

**Filter 1 — Linguistic / phonetic viability (Claude reasoning, no
tool calls).**

For each candidate, Claude evaluates against the target languages from
positioning: pronounceable by target users? Offensive or awkward in
any target-market language? SCRATCH hits (spelling-challenged,
hard-to-pronounce, curse-of-knowledge, tame)? Eliminate candidates
that fail any hard SCRATCH criterion.

First because free and highest-discriminative (kills the
five-syllable-unpronounceable case before any tool call spends budget
on it).

**Filter 2 — Well-known brand collision (1 WebSearch per Filter-1
survivor).**

Single focused WebSearch per candidate: `"<name>" <category>` (where
category comes from the positioning brief). If page-one results
include a recognizable brand or product in the category or an adjacent
category, eliminate. Bar is "recognizable", not "exists somewhere."
Claude judges recognizability from snippets — a 10-year-old indie
project with 50 stars is not a collision; a funded startup is.

**Filter 3 — Primary TLD active-site probe (1 RDAP + 1 HTTPS per
Filter-2 survivor).**

For each candidate that survived Filter 2:
- Query `https://rdap.verisign.com/com/v1/domain/<name>` via WebFetch
- HTTPS probe `https://<name>.com` via WebFetch

Classify:
- **Available** (RDAP 404) → kept, strong positive signal
- **Parked / for-sale** (registered, HTTPS returns parking page) →
  kept, noted as buyable
- **Active site** (registered, HTTPS returns a real site not matching
  parking patterns) → eliminated, recorded with site title if
  detectable

Parking detection is a best-effort HTML check: `"for sale"`,
`"afternic"`, `"sedo"`, GoDaddy parking markup. When ambiguous,
default to `kept, verify manually` — loose filter safer than strict.

RDAP for .com is authoritative from sandbox (Verisign endpoint works).
For .io, .dev, .app — skill uses HTTPS probe only and reports best-
effort state.

#### Step 5 — SMILE/SCRATCH ranking

For each Filter-3 survivor, Claude scores against the SMILE rubric:

- **Suggestive** (evokes brand) — 0–2
- **Meaningful** (resonates with target users, not only the founder) — 0–2
- **Imagery** (visualizable) — 0–2
- **Legs** (extensible to a brand theme) — 0–2
- **Emotional** (moves people) — 0–2

Total 0–10. SCRATCH hits already eliminated in Filter 1, so ranking
uses SMILE only.

**Cross-lens bonus.** Candidates that appeared in 2+ lenses during
generation get a +1 tiebreaker bump (not enough to override a
single-lens strong candidate, but breaks ties in favor of names that
felt inevitable from multiple associative angles).

Take the **top 12** by adjusted SMILE total. If fewer than 12
survive, take all survivors and flag "pool was tight — consider
rerun with broadened positioning" as a note to the CPTO.

#### Step 6 — Present shortlist (CPTO Gate 1)

Skill writes a shortlist table to the conversation:

```markdown
| Name | Category | Lens(es) | SMILE | Positioning fit | Filter notes |
|---|---|---|---|---|---|
| ... | evocative | 2,4 | 8/10 | strong | .com available; no collision |
| ... | invented | 3 | 7/10 | medium | .com parked (likely buyable); no collision |
| ... | functional | 1 | 6/10 | strong | .com available |
```

CPTO options:
- **Pick** 3–5 specific candidates by name
- **Regenerate** one or more category slots with a tweaked positioning
  direction (skill reruns steps 3–5 with adjusted weights)
- **Chat about this** — open-ended escape hatch

No cap on regeneration count — judgment stays with the human.

#### Step 7 — Trademark search handoff (optional helper)

Skill presents three registry URLs for the finalists:

```
USPTO:   https://tmsearch.uspto.gov
WIPO:    https://branddb.wipo.int
EUIPO:   https://euipo.europa.eu/eSearch
```

Prompt:

> "If you want to check trademark availability for the finalists,
> these are the three public registries. This is the only legal
> hard-stop check, but it's optional — you can skip it entirely or
> check any subset. For each finalist, report back as:
> clear / conflict / ambiguous / skipped."

The skill does not attempt to WebFetch these URLs (they're
JS SPAs behind bot protection — verified in 2026-04-11 research).
No pre-filled query strings (the sites don't accept them). No nudging
about skipping. No commentary.

CPTO reports per finalist, per jurisdiction. Any finalist marked
`conflict` in any jurisdiction drops from the advancing set. All
other states (`clear`, `ambiguous`, `skipped`) advance. The skill
records verbatim in the validation record, honestly reflecting what
was actually done.

If all finalists hit `conflict`, the skill loops back to Gate 1 and
asks the CPTO whether to reopen the shortlist, regenerate the pool,
or escalate. Never silently falls through.

#### Step 8 — Brand viability writeup

For each advancing finalist (finalists not marked conflict), Claude
writes a short brand viability note:

```markdown
### [Name] — [category]

**Positioning fit:** [1 sentence]
**SMILE strengths:** [strongest dimensions]
**SMILE weaknesses:** [any scoring <1, honest]
**Linguistic notes:** [pronunciation across target languages,
  syllable count, stress, any stylization caveats]
**Primary web presence:** [.com status from Filter 3]
**Trademark result:** [verbatim per jurisdiction]
**Known risks:** [phonetic overlap with competitors, buyable domain
  cost estimate, etc.]
```

Written to the conversation for Gate 2, not yet persisted.

#### Step 9 — Present finalists (CPTO Gate 2)

Skill presents the advancing finalists with their brand viability
notes and adds a grounded lean:

> "Here are the finalists for the final pick. I'd lean toward
> **[Name B]** — highest SMILE score, direct positioning fit, .com
> available, trademark clear in all three jurisdictions you checked.
> **[Name C]** is the alternative worth serious consideration —
> stronger emotional pull, but a phonetic risk for English speakers
> (five syllables, unfamiliar consonant cluster). Which one do you
> want to ship?"

Claude's lean is grounded in measurable dimensions (SMILE,
positioning fit, TLD state, trademark result, linguistic risk) and
names which dimensions drove it, so the CPTO can challenge the
framing, not just the conclusion.

CPTO options:
- Pick the leaned name
- Pick a different finalist
- Reject all — skill offers: reopen shortlist, rerun generation, or
  halt
- Chat about this — open-ended escape hatch

#### Step 10 — Write `naming.md`

**Forbidden variants and approved short forms — content source.**
Before writing the artifact, the skill generates a draft "Forbidden
variants" list from the chosen name's phonetic neighbors,
common-misspelling patterns, and forbidden stylization rules
(all-caps, all-lowercase, hyphenated forms that don't match the
canonical stylization). It generates a draft "Approved short forms
and nicknames" list (typically the first 1–2 syllables, common
contractions, any explicit short form from the brief). Both drafts
are presented to the CPTO for confirmation, edit, or removal —
**one open-ended question per list**, not a menu. The artifact
records the CPTO-confirmed final version.

Save to `${user_config.product_home}/identity/naming.md`:

```markdown
# Product Naming: [Name]

Status: draft
Date: YYYY-MM-DD
Approved by: pending
Brief: product/brief.md

## Chosen name

**[Name]**

**Category:** [Igor 4-category]
**Pronunciation:** [phonetic guide]
**Stylization:** [capitalization rule — e.g., "Trabajador", never
  "TRABAJADOR" or "trabajador"]

## Philosophy

[Why this name — what it expresses, how it connects to the brief's
positioning, what the CPTO is staking on it. 1–3 paragraphs. This
is the section the CPTO writes in voice with Claude's help, not
auto-generated from rubric scores.]

## Usage rules

### Approved short forms and nicknames
- ...

### Forbidden variants
- ... (misspellings, forbidden stylizations, former names if rebrand)

### How it appears in sentences
[Capitalization rule, article usage, possessive form, plural form]

### What this product is NOT called
- ...

### Context-specific usage
- **Marketing:** ...
- **Product UI:** ...
- **Docs:** ...
- **Code identifiers:** ... (npm scope, module name — derived, not
  canonical)

## Validation record

### Filters (automated)

| Filter | Result | Notes |
|---|---|---|
| Linguistic / phonetic (SCRATCH) | PASS | [brief note] |
| Brand collision search | PASS | [search query, page-one summary] |
| Primary TLD probe | [available / buyable / active] | [details] |

### Trademark (human-run, optional)

| Jurisdiction | Result | Notes |
|---|---|---|
| USPTO | clear / conflict / ambiguous / skipped | [verbatim CPTO-reported detail] |
| WIPO | ... | ... |
| EUIPO | ... | ... |

### Generation context

- **Pool size:** [actual, post-dedupe]
- **Lens 2 adjacent domain:** [domain seed for this run, e.g., "craft"]
- **Cross-lens hit:** [yes/no — did the chosen name appear in
  multiple lenses independently?]
- **Reruns:** [N — number of generation reruns triggered, e.g.,
  trademark conflicts on prior finalists; 0 if first run produced
  the chosen name]
```

#### Step 11 — Independent review

Invoke `squad:product-naming-review`. Runs in fresh context fork. Wait
for findings.

#### Step 12 — Address findings

Same handling as shipped skills:
- **PASS** → proceed directly to CPTO approval
- **PASS WITH NOTES** → fix what you agree with, proceed
- **FAIL** → work through each finding (clear fix / multiple paths
  with CPTO consultation / disagree with reasoning)

After fixes, re-run steps 10–11.

#### Step 13 — Request CPTO approval (or emit Sub-skill Report)

**Standalone modes** — present the artifact to the CPTO:

> "Product naming written to
> `${user_config.product_home}/identity/naming.md`. Please review
> and let me know if you want changes before we proceed."

On approval, flip `Status: approved`, set date and approver.
Product Identity is one of four durable foundations. After approval,
if `squad:design-system` has not already produced an approved Design
System Doc, declare it as the next skill.

**Orchestrated mode** — emit Sub-skill Report per the
"Sub-skill status protocol" section of `squad-skills-architecture.md`
instead of presenting to CPTO. The artifact is written with
`Status: draft`. **The sub-skill never sets `Status: approved` in
orchestrated mode** — Product Identity foundation approval flows
through the orchestrator (`design-system`), which is responsible for
surfacing the artifact to the CPTO and triggering the approval. This
preserves the rule that durable foundation approvals belong to the
human CPTO, while keeping the orchestrator in control of the
user-facing channel.

Report:

```markdown
## Sub-skill Report

- **Status:** DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED
- **Artifact:** ${user_config.product_home}/identity/naming.md
- **Summary:** [1–3 sentences: chosen name, why it survived, any caveats]
- **Notes / Question / Reason:** [per status, matching shipped contract]
- **Working state:** clean | partial: [list]
```

Status mapping:
- **DONE** — artifact written, review passed, all filters cleared
  normally
- **DONE_WITH_CONCERNS** — artifact written, but caveats the
  orchestrator should read (all trademark jurisdictions skipped,
  .com unavailable on chosen name, pool was tight requiring rerun)
- **NEEDS_CONTEXT** — CPTO ambiguous on positioning or finalist pick,
  sub-skill halted on a question
- **BLOCKED** — hard gate failed (brief missing or not approved),
  or all finalists hit trademark conflict and no recovery path

### Chains To

After CPTO approves the naming artifact in standalone mode:

- If `${user_config.product_home}/design/system.md` does not exist
  or is not approved, declare `squad:design-system` as the next
  skill (Product Identity is one of four equal-rank foundations;
  Design System is another, and a working inner cycle requires
  both).
- If Design System is already approved, no chain — the four
  durable foundations are complete and the next step is the outer
  cycle (`squad:product-backlog`, planned).

In orchestrated mode, no chain — control returns to the orchestrator
via the Sub-skill Report.

### SKILL.md content requirements

The shipped SKILL.md (not just this spec) must include:

- **DOT process digraph** showing the 13-step flow with the two
  CPTO gates marked, matching the pattern in
  `product-brief/SKILL.md` and `architecture-record/SKILL.md`.
- **"Common Rationalizations" table** at the end of the SKILL.md,
  listing the 4–6 most likely shortcuts the agent will be tempted
  to take and why each one is wrong. Examples:

  | Excuse | Reality |
  |---|---|
  | "I can pick a name without the brief" | Naming without a defined problem produces marketing fluff. Hard gate exists for a reason. |
  | "200 candidates is overkill, 30 is enough" | Single-context generation locks on the first register; the wide pool exists to escape the autoregressive trap, not to be exhaustive. |
  | "Skip the parallel dispatch, just generate everything in one call" | Same trap as above. The 4 lenses are isolated contexts on purpose. |
  | "Trademark check is optional, so I'll skip it for the user" | The CPTO decides whether to skip, not the agent. Present the helper, accept the answer. |

  Final wording is set during SKILL.md authoring; the spec only
  requires the table exists.

## Skill: product-naming-review

### Directory structure

```
squad/skills/product-naming-review/
└── SKILL.md              # ~150 lines
```

### Frontmatter

```yaml
---
name: product-naming-review
description: >
  Independent review of the product naming artifact. Validates
  structural completeness, honesty of the validation record, and
  internal consistency. Does not second-guess the CPTO's taste
  decisions. Invoked by product-naming after the artifact is drafted.
context: fork
---
```

`context: fork` ensures fresh-context review — the reviewer does not
see how the artifact was produced.

### Review checklist

Three passes:

**Pass 1 — Structural completeness.**
- Status / Date / Approved-by / Brief fields present
- Chosen name section: name, category, pronunciation, stylization
  all non-empty
- Philosophy section non-empty (at least one paragraph)
- Usage rules: all 5 subsections populated (approved short forms,
  forbidden variants, sentence usage, what it's NOT called,
  context-specific)
- Validation record: all 3 automated filters populated; all 3
  trademark jurisdictions present with a result (including
  `skipped`); generation context present

**Pass 2 — Honesty of the validation record.**
- Automated filter results match the artifact's claimed state (no
  silently relabeled `skipped` as `clear`)
- Chosen name is not in any forbidden variant list
- Approved short forms do not conflict with forbidden variants
- Context-specific usage does not contradict stylization rule
- If `Primary TLD probe` shows `active`, artifact notes the alternate
  TLD strategy or explains why the chosen name still works

**Pass 3 — Philosophy-to-evidence alignment.**
- Philosophy section claims (e.g., "evokes craftsmanship") are
  consistent with the name's category and SMILE strengths
- Philosophy does not contradict the brief's positioning

Verdict:
- **PASS** — all three passes clean
- **PASS WITH NOTES** — minor issues the producer should consider
  but are not blocking
- **FAIL** — one or more material issues (e.g., validation record
  dishonest, required section empty, chosen name contradicts forbidden
  variant list)

Format follows shipped reviewers (`product-brief-review`,
`architecture-record-review`). Reviewer outputs findings structured
by pass, with specific line references where possible.

## Testing plan

Three tiers per `tests/` convention.

### Tier 1 — Knowledge (`tests/skill-knowledge/test-product-naming.sh`)

5 questions:

1. "What happens if no approved product brief exists?"
   → expected: hard-gate refusal, points user to `squad:product-brief`
2. "How does the skill generate candidate names?"
   → expected: 4 parallel subagents with differentiated lenses,
      ~200 candidates after dedupe
3. "What are the three automated filters?"
   → expected: linguistic/SCRATCH, brand collision WebSearch,
      primary TLD RDAP+HTTPS
4. "Is the trademark check mandatory?"
   → expected: optional helper, CPTO can skip, result recorded
      honestly in artifact
5. "Where is the artifact written?"
   → expected: `${user_config.product_home}/identity/naming.md`

Pattern: `run_claude_knowledge` with `--max-turns 5` to prevent the
skill from actually running.

### Tier 2 — Triggering (`tests/skill-triggering/prompts/`)

Three prompts:
- **Explicit:** `product-naming-explicit.txt` — "Help me name my
  product. I have an approved brief but no name yet." → should trigger
  `product-naming`
- **Implicit:** `product-naming-implicit.txt` — "I need to pick a
  name for this thing before launch" → should trigger `product-naming`
- **Negative:** `product-naming-negative.txt` — "What font should my
  logo use?" → should NOT trigger `product-naming` (Design System
  territory)

Add `product-naming` to `tests/skill-triggering/run-all.sh` TESTS array.

### Tier 3 — Execution (`tests/skill-execution/test-product-naming-execution.sh`)

Run the full skill against a fixture brief. Fixture: an approved
product brief for a synthetic product (e.g., a small Trabajador-style
project with a defined problem, users, and positioning). Verify:

- `identity/naming.md` exists at the correct path after skill runs
- All required sections populated per the review checklist
- `Status: draft` (not `approved` — the skill does not auto-approve)
- Chosen name is non-empty
- Validation record shows all 3 automated filter results
- All 3 trademark jurisdictions present (with any valid result
  including `skipped`)
- Generation context shows lens-2 adjacent domain and pool size

Respects the "stop on 500/429" rule from memory.

## File layout summary

```
squad/skills/product-naming/
├── SKILL.md              # ~350 lines — process, checklist, step detail
└── naming-playbook.md    # ~300 lines — methodology depth

squad/skills/product-naming-review/
└── SKILL.md              # ~150 lines — review checklist

tests/skill-knowledge/
└── test-product-naming.sh

tests/skill-triggering/prompts/
├── product-naming-explicit.txt
├── product-naming-implicit.txt
└── product-naming-negative.txt

tests/skill-execution/
├── test-product-naming-execution.sh
└── fixtures/product-naming-brief.md
```

## Architecture updates from this spec

**`docs/ideation/squad-skills-architecture.md` line 398** — updated
in the same change as this spec. The previous row described a custom
6-category taxonomy and an over-promised mandatory validation list,
both of which were speculative pre-research. Replaced with Igor's
4-category taxonomy + Watkins SMILE/SCRATCH + Meyerson 7-stage
pipeline + parallel subagent generation (the actual methodology
spine this spec uses).

## Methodology sources (cited in `naming-playbook.md`)

- Jurisich, S. & Manning, S., *Igor Naming Guide*, Igor International,
  2022. https://www.igorinternational.com/process/i/Igor%20Naming%20Guide%202022A.pdf
- Watkins, A., *Hello, My Name Is Awesome*, Berrett-Koehler, 2018
  (SMILE/SCRATCH rubric widely summarized in public sources).
- Meyerson, R., "A seven-step process for brand naming",
  howbrandsarebuilt.com, 2022.
- Lexicon Branding (David Placek) — cited for parallel-team
  generation philosophy (the decoy-brief technique that motivates
  the 4-lens parallel subagent dispatch).
