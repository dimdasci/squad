# Skill Implementation Comparison: Superpowers vs Gstack

Review against Anthropic's official Claude Code skill authoring guidance.

---

## 1. Anthropic's Key Requirements (Summary)

From `anthropic-best-practices.md` (Anthropic's published guidance):

| Requirement | Detail |
|-------------|--------|
| **Conciseness** | Context window is shared; only add what Claude doesn't already know |
| **SKILL.md < 500 lines** | Split into reference files beyond this |
| **Progressive disclosure** | SKILL.md = overview + pointers; reference files loaded on demand |
| **Frontmatter** | `name` (64 char max) + `description` (1024 char max), nothing else |
| **Description in 3rd person** | Triggers discovery; includes WHEN to use, not just WHAT |
| **References one level deep** | No SKILL.md → file A → file B chains |
| **Degrees of freedom** | High/medium/low specificity matching task fragility |
| **Naming** | Gerund form preferred (verb + -ing) |
| **Executable scripts** | Prefer execution over context loading; output consumes tokens, code doesn't |
| **Evaluation-first** | Test without skill, identify gaps, write minimal skill, iterate |
| **No time-sensitive info** | Avoid dates, version-gated instructions |
| **Consistent terminology** | Pick one term, use it throughout |

---

## 2. Frontmatter Compliance

### Anthropic spec

```yaml
---
name: skill-name        # 64 char max
description: ...        # 1024 char max, 3rd person, includes triggers
---
```

Two fields only. That's it.

### Superpowers

```yaml
---
name: test-driven-development
description: Use when implementing any feature or bugfix, before writing implementation code
---
```

**Compliant.** Two fields, gerund-adjacent naming, description focused on trigger
conditions. The `using-superpowers` CSO principle (description = WHEN, not WHAT)
directly aligns with Anthropic's guidance.

One deviation: descriptions use second person ("Use when...") rather than third
person ("Used when implementing..." or "Enforces TDD when implementing...").
Minor, but technically against the spec.

### Gstack

```yaml
---
name: ship
preamble-tier: 4
version: 1.0.0
description: |
  Ship workflow: detect + merge base branch, run tests, review diff, bump VERSION,
  update CHANGELOG, commit, push, create PR. Use when asked to "ship", "deploy",
  "push to main", "create a PR", "merge and push", or "get it deployed".
  Proactively invoke this skill (do NOT push/PR directly) when the user says code
  is ready, asks about deploying, wants to push code up, or asks to create a PR. (gstack)
allowed-tools:
  - Bash
  - Read
  - Write
  ...
---
```

**Non-compliant in multiple ways:**

1. **Extra frontmatter fields** — `preamble-tier`, `version`, `allowed-tools` are
   custom extensions not in the Anthropic spec. Claude Code ignores unknown frontmatter
   fields, so they're dead weight in the YAML but potentially confuse skill parsers
   on other platforms.

2. **Description too verbose** — The multiline description duplicates the WHAT (workflow
   steps) and the WHEN (trigger phrases). Anthropic says description is for discovery,
   not for workflow summary. Superpowers' CSO principle explicitly warns against this:
   Claude may follow the description instead of loading the full skill.

3. **Description includes behavioral instruction** — "Proactively invoke this skill
   (do NOT push/PR directly)" is a routing instruction embedded in metadata. This
   belongs in the skill body or in CLAUDE.md routing rules, not in the description
   field that's loaded into every session's system prompt.

4. **Brand tag `(gstack)`** — Appended to every description. Consumes tokens in every
   session whether or not the skill is triggered.

---

## 3. SKILL.md Body Size

### Anthropic recommendation: < 500 lines

| Skill | Superpowers | Lines | Gstack | Lines (est.) |
|-------|-------------|-------|--------|-------------|
| TDD | test-driven-development | 371 | — | — |
| Debugging | systematic-debugging | 296 | investigate | ~800+ |
| Shipping | finishing-a-dev-branch | 200 | ship | ~1,200+ |
| Design | brainstorming | 164 | design-consultation | ~600+ |
| Review | requesting-code-review | 105 | review | ~900+ |
| Meta | using-superpowers | 117 | root SKILL.md | ~2,000+ |
| Skill authoring | writing-skills | **655** | — | — |

**Superpowers:** 13 of 14 skills under 500 lines. One violation: `writing-skills`
at 655 lines (ironic — the skill that teaches token efficiency exceeds the budget).
Average: ~264 lines per SKILL.md.

**Gstack:** Every skill includes the shared preamble (~100 lines of bash) plus
the shared voice/routing/telemetry/completeness sections (~300 lines). Before any
skill-specific content begins, ~400 lines are already consumed. The ship skill
body alone exceeds 1,200 lines. The root SKILL.md (browser + routing) exceeds
2,000 lines. Every skill is 2-5x over the 500-line recommendation.

### Why this matters

Anthropic's guidance is specific: "once Claude loads [SKILL.md], every token
competes with conversation history and other context." Large skills push out
working memory. The recommendation isn't arbitrary — it's based on observed
degradation in instruction-following as context fills.

Gstack's approach is to front-load everything: voice rules, telemetry prompts,
routing tables, completeness philosophy, upgrade checks, context recovery —
all in every skill. This trades token efficiency for guaranteed availability
of framework behavior.

Superpowers keeps skills focused on one concern. The tradeoff is that
cross-cutting concerns (voice, formatting, routing) must be handled elsewhere
(hooks, CLAUDE.md, or the meta-skill).

---

## 4. Progressive Disclosure

### Anthropic pattern

```
SKILL.md        → overview + pointers to reference files
reference.md    → loaded on demand when needed
scripts/        → executed, not loaded into context
```

One level deep. SKILL.md points to files; files don't point to other files.

### Superpowers

```
systematic-debugging/
├── SKILL.md                    # 296 lines — overview + technique pointers
├── root-cause-tracing.md       # Loaded when tracing needed
├── defense-in-depth.md         # Loaded when validation pattern needed
├── condition-based-waiting.md  # Loaded for async test patterns
└── find-polluter.sh            # Executed, not loaded
```

**Good alignment.** SKILL.md is the overview, supporting files are one level deep,
and the shell script is for execution. The `@reference-file.md` convention in
skill bodies tells Claude to read when needed.

```
subagent-driven-development/
├── SKILL.md                          # 277 lines — orchestration logic
├── implementer-prompt.md             # Template for subagent dispatch
├── spec-reviewer-prompt.md           # Spec compliance prompt
└── code-quality-reviewer-prompt.md   # Quality review prompt
```

**Also good.** The reviewer prompts are templates passed to subagents, not
reference material Claude needs to internalize. They're read, filled in, and
dispatched — effectively "executed" rather than studied.

### Gstack

```
ship/
└── SKILL.md     # Everything in one file: preamble, voice, routing,
                 # workflow steps, decision trees, AskUserQuestion
                 # formatting, completion protocol, telemetry
```

**No progressive disclosure.** Each skill is a single monolithic SKILL.md with
everything inlined. There are no supporting reference files. The browse skill
has a separate directory for source code, but that's the binary — not skill
reference material.

The root SKILL.md does include the browser command reference, which could be
a separate reference file loaded only when browser interaction is needed.
Instead, it's loaded into every `/gstack` session.

The template system (`SKILL.md.tmpl` → generated `SKILL.md`) is a build-time
optimization, not a runtime progressive disclosure mechanism. All generated
content is inlined at build time.

---

## 5. Executable Code vs Prose

### Anthropic guidance

> "Scripts executed efficiently: Utility scripts can be executed via bash
> without loading their full contents into context. Only the script's output
> consumes tokens."

Prefer scripts for deterministic operations. Don't make Claude generate code
when a pre-made script would be more reliable.

### Superpowers

Almost entirely prose. The only executable components are:
- `find-polluter.sh` in systematic-debugging (test polluter detection)
- The brainstorm visual companion server scripts
- The `session-start` hook script

Skills are behavioral guidance, not operational automation. When a skill says
"run tests," it means the project's test command — not a skill-provided script.

This is appropriate for methodology skills. TDD enforcement doesn't need a
script; it needs Claude to follow a process. But it means Superpowers can't
solve problems that require deterministic execution.

### Gstack

Heavy executable code integration:
- 80+ line bash preamble in every skill (session tracking, telemetry, config)
- 28 shell utilities in `bin/` (gstack-config, gstack-slug, gstack-timeline-log, etc.)
- Browser daemon binary (compiled Bun, 9,700 lines TypeScript)
- Design binary (compiled Bun, 2,900 lines TypeScript)
- Context recovery scripts reading project state

Gstack follows Anthropic's "solve, don't punt" principle aggressively — it
ships compiled binaries for browser automation and design generation. But the
preamble bash block is **loaded into context, not just executed**. The preamble
runs first, but its ~100 lines of shell are parsed by Claude as part of the
skill content, consuming tokens even though the output is what matters.

A more aligned approach would put the preamble logic in an external script
and have SKILL.md say "Run `bin/gstack-preamble.sh` and use the output."

---

## 6. Degrees of Freedom

### Anthropic framework

- **High freedom**: Multiple valid approaches, context-dependent decisions
- **Medium freedom**: Preferred pattern with acceptable variation
- **Low freedom**: Fragile operations requiring exact sequence

### Superpowers

Discipline skills (TDD, debugging, verification) are explicitly **low freedom**:

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

```
Violating the letter of the rules is violating the spirit of the rules.
```

This is appropriate. These skills enforce non-negotiable processes where
deviation causes measurable failures. The rationalization counter tables exist
precisely because Claude tries to exercise freedom where none should exist.

Workflow skills (brainstorming, writing-plans) are **medium freedom**: they
prescribe steps but allow judgment in how to execute each step.

The meta-skill (using-superpowers) is **high freedom**: "check if any skill
applies" leaves routing judgment to Claude.

**Good calibration** — freedom matches fragility.

### Gstack

Mixed signals. The ship skill prescribes an exact sequence (detect base branch,
run tests, review diff, bump version, update changelog, commit, push, PR) with
**low freedom** in steps. But then embeds **high freedom** voice instructions:

```
Lead with the point. Say what it does, why it matters, and what changes for
the builder. Sound like someone who shipped code today...
```

The voice/personality section takes ~100 lines of skill content to express
stylistic preferences that don't affect correctness. This is high-freedom
guidance consuming low-freedom token budget.

The completeness principle ("Boil the Lake") adds medium-freedom guidance
to every skill, but it's an editorial philosophy, not an operational constraint.

---

## 7. Description Field: Discovery vs Instruction

### Anthropic guidance

> "The description is critical for skill selection: Claude uses it to choose
> the right Skill from potentially 100+ available Skills."

Description = discovery metadata. Not workflow steps. Not behavioral directives.

### Superpowers (CSO-aligned)

```yaml
description: Use when implementing any feature or bugfix, before writing implementation code
```

Trigger conditions only. Doesn't mention RED-GREEN-REFACTOR, Iron Laws, or
any workflow content. Claude must load the full skill to know what to do.

```yaml
description: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes
```

Same pattern. Symptoms and timing, not methodology.

This is directly aligned with both Anthropic's guidance and Superpowers' own
CSO principle: if the description summarizes the workflow, Claude may follow
the summary instead of reading the skill.

### Gstack

```yaml
description: |
  Ship workflow: detect + merge base branch, run tests, review diff, bump VERSION,
  update CHANGELOG, commit, push, create PR. Use when asked to "ship", "deploy",
  "push to main", "create a PR", "merge and push", or "get it deployed".
  Proactively invoke this skill (do NOT push/PR directly) when the user says code
  is ready, asks about deploying, wants to push code up, or asks to create a PR. (gstack)
```

Three things wrong:
1. **Workflow summary in description** — "detect + merge base branch, run tests,
   review diff, bump VERSION, update CHANGELOG, commit, push, create PR" is the
   workflow. Claude might follow this 8-step summary instead of loading the skill.
2. **Behavioral directive** — "Proactively invoke" and "do NOT push/PR directly"
   are instructions, not discovery metadata.
3. **Length** — This description is loaded for every session alongside descriptions
   from all other skills. With 36 skills, gstack's descriptions alone could consume
   significant system prompt space.

---

## 8. Cross-Cutting Concerns

### How each framework handles shared behavior

| Concern | Superpowers | Gstack |
|---------|-------------|--------|
| Skill discovery | Hook injects meta-skill on session start | Proactive routing rules in every SKILL.md |
| Voice/personality | Not addressed (defers to user's CLAUDE.md) | ~100 lines in every SKILL.md |
| Telemetry | None | Bash preamble in every skill |
| Session persistence | Plan files on disk | Timeline JSONL + checkpoint system |
| Version management | External `bump-version.sh` | Preamble checks + upgrade flow in every skill |
| Routing | Meta-skill says "check skills" | Decision table + CLAUDE.md injection |

**Superpowers** handles cross-cutting concerns **outside skills**: the hook handles
bootstrap, CLAUDE.md handles project config, the meta-skill handles routing.
Individual skills stay focused on their domain.

**Gstack** handles cross-cutting concerns **inside every skill**: the template system
injects shared content (preamble, voice, routing, completeness, AskUserQuestion
format, completion protocol) into every generated SKILL.md. This guarantees
availability but means every skill carries ~400 lines of overhead.

### Anthropic's implicit guidance

The < 500 line recommendation and progressive disclosure pattern strongly favor
the Superpowers approach: keep skills focused, handle shared concerns elsewhere.
The framework examples in the best practices doc show skills that do one thing well,
not skills that carry organizational infrastructure.

---

## 9. Structural Diagrams

### Anthropic guidance

Anthropic's best practices don't mandate diagrams, but recommend concise,
unambiguous representations of process flows. Graphviz `dot` blocks are
particularly efficient: compact token footprint, forced explicitness (every
node and edge must be declared), and no prose hand-waving.

### Superpowers: 10 diagrams across skills

| Skill | Diagrams | Purpose |
|-------|----------|---------|
| `using-superpowers` | 1 | Skill activation decision flow |
| `brainstorming` | 1 | 9-step process with decision points |
| `test-driven-development` | 1 | RED-GREEN-REFACTOR cycle |
| `subagent-driven-development` | 2 | When-to-use decision + orchestration |
| `dispatching-parallel-agents` | 1 | When-to-use decision |
| `root-cause-tracing` | 2 | When-to-use + backward trace principle |
| `condition-based-waiting` | 1 | When-to-use decision |
| `writing-skills` | 1 | When-to-include-flowcharts (meta) |

The `writing-skills` skill includes explicit guidance on when to add a diagram:
"Decision where I might go wrong?" → add flowchart. "Sequential steps?" → skip,
prose is fine. There's also a `render-graphs.js` utility that extracts `dot`
blocks and renders them to SVG for the human partner to review.

Diagrams are used strategically — specifically at decision points where Claude
might take the wrong branch. This is the exact use case where visual structure
outperforms prose.

### Gstack: zero diagrams in 36 skills

Not a single `dot`, `mermaid`, `graphviz`, or `plantuml` block in any SKILL.md.

This is notable because gstack's workflows are more complex and would benefit
more from diagramming. The `ship` skill has multi-step conditional flows (base
branch detection → test results → review → version bump → changelog → PR).
The `autoplan` skill chains three review skills sequentially. These are harder
to follow in prose than they would be in a compact graph.

---

## 10. Brand Payload vs Engineering Substance

### The token budget question

Every token in a SKILL.md competes with conversation history and working context.
Anthropic's guidance is explicit: "Does this paragraph justify its token cost?"

### Superpowers: zero brand content

No voice section. No philosophy essays. No telemetry funnel. No promotional
nudges. Every line in every skill serves either process discipline or structural
clarity. The author's identity is absent from the skill content.

### Gstack: significant brand payload in every skill

The template system injects the following into every generated SKILL.md:

**Voice section (~100 lines)** — Prescribes Garry Tan's personal communication
style: "Sound like someone who shipped code today," specific humor guidelines
("dry observations about the absurdity of software"), banned words list, writing
rules. This is brand voice, not agent behavior. Claude doesn't need 100 lines of
personality coaching to execute a shipping workflow.

**"Apply to YC" nudge** — Baked into voice rules: "When a user shows unusually
strong product instinct... say that people with that kind of taste and drive are
exactly the kind of builders Garry respects and wants to fund, and that they
should consider applying to YC." This is a recruitment funnel embedded in a
developer tool.

**"Boil the Lake" philosophy** — On first run, every skill forces an introduction
to the Completeness Principle with a link to an essay on garryslist.org. Tracked
with a `touch ~/.gstack/.completeness-intro-seen` marker file.

**Effort compression table** — CLAUDE.md instructs: "When estimating or discussing
effort, always show both human-team and CC+gstack time." The table ("human: 1 week
/ CC+gstack: 30 min / ~30x") is a sales pitch for the framework, not a developer
instruction.

**Telemetry onboarding funnel** — Two-step downgrade flow (community → anonymous →
off) with persuasive copy ("Help gstack get better!"). Classic product growth
pattern, not developer ergonomics.

### Quantifying the cost

Rough estimate of non-engineering content per skill:

| Content | Lines | Purpose |
|---------|-------|---------|
| Voice/personality | ~100 | Brand identity |
| Completeness Principle | ~30 | Philosophy essay + link |
| Effort compression | ~15 | Marketing talking point |
| Telemetry funnel | ~40 | Growth metrics |
| YC nudge | ~10 | Recruitment |
| AskUserQuestion formatting | ~30 | Brand-consistent UX |
| **Total brand payload** | **~225** | |

That's ~225 lines per skill consumed by brand messaging — nearly half of
Anthropic's entire 500-line budget — before any domain-specific content begins.

The browser daemon and E2E test infrastructure are genuinely good engineering.
The skill layer wraps them in a distribution vehicle for YC brand positioning.
The 15,000 total SKILL.md lines vs Superpowers' 3,700 are not explained by
gstack doing more work — they're explained by gstack carrying more payload.

---

## 11. Evaluation and Testing

### Anthropic guidance

> "Create evaluations BEFORE writing extensive documentation."
> "Tested with Haiku, Sonnet, and Opus."

### Superpowers

Pressure scenario testing: run scenario without skill (baseline), observe failure,
write skill, test with skill (compliance), iterate. The `writing-skills` skill
documents this methodology in detail, including pressure types and meta-testing.

Test infrastructure exists (`tests/` directory) with trigger tests, integration
tests, and brainstorm server tests. The framework treats skill testing as a
first-class concern.

Aligns well with Anthropic's evaluation-first approach. The pressure scenario
methodology goes further than Anthropic's recommendation by testing specific
behavioral failure modes, not just task completion.

### Gstack

Comprehensive testing infrastructure:
- Static validation (`skill-validation.test.ts`)
- LLM-as-judge evaluations (`skill-llm-eval.test.ts`)
- End-to-end tests via `claude -p` (`skill-e2e-*.test.ts`)
- Two-tier system (gate for CI, periodic for quality)
- Diff-based test selection for cost control

Gstack's testing is more infrastructure-heavy but focuses on output quality
rather than behavioral compliance. The LLM-as-judge pattern evaluates whether
the skill produced good results, not whether the agent followed the process.

Both approaches have merit. Superpowers tests process discipline; gstack tests
output quality. Ideally, both would be tested.

---

## 12. Summary Scorecard

| Criterion | Superpowers | Gstack | Winner |
|-----------|:-----------:|:------:|:------:|
| Frontmatter compliance | 9/10 | 4/10 | Superpowers |
| SKILL.md size (< 500 lines) | 9/10 | 2/10 | Superpowers |
| Progressive disclosure | 8/10 | 2/10 | Superpowers |
| Description field usage | 9/10 | 3/10 | Superpowers |
| Degrees of freedom calibration | 9/10 | 5/10 | Superpowers |
| Structural diagrams | 8/10 | 0/10 | Superpowers |
| Executable code utilization | 3/10 | 7/10 | Gstack |
| Cross-cutting concern isolation | 8/10 | 3/10 | Superpowers |
| Testing methodology | 7/10 | 8/10 | Gstack |
| Token efficiency | 8/10 | 3/10 | Superpowers |
| Engineering-to-brand ratio | 10/10 | 4/10 | Superpowers |
| Deterministic operations | 2/10 | 8/10 | Gstack |

### The fundamental difference

**Superpowers builds skills as behavioral guidance** — lean markdown that shapes
how Claude approaches work. It trusts Claude's intelligence and focuses on
preventing specific failure modes. Skills are concise because they only contain
what Claude wouldn't do on its own.

**Gstack builds skills as operational packages** — everything needed for a workflow
bundled into one artifact: voice, routing, telemetry, session state, error handling,
and the actual domain logic. Skills are large because they carry organizational
infrastructure alongside domain knowledge.

From Anthropic's guidance perspective, Superpowers is closer to the recommended
pattern. But Anthropic's examples are for knowledge/tool skills (PDF processing,
BigQuery analysis), not workflow orchestration. Gstack's monolithic approach may
be a deliberate tradeoff for guaranteed behavior at the cost of token efficiency.

### What our framework should take from each

**From Superpowers** (structural patterns):
- Minimal frontmatter (name + description only)
- < 500 line SKILL.md with progressive disclosure
- Description = trigger conditions, not workflow summary
- Cross-cutting concerns outside individual skills
- Freedom calibrated to fragility

**From Gstack** (operational patterns):
- Executable scripts for deterministic operations
- Session state infrastructure (timeline, checkpoints)
- LLM-as-judge evaluation alongside behavioral testing
- Context recovery after compaction

**From neither** (our gap):
- Product-level backlog management
- Feature grooming and prioritization
- Handoff protocol from product decisions to execution skills
