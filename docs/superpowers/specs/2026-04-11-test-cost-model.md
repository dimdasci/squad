# Brainstorm: Test Cost Model Rethink

Date: 2026-04-11
Status: brainstorm (not ready for a plan — decisions pending)

## Problem

The squad test suite burns too much API budget to run casually. On
2026-04-11, shipping the product-naming skill pair triggered a five-hour
rate-limit rejection after combining a fast-tier run (~11 min wall
clock, 9 triggering tests + 4 knowledge test scripts) with two
execution-tier attempts (~10 min and ~stall respectively). The user
explicitly paused execution tier and asked to "rethink it after rate
will be renewed."

Cost symptoms:

- **Fast tier:** 11 min wall clock, scales linearly with skill count.
  Dominated by the triggering batch (6.6 min for 9 tests), which is
  ~25-45s per sequential `claude -p` call with no amortization.
- **Execution tier:** 5-15 min per skill, dominated by network-bound
  filter passes (WebSearch + WebFetch per candidate). Product-naming
  hit 35 WebSearches + 20 WebFetches before timeout.
- **Whole-suite runs** burn budget on skills you're not touching.
  Working on product-naming re-runs product-brief + architecture-record
  tests for no incremental coverage.

## Constraints

Two non-negotiables:

1. **No heavy parallelization.** Bursting parallel `claude -p` sessions
   spikes request rate in the opening seconds and trips 429s. Per user
   memory: stop on 429/500, don't retry.
2. **Cost-sensitive.** The current cadence is too expensive to run on
   every commit or every skill change. Needs to be justifiable per run.

## Proposals to decide between

Four options on the table, not mutually exclusive.

### Option 1: Per-skill test filter (`--skill NAME`)

Add a filter flag to `tests/run-tests.sh` that narrows every tier to
files matching the skill name prefix:

- **Knowledge:** `test-<name>.sh` only (one file instead of four)
- **Triggering:** `run-all.sh` accepts the skill arg, filters the
  `TESTS=()` array to rows whose first field starts with `<name>`
  (catches both the produce and review variants via prefix)
- **Execution:** `test-<name>-execution.sh` only

Estimated cost impact: fast tier drops from ~11 min to ~4 min per
skill-focused run. Execution tier drops from four slow tests to one.

**Dependency clarification** (resolved in the same conversation): the
filter only chooses which prompts/assertions to run. Claude's session
always loads the entire plugin — there's no "load only this skill"
flag in the CLI — so runtime invocations like product-naming's Step 11
call into product-naming-review naturally without needing a special
dependency declaration. Prefix matching handles today's paired-skill
convention; it would need upgrading if a skill ever invokes a sibling
whose name doesn't share the prefix.

**Files to change:**

- `tests/run-tests.sh` — parse `--skill`, thread into globs
- `tests/skill-triggering/run-all.sh` — accept filter arg

**Cost:** ~20-30 lines of bash, one commit. Reversible.

**Limitations:** saves budget per run but doesn't reduce the cost of
the tests themselves. A filtered run still burns real API.

### Option 2: Mock the network layer in execution tests

The execution tier's cost is dominated by WebSearch and WebFetch calls
that iterate over candidate pools. Filter 2 alone ran 35 WebSearches;
Filter 3 ran 20 WebFetches before timeout. These are network-bound and
non-deterministic.

Approach: introduce a mocking harness that intercepts WebSearch and
WebFetch at the test boundary and returns canned responses from a
fixtures directory. Keeps the skill logic under test (ranking,
filtering, artifact shape) while removing the network cost.

**Challenges:**

- Fixture maintenance — every new candidate pool needs fresh mocks
- Harness integration — the skill system doesn't currently expose a
  way to intercept tool calls from outside the session
- Fidelity gap — mocked tests don't catch real-world API changes
  (e.g., parking pattern evolution, RDAP format drift)

**Best for:** catching ranking/filter logic regressions cheaply on
every commit, while full execution tests become a rare cross-check.

### Option 3: Cheaper checkpoints instead of end-to-end

Break each execution test into smaller assertions that verify specific
steps without running the full pipeline:

- "Parallel dispatch test" — assert the 4-lens Task invocations fire,
  stub the subagents with trivial outputs, check dedup output shape
- "Filter 1 test" — give the skill a synthetic candidate pool, verify
  SCRATCH elimination produces expected survivors
- "Artifact shape test" — hand the skill a mock state at Step 10, verify
  the written `naming.md` has all required sections

Each checkpoint is ~1-2 min instead of 10-15 min, and they can run
independently. Loses the "real end-to-end integration" property, but
gains cheap per-commit verification.

**Best for:** iteration speed. Full end-to-end becomes a quarterly or
pre-release check.

### Option 4: Sampling strategy

Keep the current expensive tests but run them rarely — on release
cuts, not on every change. Day-to-day development uses the fast tier
only, plus manual smoke testing on a real project.

**Pros:** zero code change, matches how many teams already work
**Cons:** regressions in execution-only behavior (parallel dispatch,
full workflow) go undetected between samples

**Best for:** low-change-rate periods. Probably not sufficient during
active skill development.

## Recommendation for the next working session

Start with **Option 1** unconditionally — it's cheap, reversible, and
immediately reduces day-to-day cost without committing to anything
bigger. Then decide between Options 2 and 3 based on what you value:
Option 2 preserves end-to-end fidelity at the cost of fixture maintenance;
Option 3 trades fidelity for iteration speed. Option 4 is a fallback
if neither 2 nor 3 feels worth the investment.

Do NOT run the execution tier speculatively in the meantime. Per
existing memory: ask before running execution tests.

## Open questions

- Is there a Claude CLI or SDK hook for intercepting tool calls from
  outside the session? (Needed for Option 2 feasibility.)
- Does the rate limit reset model ever allow a pre-push "run all
  execution tests" gate without torching the budget for regular work?
- Should the knowledge test file structure change to one-file-per-skill
  for cleaner filtering, or is the current single-file-per-skill
  convention already adequate?
- How does the dependency test (`test-skill-dependencies.sh`) fit into
  the filter — always run, never run with a filter, or split into
  per-skill files?

## Not in scope

- Parallelizing the triggering tests (rejected — hits rate limits)
- Upgrading the `claude -p` harness itself (out of our repo's control)
- Changing the three-tier taxonomy (knowledge / triggering / execution
  is sound, the cost is inside the tiers, not in the structure)
