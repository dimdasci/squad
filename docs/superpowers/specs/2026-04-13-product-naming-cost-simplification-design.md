# Product-Naming Skill: Cost Simplification + Filter 3 Fix

Date: 2026-04-13
Status: design (ready for plan)
Scope: `squad/skills/product-naming/SKILL.md` and supporting playbook

## Problem

The `product-naming` skill, as shipped, has two issues:

1. **Filter 3 is broken.** The domain probe uses RDAP + HTTPS WebFetch.
   RDAP returns HTTP 404 as the positive "domain available" signal, but
   WebFetch throws on 404 rather than returning it as a response. So
   the mechanism fails in the direction it is supposed to celebrate —
   every available `.com` domain surfaces as a tool error, not a pass.
   Observed live: `attune`, `earshot` both errored out during manual
   test on 2026-04-13.

2. **WebFetch on candidate domains is a security hazard.** The skill
   currently calls `WebFetch https://<name>.com` on every Filter-2
   survivor to look for parking markers. These are arbitrary domains
   not controlled by us — a candidate name could map to an adversarial
   site that ships malicious content, tracking pixels, or prompt
   injection aimed at Claude. Running this at scale against pools of
   20-30 names is not defensible even if the 404 bug were fixed.

A third concern — cost — is partially real. The Filter 3 WebFetch
calls (~20 per run) burn budget for little signal. The Filter 2
WebSearch calls (~25 per run) are **not** a cost problem and carry
real signal when interpreted correctly (see "What we validated").

## Goals

- Remove the Filter 3 bug by replacing RDAP+WebFetch with a mechanism
  that actually works.
- Remove WebFetch from the skill entirely — the tool's fetch-arbitrary-
  sites model is incompatible with operating on adversarial-controllable
  inputs (candidate domains).
- Keep Filter 2 WebSearch in place. It is the right filter, running at
  the right time, on the right inputs.
- Give the CPTO better cross-finalist visibility at Gate 2 via a
  multi-TLD domain availability grid.

## Non-goals

- No change to the 4-lens parallel dispatch, dedupe pipeline, SMILE
  rubric, SCRATCH filter, cross-lens bonus, Gate 1 / Gate 2 ceremony,
  trademark handoff, `product-naming-review` pair, or CPTO approval
  flow. The skill structurally works.
- No change to Step 2 positioning extract-plus-confirm.
- No refactor of the overall 13-step flow. Step count stays the same;
  Step 4 (Filter 3) changes mechanism; Step 8 (Brand viability writeup)
  gains the domain grid; Step 10 (Write naming.md) gains a validation
  record section for the grid.

## What we validated in this brainstorm

**DoH works where RDAP+WebFetch does not.** Google DNS-over-HTTPS at
`https://dns.google/resolve?name=<name>.<tld>&type=NS` always returns
HTTP 200 with a JSON body. `Status: 3` (NXDOMAIN) signals the domain
is not in DNS → available. `Status: 0` with an `Answer` array of NS
records signals registered. Tested on 35 lookups (5 names × 7 TLDs)
during the brainstorm — zero errors.

**Bash curl is the right transport, not WebFetch.** WebFetch is being
removed from the skill's allowed-tools. The test agent used
`curl -s 'https://dns.google/resolve?...'` via Bash and returned clean
results. DoH via a known Google endpoint is not "fetching a random
site" — it's a trusted API, same spirit as calling any other
deterministic service.

**Filter 2 WebSearch is high-signal when distribution is the signal.**
Compared empirically:
- `"Garmin" time tracker` — 9 of 10 hits on `*.garmin.com` including a
  Garmin-shipped "Time Tracker" app. Clear collision.
- `"Attune" / "Sonara" / "Audenza" time tracker` — results scattered
  across unrelated domains (WoW addon, timezone pages, homeware). No
  brand dominates the category.

Pattern reading is cheap: concentrated results on one brand's domains
in the target category → collision → eliminate. Scattered results
across unrelated domains → no collision → pass. Adjacent-category hits
(e.g., Sonara USA as a job-tracker) noted but not eliminated.

## Changes

### Change 1: Filter 3 mechanism — RDAP+WebFetch → DoH via Bash curl

**Current (Step 4, Filter 3):**
```
- WebFetch https://rdap.verisign.com/com/v1/domain/<name>
- WebFetch https://<name>.com
```

**Replacement:**
```
- Bash: curl -s 'https://dns.google/resolve?name=<name>.<tld>&type=NS'
```

One Bash call per (name, tld) pair. JSON parsed inline. No WebFetch.

Classification collapses from three states (available / parked / active)
to two (available / registered) because the parking-vs-active
distinction required an HTTPS fetch of the candidate domain, which we
are no longer doing.

### Change 2: Filter 3 scope — single-TLD → multi-TLD

**Current:** `.com` only.

**Replacement:** hardcoded TLD set `.com, .io, .ai, .app, .co, .dev, .so`.

Rationale: DoH is cheap enough (~50ms per call, no rate limits of
concern at our volume) that checking 7 TLDs per finalist is trivial
overhead. Gives the CPTO richer choices at Gate 2 and surfaces the
full alternative space in the artifact.

TLD set hardcoded in SKILL.md for now. Configurable via plugin config
if a later skill needs different TLDs; not built as configurable on
first pass.

### Change 3: Filter 3 placement — pre-Gate-1 → post-Gate-1

**Current:** Filter 3 runs in Step 4 on every Filter-2 survivor
(typically 15-25 candidates after Filter 2 has narrowed).

**Replacement:** Filter 3 moves to a new sub-step within Step 8
("Brand viability writeup"), running on the 3-5 finalists only.

Rationale: the automated filter tier shouldn't eliminate names based on
domain state before CPTO has seen the shortlist. Domain availability
is input to Gate 2 (final pick), not Gate 1 (shortlist). Running it on
finalists also cuts call volume: 3-5 × 7 TLDs = 21-35 DoH calls instead
of ~20 single-TLD WebFetches pre-Gate-1.

Pre-Gate-1 narrowing becomes: Filter 1 (SCRATCH, free) → Filter 2
(brand collision WebSearch, ~25 calls) → SMILE rank. Domain state not
consulted.

### Change 4: Filter 2 interpretation rule tightened

**Current (Step 4, Filter 2):**
> If page-one results include a recognizable brand in the category or
> adjacent category, eliminate.

**Replacement:**
> **Pass rule: no explicit conflict on product name + category.** Read
> the result distribution. If results are scattered across unrelated
> domains (no single brand dominates the category), pass. If a
> recognizable brand in the **same category** dominates the first-page
> results (high concentration on one brand's domains with active
> products in-category), eliminate. Adjacent-category hits are noted
> in the validation record but do not eliminate.

Tightening: eliminates only on same-category dominance, not on any
brand-shaped hit anywhere. Matches how the result distribution
actually signals — concentrated vs scattered.

Elimination reason recorded per eliminated candidate: "dominant brand
in category — [domain] — [1-line evidence]".

### Change 5: Domain availability grid at Gate 2 and in the artifact

Post-Gate-1, after DoH checks on finalists × TLDs, Step 8 produces a
grid as part of the Brand Viability Writeup, shown to CPTO before
Gate 2:

```markdown
## Domain availability

| Finalist | .com | .io | .ai | .app | .co | .dev | .so |
|---|---|---|---|---|---|---|---|
| Attune   | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |
| Audira   | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ |
| Audivo   | ✗ | ✗ | ✓ | ✗ | ✓ | ✓ | ✓ |
| Sonara   | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ✓ |
| Audenza  | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
```

Legend: ✓ = available (DoH NXDOMAIN), ✗ = registered (DoH has NS), ? =
DoH returned Status 0 with no Answer array (rare, treat as ambiguous).

The grid lives in `naming.md`'s validation record (see Change 6), not
only in the conversation. Future rebrands can see which alternatives
had room at decision time.

### Change 6: Validation record shape in naming.md

**Remove** the "Primary TLD probe" row from the Filters (automated)
table — the mechanism it described is gone.

**Add** a new top-level subsection "Domain availability (finalists ×
TLDs)" showing the grid from Change 5.

**Revised shape:**

```markdown
## Validation record

### Filters (automated)
| Filter | Result | Notes |
|---|---|---|
| Linguistic / phonetic (SCRATCH) | PASS | [brief note] |
| Brand collision search | PASS | [verdict pattern: scattered / concentrated + query used] |

### Domain availability (finalists × TLDs)
| Finalist | .com | .io | .ai | .app | .co | .dev | .so |
|---|---|---|---|---|---|---|---|
| ... | ✓ | ✗ | ... |

### Trademark (human-run, optional)
| Jurisdiction | Result | Notes |
| USPTO | clear / conflict / ambiguous / skipped | ... |
| WIPO | ... | ... |
| EUIPO | ... | ... |

### Generation context
- Pool size: [actual, post-dedupe]
- Lens 2 adjacent domain: [domain seed for this run]
- Cross-lens hit: [yes/no]
- Reruns: [N]
```

### Change 7: `allowed-tools` front matter

**Current:**
```yaml
allowed-tools: Task WebSearch WebFetch Bash(sh /tmp/naming-dedup.sh)
```

**Target:** WebFetch removed. Bash allowlist broadened to permit two
command patterns: the existing dedup script, and a DoH curl call
targeting `dns.google`.

The exact allow-list syntax (glob pattern for curl URL, comma vs
separate `Bash(...)` clauses) is verified against Claude Code docs
during implementation. The intent is: deny arbitrary `curl`, permit
only curl against `https://dns.google/resolve`.

## Revised flow

Step numbers unchanged; content of Steps 4 and 8 changed; Step 10
artifact shape updated.

```
1. Read existing context                       [unchanged]
2. Positioning brief                           [unchanged]
3. Generate candidate pool (4 lenses + dedupe) [unchanged]
4. Automated filter pass                       [Filter 3 removed from here]
   - Filter 1: SCRATCH linguistic (free)
   - Filter 2: Brand collision WebSearch (interpretation rule tightened)
5. SMILE ranking → top 12                      [unchanged]
6. Present shortlist (CPTO Gate 1)             [unchanged]
7. Trademark search handoff (optional)         [unchanged]
8. Brand viability writeup                     [+ DoH domain check + grid]
   - For each advancing finalist:
     - Run DoH NS-lookup across TLD set (Bash curl)
     - Build per-finalist availability row
   - Show full grid to CPTO before Gate 2
9. Present finalists (CPTO Gate 2)             [unchanged]
10. Write naming.md                            [validation record shape updated]
11. Independent review                         [unchanged]
12. Address findings                           [unchanged]
13. Request CPTO approval                      [unchanged]
```

## Cost model before vs after

| Phase | Current | Proposed |
|---|---|---|
| Filter 2 (WebSearch) | ~25 calls pre-Gate-1 | ~25 calls pre-Gate-1 |
| Filter 3 (network) | ~20 WebFetches pre-Gate-1 (many erroring on 404) | 21-35 Bash curl DoH calls on finalists only |
| Post-Gate-1 network | 0 | DoH calls above |
| **Paid calls (WebSearch + WebFetch)** | **~25 + ~20 = ~45** | **~25 + 0 = ~25** |
| **Broken calls** | ~10-15 (404 errors on available domains) | 0 |

Paid call reduction is modest (~45% fewer), but all remaining paid
calls are WebSearches, which we validated as high-signal. The broken
calls — the worst category, where we paid for a failure — go to zero.

## Security rationale (WebFetch drop)

WebFetch lets the skill fetch the HTML at arbitrary candidate domains.
Candidate names come from a generative LLM — in principle they could
be steered, collided, or squatted against. A malicious actor who
registers `<likely-generated-name>.com` with hostile content could:

- Return a prompt-injection payload in the HTML body, attempting to
  redirect the model's behavior
- Serve content that looks like "parking" to exfiltrate the fact that
  Claude is evaluating this name
- Serve large or pathological responses designed to consume context

The original design accepted this risk for the parking-vs-active
distinction. We are cutting that feature and the risk together. Domain
availability (binary: registered or not) is sufficient signal for the
artifact; parking state is not worth the attack surface.

DoH via Bash curl to `dns.google` is not equivalent risk — it's a
trusted Google API returning structured JSON, same profile as any
other deterministic service call.

## Open questions

None blocking. Noted for post-implementation:

- Should the DoH TLD set be configurable via plugin config rather than
  hardcoded? Revisit if a future skill (or a user) needs different
  TLDs. Not worth building before the need appears.
- Should `product-naming-review` check the grid's completeness (all
  finalists × all TLDs populated)? Likely yes — cheap addition to the
  review checklist, deferred to the implementation plan.

## Not in scope

- Rethinking SMILE, SCRATCH, parallel dispatch, or any structural
  element of the skill. The user's position, validated in the
  brainstorm: the skill itself works; only the network-bound mechanisms
  needed the rethink.
- Cutting `product-naming-review`. The review pair stays; the precedent
  for produce/validate pairs stays intact.
- Test infrastructure changes. The separate test-cost-model brainstorm
  (2026-04-11) covers that thread.
