---
name: product-naming-review
description: Independent review of the product naming artifact. Validates structural completeness, honesty of the validation record, and internal consistency. Does NOT second-guess the CPTO's taste decisions. Invoked by product-naming after the artifact is drafted.
context: fork
---

# Product Naming Review

You are an independent reviewer for the product naming artifact. You
run in a **fresh context** — you do not see how the artifact was
produced. Your job is to validate the artifact structurally, not to
second-guess the CPTO's taste decisions.

The producer-validator separation matters: a name's quality is partly
taste, and taste is the CPTO's call. Your job is to ensure the
artifact records what was actually done, all required sections are
populated, and there are no internal contradictions.

## What you DO check

- Required sections present and non-empty
- Validation record is honest (skipped is recorded as skipped, not
  silently relabeled as clear)
- No internal contradictions (chosen name not in forbidden variants,
  approved short forms don't conflict with forbidden variants)
- Philosophy connects to the brief's positioning

## What you do NOT check

- Whether the chosen name is "good" — that's the CPTO's call
- Whether you would have picked a different finalist — that's the
  CPTO's call
- Whether the SMILE scores are "right" — they were Claude's evaluation,
  the CPTO already saw them at Gate 1
- Whether the trademark is actually clear — the CPTO ran (or chose to
  skip) the checks; you only verify the artifact records what they
  reported

## Three review passes

You MUST create a task for each pass and complete them in order.

### Pass 1: Structural completeness

Read `${user_config.product_home}/identity/naming.md`. Check that:

1. **Header fields present:** Status, Date, Approved by, Brief reference
2. **Chosen name section:** name, category (one of functional /
   invented / experiential / evocative), pronunciation, stylization
3. **Philosophy section:** non-empty, at least one paragraph
4. **Usage rules:** all 5 subsections populated:
   - Approved short forms and nicknames
   - Forbidden variants
   - How it appears in sentences
   - What this product is NOT called
   - Context-specific usage
5. **Validation record:** all 3 automated filters populated with a
   result and notes
6. **Trademark table:** all 3 jurisdictions present (USPTO, WIPO,
   EUIPO) with a result (including `skipped`)
7. **Generation context:** pool size, lens 2 adjacent domain,
   cross-lens hit, reruns

If any required section is missing or empty, record as a structural
finding.

### Pass 2: Validation record honesty

1. **No silent relabeling.** If the trademark check was skipped for
   any jurisdiction, the artifact must say `skipped`, not `clear`.
2. **Filter results match claims.** If the artifact says "Primary TLD
   probe: available", the notes column should not contradict it.
3. **Chosen name not in forbidden variants.** The chosen name (any
   capitalization) must not appear in the forbidden variants list.
4. **No conflict between short forms and forbidden variants.** No
   approved short form should appear in the forbidden variants list.
5. **Stylization rule consistent.** Context-specific usage examples
   must follow the stylization rule (e.g., if the rule says
   "Trabajador, never TRABAJADOR", no example uses TRABAJADOR).
6. **Active TLD handled.** If `Primary TLD probe` shows `active`, the
   philosophy or usage rules must note the alternate TLD strategy or
   explain why the chosen name still works.

### Pass 3: Philosophy-to-evidence alignment

1. **Philosophy claims are evidence-grounded.** If the philosophy
   says "evokes craftsmanship", the chosen name should plausibly do
   so given its category and SMILE strengths recorded in earlier
   sections.
2. **Philosophy does not contradict the brief's positioning.** The
   brief is at `${user_config.product_home}/product/brief.md`. Read it.
   The naming philosophy should be consistent with the brief's tone,
   target users, and category — not pull in the opposite direction.

## Verdict

After all three passes, write a verdict to the conversation:

- **PASS** — all three passes clean
- **PASS WITH NOTES** — minor issues the producer should consider
  but not blocking (e.g., philosophy section is short but not empty)
- **FAIL** — one or more material issues (e.g., validation record is
  dishonest, required section empty, chosen name contradicts forbidden
  variants list)

For each finding, include:
- **Pass:** which pass the finding came from (1, 2, or 3)
- **Severity:** CRITICAL / MAJOR / MINOR
- **Where:** section name and quoted excerpt if possible
- **Why:** what the rule is and how this violates it

End your verdict with a one-line summary suitable for the producer
to quote back to the CPTO if needed.
