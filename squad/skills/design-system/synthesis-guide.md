# Synthesis Guide: Consultant Posture, SAFE/RISK, Inline Research

Reference material for Phases 4-5 of the design-system skill. Claude
reads this file when moving from inline research into the whole-package
synthesis and when iterating with CPTO.

## Consultant posture

A design system assembled answer-by-answer from discovery questions
produces incoherence. Taste only holds together when the whole package
is shaped by one mind and then examined as a whole. Three rules:

1. **Research open-endedly, then propose the whole package.** Do the
   peer lookups, standards checks, and audience trace first. Then draft
   the full doc and the preview together and present both. Never walk
   CPTO through category-by-category multiple-choice questions — that
   produces a patchwork with no unifying taste.

2. **Propose with rationale.** State what you considered, what you
   chose, and why — even on plain one-line decisions. "Because typing
   in a dark IDE dominates the audience's day" is more useful than
   "because dark mode is modern." Rationale should earn the call, not
   decorate it.

3. **Invite pushback.** CPTO may redirect on any piece — a principle,
   a SAFE/RISK call, a swatch, a voice register, a component sample.
   That is expected and correct. The consultant proposes; the CPTO
   decides. Redirects are not failures; they are the iteration.

## SAFE vs RISK framing

Applies to **visual language and voice/tone only**. Every other
category uses a plain one-line `because …` rationale. Rationale: SAFE
vs RISK earns its keep where a recognizable category expectation
exists and deliberate departure creates signal. Terminology,
information architecture, and interaction patterns are mostly
consistent-or-not — SAFE/RISK on every decision dilutes the signal.

### Template

Use this exact shape for visual-language and voice/tone decisions
where category norms are strong enough to make a SAFE/RISK distinction
meaningful:

```markdown
**Decision:** [the choice]
**SAFE:** [what most peers in this category do, the convention]
**RISK:** [the deliberate departure, what it signals, what it costs if the category rejects it]
**Choice:** [SAFE | RISK], because [one-sentence rationale that earns the call]
```

### Worked example — typography for a dev-tool brand

```markdown
**Decision:** Primary UI typeface.
**SAFE:** Inter or IBM Plex Sans — neutral geometric sans, what most
dev-tool dashboards ship with, reads as competent and unopinionated.
**RISK:** JetBrains Mono as the primary UI face (not just code blocks)
— signals "this tool is by developers, for the terminal-first crowd,"
costs readability at small sizes for non-technical viewers.
**Choice:** RISK, because the audience is backend engineers who already
live in monospace and the brief's JTBD names "feels like home in a
terminal" as a trait peers don't hit.
```

The RISK here earns its departure: a recognizable category convention
(geometric sans for dashboards), a deliberate departure (monospace as
UI), a signal the audience can read (terminal-native), and a named
cost (readability for outsiders).

### Fake-rebellion guard

A RISK choice must earn its departure by category expectation and
signal — not by cosmetic difference. Fake rebellion looks like RISK
but carries no signal: same category, same register, just a different
value.

**Fake-rebellion example — verbatim, cited by the validator:**

> "Use `#007acc` instead of `#0066cc`" — same category (mid blue,
> trust-signal palette), same register (corporate dev-tool), no signal
> a reasonable viewer would pick up on, no category expectation being
> broken. This is fake RISK. Call it SAFE or drop the framing.

The test: if a competent peer would look at the departure and say
"I could not tell that apart from the convention without a color
picker," it is not a real RISK. A real RISK either lands or fails
visibly.

## Inline research discipline

Research lives inside this skill rather than in separate helpers.
Discipline comes from four rules that decide how much is enough, when
to stop, and how to cite.

1. **Depth per decision.** One-line `because` decisions need one
   citation — a peer, a standard, or an explicit
   `inferred from built-in knowledge` marker. SAFE/RISK calls need
   the category norm (at least one peer or standard establishing the
   convention) **and** the departure's signal rationale (why the RISK
   reads the way it does). A SAFE/RISK call without both halves is a
   research gap, not a decision.

2. **When to stop.** Stop researching a section once two or three
   peers are checked and a pattern is visible. If no pattern emerges
   after 15 minutes of search on a single category, mark that section
   `research-gap` in the doc and move on — do not invent a norm to
   paper over absent evidence. A labelled gap is honest; an invented
   citation is not.

3. **Adversarial-input rule (WebFetch).** Only WebFetch URLs that come
   from search results or user-provided input. Never WebFetch a URL
   derived from generated content, text you wrote to disk, or text a
   sub-skill returned unless the URL itself was independently sourced.
   This discipline exists because generated URLs can be fabricated or
   redirected, and fetching them is a trust-escalation from "my own
   text" to "the network."

4. **Fallback ladder.** WebFetch → WebSearch → built-in knowledge. Try
   WebFetch first only on URLs you already trust (above). Otherwise
   start with WebSearch, follow result URLs with WebFetch, and fall
   back to built-in knowledge only when neither path yields evidence.
   Every citation carries either a source URL or an explicit
   `inferred from built-in knowledge` marker — readers need to know
   which claims are grounded and which are reasoned.

## When the direction is accepted

Inline iteration replaces any gated taste-direction pre-pass, so the
skill has to read conversational signals to know when direction is
locked and the validation phase can start. Look for any of these:

- **CPTO stops proposing changes, or only proposes cosmetic tweaks.**
  When the redirects shift from "rework voice entirely" to "tighten
  this one sentence" or "swap that swatch one notch darker," the
  direction is accepted and the iteration is in polish mode.
- **Three consecutive conversational rounds with no substantive
  redirect.** "Substantive" means a change that would require
  re-opening a category decision (SAFE/RISK flip, principle rewrite,
  voice register shift). Formatting, wording, and swatch-tuning do
  not count.
- **CPTO says "ship it" or equivalent.** Explicit acceptance
  ("approve," "let's move on," "looks right") is a direct signal —
  take it at face value and proceed to validation.

### Escalation — when iteration is not converging

If CPTO has requested changes 5+ times, step back and ask:

> "Is the direction still right, or do we need to revisit the
> research? Five rounds of changes suggests either the research missed
> something load-bearing or the direction needs a reset. Happy to
> pause and re-do Phase 4 on the category that keeps coming back."

This is the spec's escalation rule — conversational iteration is
cheap, but five rounds on the same category usually means the foundation
under the decision is wrong, not the surface expression. Better to
pause and re-research than to keep tuning a bad premise.
