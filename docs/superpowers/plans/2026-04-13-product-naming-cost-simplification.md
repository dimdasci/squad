# Product-Naming Cost Simplification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the broken Filter 3 in the `product-naming` skill, remove WebFetch entirely, and add a multi-TLD domain availability grid via DNS-over-HTTPS. All structural elements (SMILE, SCRATCH, parallel dispatch, review pair) stay untouched.

**Architecture:** Markdown-only edits to four files — the `product-naming` SKILL, its playbook, the paired `product-naming-review` SKILL, and the execution test. Pre-Gate-1 narrowing keeps Filter 2 WebSearch but drops Filter 3. Filter 3's work (domain check) moves to Step 8 post-Gate-1, runs DoH via Bash `curl` on finalists × a fixed TLD set, and produces a grid for Gate 2 decision support.

**Tech Stack:** Claude Code skill markdown, Google DoH (`dns.google`), Bash `curl`, `jq` not needed (Claude parses JSON inline).

**Spec:** `docs/superpowers/specs/2026-04-13-product-naming-cost-simplification-design.md`

---

## File Structure

- Modify: `squad/skills/product-naming/SKILL.md` — front matter, Step 4, Step 8, Step 10, process diagram
- Modify: `squad/skills/product-naming/naming-playbook.md` — replace "Filter 3 implementation notes" with DoH notes
- Modify: `squad/skills/product-naming-review/SKILL.md` — update Pass 1 and Pass 2 checks for new validation record shape
- Modify: `tests/skill-execution/test-product-naming-execution.sh` — update assertions for new shape

No files created, no files deleted.

## Worktree

Markdown-edit plan on a single skill family. Worktree is optional. If the executor wants to keep main tidy, create one via `superpowers:using-git-worktrees`; otherwise execute in the main tree.

---

## Task 1: Front matter — remove WebFetch, add DoH curl to Bash allowlist

**Files:**
- Modify: `squad/skills/product-naming/SKILL.md:4`

- [ ] **Step 1: Verify Claude Code `allowed-tools` syntax for Bash patterns**

Open Claude Code docs or plugin reference. The existing entry is `Bash(sh /tmp/naming-dedup.sh)`. Determine whether multi-pattern Bash allow-lists use comma-separated patterns inside a single `Bash(...)` clause, or multiple `Bash(...)` clauses. Determine whether URL globs (e.g., `curl -s 'https://dns.google/*'`) are supported.

Expected outcome: one of two working syntaxes for permitting both `sh /tmp/naming-dedup.sh` and `curl -s 'https://dns.google/resolve...'`.

- [ ] **Step 2: Edit front matter**

Find (line 4):

```yaml
allowed-tools: Task WebSearch WebFetch Bash(sh /tmp/naming-dedup.sh)
```

Replace with (syntax per Step 1; example shown assumes comma-separated inside `Bash(...)`):

```yaml
allowed-tools: Task WebSearch Bash(sh /tmp/naming-dedup.sh, curl -s 'https://dns.google/resolve?*')
```

- [ ] **Step 3: Verify edit**

Run: `grep -n "allowed-tools" squad/skills/product-naming/SKILL.md`

Expected: line 4 shows the new value; no `WebFetch` remains anywhere in the front matter.

- [ ] **Step 4: Commit**

```bash
git add squad/skills/product-naming/SKILL.md
git commit -m "refactor(squad): remove WebFetch from product-naming allowed-tools"
```

---

## Task 2: Step 4 — tighten Filter 2 interpretation rule, remove Filter 3

**Files:**
- Modify: `squad/skills/product-naming/SKILL.md` — Step 4 (`### 4. Automated filter pass`)

- [ ] **Step 1: Update Step 4 intro count**

Find:

```markdown
### 4. Automated filter pass

Three filters, cheapest-first. Each candidate tagged `eliminated` or
`kept` with reason recorded internally.
```

Replace with:

```markdown
### 4. Automated filter pass

Two filters, cheapest-first. Each candidate tagged `eliminated` or
`kept` with reason recorded internally. (Filter 3 — domain probe —
moved to Step 8 in the 2026-04-13 cost-simplification pass and now
runs post-Gate-1 on finalists only.)
```

- [ ] **Step 2: Rewrite Filter 2 block**

Find (from "**Filter 2 — Well-known brand collision**" through the end of the Filter 2 paragraph, before the "**Filter 3 — Primary TLD probe**" heading):

```markdown
**Filter 2 — Well-known brand collision (1 WebSearch per Filter-1
survivor).** Query: `"<name>" <category>`. If page-one results include
a recognizable brand in the category or adjacent category, eliminate.
Bar is "recognizable", not "exists somewhere".
```

Replace with:

```markdown
**Filter 2 — Well-known brand collision (1 WebSearch per Filter-1
survivor).** Query: `"<name>" <category>`. Read the **result
distribution pattern**, not individual hits:

- **Concentrated on one brand's domains in the same category** (e.g.,
  most first-page hits on `*.examplebrand.com` with an in-category
  product — the "Garmin time tracker" pattern) → **eliminate**.
  Record: dominant brand, domain, one-line evidence.
- **Scattered across unrelated domains** (no single brand dominates
  the target category) → **pass**.
- **Mixed: mostly scattered, with one or two adjacent-category hits**
  (e.g., a same-name product in an adjacent but non-competing space) →
  **pass**, note the adjacent hit in the validation record for CPTO
  awareness.

Pass bar: **no explicit conflict on product name + category.** Do not
eliminate on brand-shaped hits outside the product's category.
```

- [ ] **Step 3: Delete the entire Filter 3 block**

Find (from "**Filter 3 — Primary TLD probe**" through and including the final line "When ambiguous, default to `kept, verify manually` — loose safer than strict."):

```markdown
**Filter 3 — Primary TLD probe (1 RDAP + 1 HTTPS per Filter-2
survivor).**

- WebFetch `https://rdap.verisign.com/com/v1/domain/<name>` — Verisign
  RDAP for `.com`, returns structured JSON
- WebFetch `https://<name>.com` — HTTPS probe

Classify:
- **Available** (RDAP 404) → kept, strong positive
- **Parked / for-sale** (registered, HTTPS has parking markers: "for
  sale", "afternic", "sedo", GoDaddy) → kept, noted as buyable
- **Active site** (registered, HTTPS returns a real site) → eliminated,
  record site title if detectable

When ambiguous, default to `kept, verify manually` — loose safer than strict.
```

Replace with: *(nothing — delete the block entirely, leaving a blank line between Filter 2 and the next section `### 5. SMILE/SCRATCH ranking`)*

- [ ] **Step 4: Verify edits**

Run: `grep -c "WebFetch" squad/skills/product-naming/SKILL.md`

Expected: `0`

Run: `grep -n "Three filters\|Two filters\|Filter 3 — Primary TLD" squad/skills/product-naming/SKILL.md`

Expected: one match for "Two filters"; zero for "Three filters" and zero for "Filter 3 — Primary TLD".

- [ ] **Step 5: Commit**

```bash
git add squad/skills/product-naming/SKILL.md
git commit -m "refactor(squad): tighten Filter 2, remove broken Filter 3 from Step 4"
```

---

## Task 3: Step 8 — add DoH domain check and grid to Brand viability writeup

**Files:**
- Modify: `squad/skills/product-naming/SKILL.md` — Step 8 (`### 8. Brand viability writeup`)

- [ ] **Step 1: Rewrite Step 8 heading + body**

Find:

```markdown
### 8. Brand viability writeup

For each advancing finalist, write a short note to the conversation:

```markdown
### [Name] — [category]

**Positioning fit:** [1 sentence]
**SMILE strengths:** [strongest dimensions]
**SMILE weaknesses:** [any scoring <1, honest]
**Linguistic notes:** [pronunciation, syllable count, stress]
**Primary web presence:** [.com status from Filter 3]
**Trademark result:** [verbatim per jurisdiction]
**Known risks:** [phonetic overlap, buyable domain cost, etc.]
```
```

Replace with:

````markdown
### 8. Brand viability writeup + domain availability

Three sub-steps: per-finalist domain check, grid presentation, per-finalist note.

**8a — Domain availability (DoH).** For each advancing finalist, run a
DNS-over-HTTPS NS lookup across the fixed TLD set
`.com, .io, .ai, .app, .co, .dev, .so`:

```bash
curl -s 'https://dns.google/resolve?name=<finalist>.<tld>&type=NS'
```

One call per (finalist, tld) pair. For 3–5 finalists × 7 TLDs, that's
21–35 curl invocations total.

Parse the JSON response's `Status` field:
- `Status: 3` (NXDOMAIN) → **available** (record ✓)
- `Status: 0` with `Answer` array of NS records → **registered** (record ✗)
- `Status: 0` without `Answer` → **ambiguous** (record ?) — rare

See [naming-playbook.md](naming-playbook.md) → "Domain availability
implementation notes" for rationale (why DoH, why no HTTPS probe).

**8b — Domain availability grid.** Show the grid to CPTO before Gate 2
so cross-finalist tradeoffs are visible in one glance:

```markdown
## Domain availability

| Finalist | .com | .io | .ai | .app | .co | .dev | .so |
|---|---|---|---|---|---|---|---|
| [Name1] | ✓ | ✗ | ... |
| [Name2] | ... |
```

**8c — Per-finalist brand viability note.** For each advancing finalist,
write a short note to the conversation:

```markdown
### [Name] — [category]

**Positioning fit:** [1 sentence]
**SMILE strengths:** [strongest dimensions]
**SMILE weaknesses:** [any scoring <1, honest]
**Linguistic notes:** [pronunciation, syllable count, stress]
**Brand collision:** [verdict pattern from Filter 2 — scattered /
adjacent-hit noted / eliminated]
**Domain paths:** [available TLDs from the grid]
**Trademark result:** [verbatim per jurisdiction from Step 7]
**Known risks:** [phonetic overlap, trademark-ambiguous, thin TLD set, etc.]
```
````

- [ ] **Step 2: Verify edit**

Run: `grep -n "dns.google/resolve" squad/skills/product-naming/SKILL.md`

Expected: at least one match inside Step 8.

Run: `grep -n "Primary web presence" squad/skills/product-naming/SKILL.md`

Expected: zero matches (old field removed).

Run: `grep -n "Domain availability grid" squad/skills/product-naming/SKILL.md`

Expected: at least one match.

- [ ] **Step 3: Commit**

```bash
git add squad/skills/product-naming/SKILL.md
git commit -m "feat(squad): add DoH domain availability grid to Step 8"
```

---

## Task 4: Step 10 — update validation record shape in naming.md template

**Files:**
- Modify: `squad/skills/product-naming/SKILL.md` — Step 10 (`### 10. Write naming.md`), validation record subsection

- [ ] **Step 1: Rewrite Filters (automated) table + add Domain availability section**

Find:

```markdown
### Filters (automated)
| Filter | Result | Notes |
|---|---|---|
| Linguistic / phonetic (SCRATCH) | PASS | [brief note] |
| Brand collision search | PASS | [search query, page-one summary] |
| Primary TLD probe | [available / buyable / active] | [details] |

### Trademark (human-run, optional)
```

Replace with:

```markdown
### Filters (automated)
| Filter | Result | Notes |
|---|---|---|
| Linguistic / phonetic (SCRATCH) | PASS | [brief note] |
| Brand collision search | PASS | [verdict pattern: scattered / concentrated + query used] |

### Domain availability (finalists × TLDs)
| Finalist | .com | .io | .ai | .app | .co | .dev | .so |
|---|---|---|---|---|---|---|---|
| [Name1] | ✓ | ✗ | ... |

### Trademark (human-run, optional)
```

- [ ] **Step 2: Verify edit**

Run: `grep -n "Primary TLD probe" squad/skills/product-naming/SKILL.md`

Expected: zero matches.

Run: `grep -n "Domain availability (finalists × TLDs)" squad/skills/product-naming/SKILL.md`

Expected: one match in Step 10's template block.

- [ ] **Step 3: Commit**

```bash
git add squad/skills/product-naming/SKILL.md
git commit -m "refactor(squad): update naming.md validation record shape"
```

---

## Task 5: Process flow diagram — reflect Filter 3 removal + new writeup scope

**Files:**
- Modify: `squad/skills/product-naming/SKILL.md` — the Graphviz `digraph product_naming` block near the top

- [ ] **Step 1: Update filters node**

Find:

```
    filters [label="3 filters\nlinguistic / collision / TLD"]
```

Replace with:

```
    filters [label="2 filters\nlinguistic / collision"]
```

- [ ] **Step 2: Update writeup node to include domain grid**

Find:

```
    writeup [label="Brand viability\nper-finalist"]
```

Replace with:

```
    writeup [label="Brand viability\n+ domain grid\n(DoH on finalists)"]
```

- [ ] **Step 3: Verify edits**

Run: `grep -n "3 filters\|2 filters\|per-finalist\|domain grid" squad/skills/product-naming/SKILL.md`

Expected: matches for "2 filters" and "domain grid"; zero for "3 filters"; zero for "Brand viability\\nper-finalist" (the old label text).

- [ ] **Step 4: Commit**

```bash
git add squad/skills/product-naming/SKILL.md
git commit -m "docs(squad): update product-naming flow diagram"
```

---

## Task 6: Replace Filter 3 section in naming-playbook.md with DoH notes

**Files:**
- Modify: `squad/skills/product-naming/naming-playbook.md` — replace `## Filter 3 implementation notes` section (lines 182–208)

- [ ] **Step 1: Rewrite section**

Find (the entire section from `## Filter 3 implementation notes` through the last line before `## When pools are tight`):

```markdown
## Filter 3 implementation notes

For each Filter-2 survivor, run two WebFetch calls:

1. **RDAP query** — `https://rdap.verisign.com/com/v1/domain/<name>`
   - 404 → available
   - 200 → registered, parse the JSON for status flags
2. **HTTPS probe** — `https://<name>.com`
   - Connection refused / DNS failure → available (no DNS record)
   - Returns HTML → check for parking patterns

**Parking patterns to detect** (case-insensitive substring match):

- `for sale`
- `domain is for sale`
- `buy this domain`
- `afternic`
- `sedo`
- `dan.com`
- `godaddy auctions`
- `bodis.com`
- `parkingcrew`

If the page returns HTML and contains none of these patterns and looks
like a real site (has navigation, paragraphs, brand identity), classify
as `active site` and eliminate. When ambiguous, classify as
`kept, verify manually`.

```

Replace with:

````markdown
## Domain availability implementation notes

Domain availability runs in **Step 8 (post-Gate-1)** on finalists, not
as a pre-Gate-1 filter. It replaces the Filter 3 RDAP + HTTPS WebFetch
probe, which was removed in the 2026-04-13 cost-simplification pass.

For each `(finalist, tld)` pair, use Bash `curl` against Google DoH:

```bash
curl -s 'https://dns.google/resolve?name=<name>.<tld>&type=NS'
```

Parse the JSON response's `Status` field:

- `{"Status":3,...}` (NXDOMAIN) → **available** — domain not in DNS
- `{"Status":0,"Answer":[...]}` → **registered** — NS records exist
- `{"Status":0,...}` without `Answer` → **ambiguous** — rare; usually
  a registered-but-undelegated domain

Record as ✓ / ✗ / ? respectively in the grid.

**TLD set (fixed):** `.com, .io, .ai, .app, .co, .dev, .so`.
Hardcoded in the skill. Revisit if a future skill needs a different
set.

### Why DoH, not RDAP + WebFetch

The earlier mechanism called `WebFetch https://rdap.verisign.com/com/v1/domain/<name>`.
RDAP returns HTTP 404 as the positive "domain available" signal, but
WebFetch throws on 404 rather than returning the response. Every
available domain surfaced as a tool error — the mechanism failed in
the direction it was meant to celebrate. DoH always returns HTTP 200
with a JSON status code, so no tool-level errors, and the signal is
directly in the response body.

### Why no HTTPS probe (parked vs active)

The earlier mechanism also fetched `https://<name>.com` to distinguish
parked from active domains by scanning for parking markers ("for sale",
"sedo", etc.). That required fetching arbitrary candidate-controlled
sites. Candidate names come from a generative process, so any name
could map to an adversarial domain serving prompt-injection payloads,
pathological responses, or tracking pixels aimed at the model session.

We dropped the parked-vs-active distinction along with the risk.
"Available vs registered" is sufficient signal for the artifact; if the
CPTO wants to buy a parked domain, they check manually via the grid
showing registered TLDs.

````

- [ ] **Step 2: Verify edit**

Run: `grep -n "WebFetch\|RDAP\|parking markers" squad/skills/product-naming/naming-playbook.md`

Expected: zero matches for "parking markers"; references to "WebFetch" or "RDAP" acceptable only inside the explanatory "Why DoH" subsection as past-tense context.

Run: `grep -n "dns.google/resolve" squad/skills/product-naming/naming-playbook.md`

Expected: at least one match.

- [ ] **Step 3: Commit**

```bash
git add squad/skills/product-naming/naming-playbook.md
git commit -m "docs(squad): replace Filter 3 playbook with DoH notes"
```

---

## Task 7: Update product-naming-review for new validation record shape

**Files:**
- Modify: `squad/skills/product-naming-review/SKILL.md` — Pass 1 and Pass 2

- [ ] **Step 1: Update Pass 1 Item 5 (automated filters count)**

Find:

```markdown
5. **Validation record:** all 3 automated filters populated with a
   result and notes
```

Replace with:

```markdown
5. **Validation record:** both automated filters populated with a
   result and notes (Linguistic / phonetic SCRATCH, Brand collision
   search)
```

- [ ] **Step 2: Add Pass 1 Item 5b (domain availability grid)**

Find the end of Pass 1 Item 5 (the one modified in Step 1 above). Between the modified Item 5 and existing Item 6, add a new item:

Find:

```markdown
5. **Validation record:** both automated filters populated with a
   result and notes (Linguistic / phonetic SCRATCH, Brand collision
   search)
6. **Trademark table:** all 3 jurisdictions present (USPTO, WIPO,
   EUIPO) with a result (including `skipped`)
```

Replace with:

```markdown
5. **Validation record:** both automated filters populated with a
   result and notes (Linguistic / phonetic SCRATCH, Brand collision
   search)
6. **Domain availability grid:** a `Domain availability (finalists × TLDs)`
   section is present; it has a row per finalist and a cell per TLD
   (✓ / ✗ / ?); cells populated for every (finalist, TLD) pair
7. **Trademark table:** all 3 jurisdictions present (USPTO, WIPO,
   EUIPO) with a result (including `skipped`)
```

- [ ] **Step 3: Renumber remaining Pass 1 items**

The Pass 1 "Generation context" item was Item 7 before, now becomes Item 8. Find:

```markdown
7. **Generation context:** pool size, lens 2 adjacent domain,
   cross-lens hit, reruns
```

Replace with:

```markdown
8. **Generation context:** pool size, lens 2 adjacent domain,
   cross-lens hit, reruns
```

- [ ] **Step 4: Update Pass 2 Item 2 (filter-result contradiction)**

Find:

```markdown
2. **Filter results match claims.** If the artifact says "Primary TLD
   probe: available", the notes column should not contradict it.
```

Replace with:

```markdown
2. **Filter results match claims.** The Brand collision search row's
   Result column (PASS/ELIMINATED) should match the Notes column's
   verdict pattern description; no contradiction.
```

- [ ] **Step 5: Update Pass 2 Item 6 (active TLD handling → available TLD surfaced)**

Find:

```markdown
6. **Active TLD handled.** If `Primary TLD probe` shows `active`, the
   philosophy or usage rules must note the alternate TLD strategy or
   explain why the chosen name still works.
```

Replace with:

```markdown
6. **Chosen TLD path exists.** The chosen name must have at least one
   ✓ (available) cell in the domain availability grid, OR the
   philosophy / usage rules must explain which already-registered TLD
   the CPTO intends to acquire (and why the chosen name still works
   without an available path).
```

- [ ] **Step 6: Verify edits**

Run: `grep -n "Primary TLD probe\|all 3 automated filters" squad/skills/product-naming-review/SKILL.md`

Expected: zero matches.

Run: `grep -n "Domain availability grid\|domain availability grid" squad/skills/product-naming-review/SKILL.md`

Expected: at least two matches (Pass 1 item and Pass 2 item 6).

- [ ] **Step 7: Commit**

```bash
git add squad/skills/product-naming-review/SKILL.md
git commit -m "refactor(squad): update product-naming-review for new validation shape"
```

---

## Task 8: Update execution test assertions

**Files:**
- Modify: `tests/skill-execution/test-product-naming-execution.sh` — Test 7 assertions

- [ ] **Step 1: Replace Filter 3 assertion with domain availability grid assertion**

Find:

```bash
# Test 7: Has validation record with all 3 filters
echo ""
echo "Test 7: Validation record — automated filters..."
assert_contains "$NAMING_CONTENT" "Linguistic\|phonetic\|SCRATCH" "Filter 1 recorded" || exit 1
assert_contains "$NAMING_CONTENT" "Brand collision\|collision" "Filter 2 recorded" || exit 1
assert_contains "$NAMING_CONTENT" "TLD\|domain" "Filter 3 recorded" || exit 1
```

Replace with:

```bash
# Test 7: Has validation record with both filters and domain grid
echo ""
echo "Test 7: Validation record — automated filters + domain grid..."
assert_contains "$NAMING_CONTENT" "Linguistic\|phonetic\|SCRATCH" "Filter 1 recorded" || exit 1
assert_contains "$NAMING_CONTENT" "Brand collision\|collision" "Filter 2 recorded" || exit 1
assert_contains "$NAMING_CONTENT" "Domain availability" "Domain grid section present" || exit 1
assert_contains "$NAMING_CONTENT" ".com" "Grid shows .com column" || exit 1
assert_contains "$NAMING_CONTENT" ".io" "Grid shows .io column" || exit 1
```

- [ ] **Step 2: Verify edit**

Run: `grep -n "Filter 3 recorded" tests/skill-execution/test-product-naming-execution.sh`

Expected: zero matches.

Run: `grep -n "Domain grid section present" tests/skill-execution/test-product-naming-execution.sh`

Expected: one match.

- [ ] **Step 3: Commit**

```bash
git add tests/skill-execution/test-product-naming-execution.sh
git commit -m "test(squad): update product-naming execution test for new shape"
```

---

## Task 9: Run knowledge + triggering tests to validate skill still loads and activates

**Files:**
- Read-only: `tests/run-tests.sh`, `tests/skill-knowledge/*`, `tests/skill-triggering/*`

**Note:** knowledge + triggering tier only. Do NOT run the execution tier — that's the expensive one the user tests manually. Per memory: ask before running execution tests; for this plan, don't.

- [ ] **Step 1: Run the default fast-tier suite**

Run: `./tests/run-tests.sh 2>&1 | tee /tmp/product-naming-test.log`

Expected: all knowledge + triggering tests pass. Specifically watch the product-naming tests:
- `tests/skill-knowledge/test-product-naming.sh` — knowledge test
- `tests/skill-triggering/` entries starting with `product-naming` — should all pass

If anything fails with a 500/429 API error, per existing memory: stop, wait for service recovery, do not retry.

- [ ] **Step 2: Inspect log for product-naming-specific lines**

Run: `grep -n "product-naming" /tmp/product-naming-test.log`

Expected: PASS markers on all product-naming knowledge + triggering lines. No failures.

- [ ] **Step 3: If any fail, diagnose before proceeding**

A failure on the knowledge test after this plan likely means the skill's edited description or content no longer matches what the knowledge test expects. Read the failing test, compare to the edited skill, adjust the skill text (not the test) if the skill edit introduced a factual change the test should reflect — otherwise adjust the test expectation.

Do NOT "fix" the test by loosening assertions until the skill edit is confirmed correct.

- [ ] **Step 4: No commit needed for a passing run**

Tests pass → proceed. Tests fail → fix root cause, loop back through Task 9.

---

## Task 10: Manual smoke test handoff

Execution-tier automated testing is off-limits per user's cost constraint. The user runs a manual smoke test on their actual product brief.

- [ ] **Step 1: Notify user**

Write to the conversation:

```
Plan fully executed and committed. Manual smoke test:

1. In a Claude Code session with the squad plugin loaded and an
   approved brief at $product_home/product/brief.md, invoke the
   product-naming skill.

2. Expected behaviors to watch for:
   - Pre-Gate-1: Filter 2 WebSearches run (~20-25 candidates); no
     WebFetch calls at all.
   - Gate 1: shortlist presented without domain data.
   - Post-Gate-1: 3-5 finalists × 7 TLDs = 21-35 Bash curl calls to
     dns.google.
   - Pre-Gate-2: domain availability grid shown in the conversation.
   - naming.md: validation record has two automated filters (no
     Primary TLD probe row) and a Domain availability (finalists × TLDs)
     section with ✓/✗/? cells.

3. If anything looks wrong, report back with the specific step and
   observed output.
```

- [ ] **Step 2: Wait for user report**

Do not mark the plan complete until the user confirms the manual smoke test observed the expected behaviors.

---

## Self-Review

### Spec coverage

Each section of the spec mapped to a task:

| Spec section | Task |
|---|---|
| Change 1: Filter 3 mechanism (RDAP → DoH) | Task 3 (Step 8 rewrite), Task 6 (playbook) |
| Change 2: Filter 3 scope (multi-TLD) | Task 3 (Step 8), Task 4 (validation record), Task 6 (playbook) |
| Change 3: Filter 3 placement (→ post-Gate-1) | Task 2 (remove from Step 4), Task 3 (add to Step 8) |
| Change 4: Filter 2 interpretation tightened | Task 2 |
| Change 5: Domain availability grid | Task 3 (Step 8), Task 4 (artifact) |
| Change 6: Validation record shape | Task 4 |
| Change 7: allowed-tools | Task 1 |
| Process flow diagram update | Task 5 |
| Review skill alignment | Task 7 |
| Execution test assertion update | Task 8 |
| Security rationale (WebFetch drop) | Task 1 enforces it; Task 6 documents rationale in playbook |

No spec section is unmapped.

### Placeholder scan

No "TBD", "TODO", or "similar to" references. One research step in Task 1 Step 1 (verify exact `allowed-tools` syntax) — that's not a placeholder, it's a verification step with a clear decision point and two documented syntax options.

### Type / name consistency

- `Domain availability` section heading used identically in Task 3 (Step 8 grid), Task 4 (naming.md schema), Task 7 (review check), Task 8 (test assertion).
- TLD set `.com, .io, .ai, .app, .co, .dev, .so` identical in Task 3, Task 4, Task 6.
- DoH URL `https://dns.google/resolve?name=<name>.<tld>&type=NS` identical in Task 1 (allowed-tools), Task 3 (Step 8), Task 6 (playbook).
- Cell markers `✓ / ✗ / ?` consistent in Task 3, Task 4, Task 7.
- File paths absolute and consistent across all tasks.

No inconsistencies found.

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-04-13-product-naming-cost-simplification.md`. Two execution options:

**1. Subagent-Driven (recommended)** — I dispatch a fresh subagent per task, review between tasks, fast iteration.

**2. Inline Execution** — Execute tasks in this session using executing-plans, batch execution with checkpoints.

Which approach?
