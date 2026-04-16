# Gstack Framework Analysis

Baseline assessment for building an adopted derivative framework.
Based on gstack v0.15.13.0 (commit 03973c2), MIT License, (c) 2026 Garry Tan.

---

## 1. The Promise (Gstack's Own Words)

> "Nine opinionated workflow skills that promise to transform a single AI
> assistant into a team of specialists — from founder-level product thinking
> to automated QA testing and one-command shipping."

The marketed value proposition:
- Role decomposition: separate specialists for planning, reviewing, QA, shipping
- Browser daemon: persistent headless Chromium for QA and design tasks
- Design system creation: DESIGN.md as single source of truth
- One-command workflows: `/ship`, `/qa`, `/review` replace manual multi-step processes
- Cross-model review: Codex as independent second opinion
- Operational learning: knowledge compounds across sessions

The framework positions itself as a "team of specialists" — implying handoffs,
shared context, and workflow continuity between roles.

---

## 2. What It Actually Is

Gstack is two things packaged together:

**A prompt library** — 36 markdown files (SKILL.md), each instructing Claude Code
to behave as a specific specialist. Skills are generated from `.tmpl` templates
at build time. There is no runtime, no SDK, no message bus. Each skill is an
independent document that Claude reads and follows step by step.

**A browser daemon** — a compiled Bun binary (~9,700 lines of TypeScript) that
gives Claude a persistent headless Chromium with sub-second command latency,
cookie import from macOS Keychain, and a ref system for AI-driven page interaction.
This is real engineering with real tests (10,200+ lines).

The "team of specialists" metaphor breaks down at handoffs. Each skill runs as
an independent `claude -p` subprocess with zero shared memory. The filesystem is
the only bridge between skills, and it's incomplete — not all skills participate
in the shared state protocols.

---

## 3. Top-Level Architecture

### Installation layout

```
~/.claude/skills/gstack/           # Global install (git clone)
├── {skill-name}/SKILL.md          # 36 skill prompts
├── browse/src/                    # Browser daemon source (9,700 lines TS)
├── browse/dist/browse             # Compiled browser binary (~58MB, arm64)
├── design/src/                    # Design binary source (2,900 lines TS)
├── design/dist/design             # Compiled design binary (~58MB, arm64)
├── bin/                           # 28 shell utilities
├── scripts/                       # Build tooling (gen-skill-docs, resolvers)
├── hosts/                         # Multi-host configs (Claude, Codex, Cursor, etc.)
├── ETHOS.md                       # Builder philosophy
└── setup                          # One-time build + symlink script
```

### Skill invocation

Claude Code's native skill system. User types `/qa` or `/ship`:
1. Claude Code looks up `~/.claude/skills/qa/SKILL.md`
2. Reads YAML frontmatter (name, description, allowed-tools)
3. Loads entire SKILL.md content as instructions
4. Claude follows those instructions step by step

No runtime process. No orchestrator. Skills are just markdown that Claude reads.

### Skill build pipeline

```
SKILL.md.tmpl        (human-written prose + {{PLACEHOLDERS}})
       |
gen-skill-docs.ts    (resolvers fill shared blocks from source code)
       |
SKILL.md             (committed, auto-generated)
```

Resolvers produce shared blocks: preamble (4 tiers), review methodology,
specialist dispatch, design binary discovery, learnings injection.
Multi-host support generates different SKILL.md per host (Claude, Codex, etc.).

### Browser daemon

```
Claude Code  -->  CLI (compiled Bun)  -->  Server (Bun.serve)  -->  Chromium
             $B snapshot -i          HTTP POST localhost:PORT        CDP
                                     Bearer token auth
```

- Persistent state: login once, stay logged in across commands
- Sub-second latency: first call ~3s, every call after ~100-200ms
- Ref system: @e1, @e2 address elements via ARIA tree, not DOM selectors
- Auto-lifecycle: starts on first use, 30min idle timeout, version auto-restart

### State and persistence

All state on filesystem under `~/.gstack/`:
- `config.yaml` — user preferences
- `sessions/$PPID` — active session markers (auto-cleanup 120min)
- `analytics/` — telemetry, skill usage, eureka moments
- `projects/{SLUG}/` — per-project: learnings, reviews, timeline, health, plans, checkpoints, designs

### The 36 skills by role

| Group | Skills | Count |
|-------|--------|-------|
| Product/Strategy | office-hours, plan-ceo-review, autoplan | 3 |
| Engineering | review, qa, qa-only, ship, investigate, cso, benchmark, plan-eng-review | 8 |
| Design | design-consultation, design-review, plan-design-review, design-html, design-shotgun | 5 |
| Shipping/Ops | land-and-deploy, canary, document-release, setup-deploy | 4 |
| Meta/Operations | checkpoint, health, learn, retro, codex, freeze, careful, guard | 8 |
| Browser/Setup | browse (root), open-gstack-browser, connect-chrome, setup-browser-cookies | 4 |
| Lifecycle | gstack-upgrade, unfreeze, devex-review, plan-devex-review | 4 |

---

## 4. The Real Value: Knowledge vs Discipline

### The core insight

The value of gstack is NOT in teaching Claude things it doesn't know. Claude
already knows SQL injection, race conditions, OWASP, design principles, and
every engineering best practice encoded in these skills.

The value is in **forcing Claude to follow disciplined processes it would skip
on its own**. Without explicit instructions, Claude defaults to:
- Agreeableness and confirmation bias on its own output
- Skipping checks it "already considered" during generation
- Not tracing data flows through shadow paths (nil, empty, error)
- Not verifying completeness against a plan
- Rubber-stamping its own work as "looks good"
- Not persisting state for the next session
- Not collecting evidence (screenshots, metrics) for claims

The right evaluation lens for every piece of skill content:
**"Does Claude reliably do this without being told?"**
If yes — cut it. If no — keep it. The discipline IS the product.

### What each role group contributes

**Product/Strategy skills** — well-curated methodology (YC partner questions, CEO
cognitive patterns, Bezos/Grove/Munger frameworks). The methodology itself is from
published sources. The value is: anti-sycophancy rules that prevent Claude from
defaulting to encouragement, forcing questions one-at-a-time with pushback,
structured design doc output that downstream skills can consume.

**Engineering skills** — standard checklists (SQL safety, race conditions, injection,
enum completeness) but explicitly enforced. Claude knows these items; it won't
reliably check each one against a diff without being told. The specialist dispatch
pattern (parallel subagents with fresh context) is a genuine architectural innovation.

**Design skills** — the strongest group. Self-contained with tangible output (DESIGN.md).
Plays to model strengths (synthesis and taste vs adversarial self-review). Honest
interaction loop (conversation, not gate). Strong guardrails (font blacklist, AI slop
anti-patterns, coherence validation).

**Shipping/Ops skills** — highest discipline value per line. Pre-merge readiness gates,
deploy strategy branching, baseline-aware canary monitoring, CHANGELOG protection,
cross-doc consistency. These are tasks where forgetting a step has real consequences.

**Meta/Operations skills** — hook-based enforcement (freeze/careful/guard) is the only
approach that actually constrains Claude at the platform level rather than asking
nicely. Health scoring with regression detection. Retro's session-aware metrics.

---

## 5. What Works Well

### Pattern: self-contained skills with tangible output

Design-consultation is the model. It runs a complete loop within a single session:
gather context, research, propose, preview, write DESIGN.md. No dependency on
prior skills, no downstream consumer needs intermediate state. The user sees
the output, confirms it, and the artifact is done.

### Pattern: honest interaction over performative gates

Design skills succeed because they don't simulate human judgment — they augment it.
Every phase asks the user to confirm or adjust. The comparison board with feedback
loop is a real human-in-the-loop workflow. Contrast with review skills that say
"CLEAR" on half-built features.

### Pattern: hook-based enforcement

Freeze, careful, and guard use Claude Code's PreToolUse hooks to actually block
tool invocations. This is platform-level constraint, not prompt-level persuasion.
The only reliable way to prevent Claude from doing something.

### Pattern: shipping discipline checklists

Land-and-deploy's pre-merge readiness gate (5 parallel checks before merge),
canary's baseline-aware delta alerting, document-release's auto/ask classification.
High consequence of failure + low tolerance for shortcuts = high discipline value.

### Pattern: office-hours to CEO-review handoff

The one place skill chaining works. Office-hours produces a design doc saved to
`~/.gstack/projects/$SLUG/`. CEO-review explicitly looks for it. If missing, offers
to run office-hours inline. Filesystem-based handoff with explicit discovery.

### The browser daemon

The only real engineering in the project. Persistent Chromium with sub-second
latency, ARIA-based ref system, cookie import, proper security model. Well-tested.
9,700 lines of source + 10,200 lines of tests.

---

## 6. What to Avoid

### Architectural gaps

**Skills don't chain.** Each skill runs as independent subprocess with zero shared
memory. The review log protocol exists (`gstack-review-log`/`gstack-review-read`)
but not all skills participate. `/qa` never writes to the shared review log. When
`/ship` reads it, QA results are invisible.

**Reviews rubber-stamp incomplete work.** The review system conflates correctness
with completeness. Plan completion audit is explicitly "INFORMATIONAL — does not
block the review." Specialists find bugs in written code but never check what should
exist but doesn't. Adaptive gating silences quiet specialists over time, reducing
coverage. No completeness gate.

**No artifact graph.** 5 different naming conventions across skills. No central
registry. Discovery via fragile `find + ls -t + head` patterns. No cleanup for
artifacts from abandoned branches. Unbounded growth of JSONL logs, plan files,
review reports, design artifacts.

**Work not pushed.** Ship's `git push` runs without exit-code validation. Workflow
unconditionally proceeds to create PR whether push succeeded or failed.

### Platform violations

Claude Code recommends SKILL.md under 500 lines. Every gstack skill violates this
by 2.5-5x:

| Skill | Lines | Over limit |
|-------|-------|------------|
| /ship | 2,543 | 5.1x |
| /plan-ceo-review | 1,837 | 3.7x |
| /office-hours | 1,714 | 3.4x |
| /review | 1,467 | 2.9x |
| /autoplan | 1,464 | 2.9x |
| /qa | 1,419 | 2.8x |

**Root causes of bloat:**
- Preamble duplication: 300-530 identical lines in every skill (telemetry, config,
  session tracking, voice, AskUserQuestion format, completeness principle, search
  philosophy, context recovery, plan mode rules, browse setup, learnings injection)
- No supporting files pattern: everything in one monolithic SKILL.md instead of
  splitting reference material into separate files loaded on demand
- No conditional loading: entire skill consumed whether all sections are needed or not
- No sub-agent stripping: sub-agents read full SKILL.md including irrelevant preamble

**The math:** Office-hours at 14,063 words is ~18,000-19,000 tokens consumed before
Claude does any work. Autoplan loading 4 review skills = 50,000+ tokens in skill
instructions alone.

### Self-review problem

Claude reviewing Claude's work is structurally biased. The same model that decided
"this is done" evaluates whether it's done. Checklists create an illusion of rigor,
but the model has the same blind spots in review mode as in build mode. The Codex
cross-model opinion is a workaround, not a solution.

### Overwhelming scope without organization

36 skills with no org chart. No defined interfaces between them. Each reinvents its
own context gathering. Duplicate responsibilities (ship does review, review does QA
scoping). No escalation paths. No shared definition of "done."

### YC marketing embedded in workflow

Office-hours skill contains a 300-line YC resource pool (34 videos/essays), tiered
founder plea ("GStack thinks you are among the top people who could do this"), and
YC application link with referral tracking. Functional distraction from the actual
product methodology.

---

## 7. Extractable Techniques

Genuinely novel patterns worth preserving in a derivative work:

### Specialist dispatch with fresh context (from /review)

Launch independent subagents for testing, security, performance, etc. Each gets
only the diff and their checklist — fresh context prevents confirmation bias.
Findings fingerprint-deduplicated and confidence-boosted on multi-specialist
agreement. This is an architectural pattern, not a prompt trick.

### Confidence calibration with display rules (from /review, /cso)

Every finding scored 1-10: 9-10 shown normally, 5-6 shown with caveat, 3-4
suppressed to appendix, 1-2 suppressed entirely. Prevents false positives
from drowning real issues.

### Test coverage as ASCII diagram (from /plan-eng-review)

Trace every codepath, build visual map marking TESTED/GAP/TENTATIVE, generate
test plan from gaps. Tests planned from structure, not invented reactively.

### Scope lock via freeze (from /investigate)

After forming root cause hypothesis, restrict file edits to affected module.
Hook-based enforcement prevents bug fix from becoming refactoring expedition.

### Test failure ownership triage (from /ship)

Classify failures as in-branch vs pre-existing. Different handling for each:
in-branch = STOP, pre-existing = triage (fix / TODO / skip) with solo vs
collaborative mode awareness.

### Baseline-aware delta alerting (from /canary)

Compare against stored baseline, not absolutes. 3 known errors staying at 3 = fine.
4th error = alert. Transient tolerance: only alert on patterns persisting across
2+ consecutive checks.

### Anti-sycophancy enforcement (from /office-hours)

Explicit bans on filler phrases ("that's an interesting approach"). Pushback
patterns showing BAD vs GOOD responses. Forcing questions one-at-a-time with
STOP between each. This measurably changes model behavior.

### Auto/ask classification (from /document-release)

Categorize every change as "auto-update" (factual: paths, counts, tables) or
"ask user" (narrative: philosophy, security, large rewrites). Explicit boundary
prevents both over-asking and silent overwriting.

### Filesystem boundary for cross-model (from /codex)

Always prepend "Do NOT read SKILL.md files" when sending prompts to other AI
models. Post-output scan for signs the model got distracted by skill files.
Hard-won lesson encoded as a rule.

### Hook-based enforcement (from /freeze, /careful, /guard)

PreToolUse hooks that block Edit/Write/Bash at the platform level. Not prompt
persuasion — actual tool invocation prevention. Safe exception list for
destructive commands (rm -rf node_modules is fine, rm -rf / is not).

---

## 8. License and Attribution

Gstack is MIT licensed. Derivative works are permitted with the requirement to
include the copyright notice:

> MIT License, Copyright (c) 2026 Garry Tan

Any derivative work using substantial portions must include this notice.
Methodology extracted and restructured into new skill files may fall under
"substantial portions" — include attribution to be safe.

---

## Summary

Gstack is a well-crafted prompt library with a good browser tool attached. It
brings genuine discipline to AI-assisted development. The methodology is mostly
curated from known sources (YC, OWASP, published engineering books), but the
packaging forces Claude to follow processes it would skip on its own.

The structural problems (no chaining, rubber-stamp reviews, no artifact graph,
token bloat, platform violations) are architectural, not cosmetic. They stem from
treating skills as monolithic documents rather than composable modules on a
platform designed for lightweight, on-demand loading.

A derivative work should:
1. Extract the discipline (checklists, enforcement rules, anti-sycophancy)
2. Restructure for platform compliance (< 500 lines, supporting files, conditional loading)
3. Fix the handoff problem (shared state protocol all skills participate in)
4. Add completeness gates (not just correctness)
5. Remove the marketing (YC pleas, founder signals, resource pools)
6. Keep the browser daemon as-is — it's good engineering

---

## Update 2026-04-16 — v0.16.0 through v0.18.0

Two weeks of upstream work (v0.15.13 → v0.18.0, 38 commits). Version
numbering now includes a fourth segment (v0.18.0.0). Skill count grew
from 36 to 38 (added `pair-agent`, `plan-devex-review`, `devex-review`;
the baseline enumeration was slightly off).

### Themes

**AI-workflow hardening trilogy** — three features aimed at making the
prompt library harder to bypass:

1. *Confusion Protocol* (b805aa01, v0.18.0) — a STOP gate injected into
   the preamble at tier >= 2, firing on "architectural decisions, data
   model changes, destructive operations, or contradictory requirements"
   but not routine coding. Framed as addressing "Karpathy failure mode
   #1 (wrong assumptions)".
2. *UX behavioral foundations* (23000672, v0.17.0) — Steve Krug's
   usability tests distilled into a `UX_PRINCIPLES` resolver shared
   across all four design skills; paired with a new `ux-audit` browser
   meta-command and a `snapshot --heatmap` flag for agent-driven
   UX analysis.
3. *Relationship closing tiers* (dbd7aee5, v0.16.2) — `office-hours`
   now reads `~/.gstack/builder-profile.jsonl` and selects one of four
   closing tiers (introduction / welcome-back / regular / inner-circle)
   based on session count.

**Security wave 3** (7e96fe29, v0.16.4) — 12 fixes from 7 contributors,
including symlink-bypass in `validateOutputPath`, shell-injection in two
bin/ scripts, cookie-path validation bypass, form-field redaction beyond
`type=password`, and session-file permissions. The browser daemon's
security model continues to harden; the "real engineering" judgment from
Section 5 is reinforced.

**AI-slop reduction** (c6e6a21d, v0.16.3) — selective error handling
utility module (`safeUnlink`, `safeKill`, etc.), replacing ~50
defensive try/catch sites in `server.ts`, `cli.ts`, `sidebar-agent`,
and `browser-manager`. Empty-catch count dropped from 22 to 2 in cli.ts.
A `bun run slop:diff` hook was also wired into `/review` as an advisory
(non-blocking) Step 3.5.

**Multi-host expansion** — GBrain and Hermes host configs added
(b805aa01), bringing host count to 10. A `GBRAIN_CONTEXT_LOAD` /
`GBRAIN_SAVE_RESULTS` resolver pair was added to four "thinking"
skills (office-hours, investigate, plan-ceo-review, retro) so agents
running on the gbrain host can do brain-first lookup / save-to-brain.
Suppressed to empty on other hosts.

**Infrastructure** — triggers field added to all 38 skill templates
(ddea3ad1) for GBrain's `checkResolvable()` router; gen-skill-docs
now emits a 100KB ceiling warning per SKILL.md; E2E tests stopped
writing into the user's real `~/.claude/skills/` (600b2237); Gemini
E2E scaled back to smoke test (9019f4c0).

### Addresses previously-identified weaknesses

*Partial — YC marketing embedded in workflow (Section 6).* Original
concern:

> Office-hours skill contains a 300-line YC resource pool (34
> videos/essays), tiered founder plea ("GStack thinks you are among
> the top people who could do this"), and YC application link with
> referral tracking.

dbd7aee5 tiers the closing so the full YC plea now fires only on
session 1; sessions 2–3 skip the plea and lead with recognition.
Partial because: the plea + 34-resource pool still ship in the skill,
still load into context on every invocation, and still activate
verbatim for first-time users. The fix reduces repeated exposure,
not payload size. File grew from 1,714 to 1,852 lines.

*Partial — self-review problem (Section 6).* Original concern:

> Claude reviewing Claude's work is structurally biased. The same
> model that decided "this is done" evaluates whether it's done.

b805aa01 wires `slop:diff` (a cross-tool scanner, not a model) into
`/review` Step 3.5 as advisory-only. The Confusion Protocol STOP gate
also adds an earlier ambiguity check. Partial because: slop:diff is
advisory and never blocks; Confusion fires on input ambiguity, not on
review-output over-confidence. The structural self-review bias is
unchanged.

*Not addressed — SKILL.md bloat (Section 6).* The bloat got worse,
not better:

| Skill               | Baseline (03973c2f) | Now (0.18.0) | Change |
|---------------------|--------------------:|-------------:|-------:|
| ship                | 2,543               | 2,567        | +24    |
| plan-ceo-review     | 1,837               | 1,873        | +36    |
| office-hours        | 1,714               | 1,852        | +138   |
| plan-devex-review   | n/a                 | 1,852        | new    |
| design-review       | (~1,640 est.)       | 1,766        | +126   |

Confusion Protocol and GBrain placeholders added ~19 lines to each
affected skill. The UX_PRINCIPLES resolver adds another resolver block.
A 100KB per-skill token ceiling was introduced as a warning, not a
hard limit. Platform guideline is still 500 lines; every major skill
is 3–5x over.

*Not addressed — skills don't chain / no artifact graph / reviews
rubber-stamp / work-not-pushed (Section 6).* No commits in this window
touched the shared review-log protocol, artifact registry, completeness
gates, or `git push` exit-code validation in `/ship`.

*Reinforces — self-contained skills pattern / design skills remain
strongest (Section 5).* UX behavioral foundations ground the
design-group strength in Krug/Redish/Jarrett instead of pure taste.
This is the one area where new work compounds the existing strength
rather than layering more discipline on top.

### Stale claims (annotated inline, not rewritten)

- Section 3 "The 36 skills by role" — count is now 38; `pair-agent`,
  `plan-devex-review`, `devex-review` added since baseline.
- Section 3 browser daemon TS line count (9,700) is likely higher now
  after TabSession extraction, AI-slop refactor, security wave 3, and
  the browser data platform commit (b73f3644). Baseline figure retained
  as a snapshot of 03973c2f; not re-measured.
- Section 6 office-hours bloat row (1,714 lines, 3.4x over limit) is
  now 1,852 lines / 3.7x over; bloat worsened after relationship-closing
  tiers were added.

### Signal for Squad

1. *The discipline-vs-bloat tradeoff hardens.* Gstack's path is to
   keep adding enforcement layers (Confusion Protocol, slop:diff,
   UX_PRINCIPLES, builder-profile tiers) as preamble injections.
   Every new safeguard inflates every SKILL.md. Squad's lightweight
   constraint (< 500 lines, supporting files, conditional loading)
   is the direct alternative, and the distance between the two
   approaches is now larger, not smaller.
2. *Long-lived per-user state is being invented ad hoc.* Gstack's
   `~/.gstack/builder-profile.jsonl` is a single-file append-only
   log driving multi-session behavior — a point solution for
   `office-hours` only. Squad's shared-artifact layer (env-var
   paths, 18 artifacts across 5 layers) is the more general answer
   to the same class of problem.
3. *Cross-model review stays advisory.* The self-review structural
   bias is still the hardest nut. Even with slop:diff wired in,
   gstack stops short of making cross-model or cross-tool checks
   blocking. Squad's produce+validate pair (where validate is a
   distinct skill with a distinct lens) remains a stronger structural
   answer than advisory-only additions.
4. *Hosts are the real extensibility surface.* Gstack keeps adding
   hosts (now 10) and now has a brain-awareness resolver pattern
   that could generalize. If Squad wants to interoperate, the
   declarative host config + resolver suppression pattern is the
   integration point.
