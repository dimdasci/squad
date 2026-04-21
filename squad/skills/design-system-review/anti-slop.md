# Anti-slop catalog

Single-source list of named patterns that the validator flags as slop
and the producer should avoid. Each entry names the pattern and
explains **why it's slop** so the validator applies specific craft
rules, not fashion judgments. This file is referenced by:

- `squad/skills/design-system-review/SKILL.md` (this skill's own Checks
  section, finding type for Visual language and Voice and tone craft)
- `squad/skills/design-system/SKILL.md` Phase 5 (producer reads before
  drafting to avoid these patterns)

Two halves: **doc-prose slop** (text of `design/system.md`) and
**visual / content slop** (HTML preview). Doc-prose slop earns a
finding on the doc; visual slop earns a finding on the preview.

## Doc-prose slop

### Vague principles

"Be delightful", "be fast", "be intuitive" — these fit any product;
they guide no decision. A principle earns its keep only when a
designer or engineer can read it and know what to rule out. A
principle that can't lose an argument isn't a principle.

### Generic voice descriptors

"Friendly but professional", "casual but polished", "warm yet
precise" — adjective-only, no concrete register or example sentence.
A voice spec passes craft only when it names a specific register
(e.g., "technical-direct") and shows at least one example sentence
for each declared surface. Adjectives without examples leave every
downstream decision to the author's guess.

### Unanchored adjectives

"Clean", "modern", "minimal" used without naming what is being
removed or what pattern is being followed. "Minimal" names a
reduction — of what? "Modern" is a date, not a choice. Anchored
equivalents: "minimal chrome around the input — no border, underline
only on focus" or "modern in the clig.dev sense — subcommands over
flags, plain output by default."

### Fake SAFE/RISK

A RISK choice that departs cosmetically without earning the departure
— same category, same register, no signal. Canonical example: "use
`#007acc` instead of `#0066cc`" — both are dev-tool blues, no category
signal, no cost if rejected. Real RISK earns the label by category
expectation + signal created + cost of rejection. If all three can't
be named, it's SAFE dressed as RISK, or it's decoration.

### Undefined concept mentions

References to "our tone" or "the aesthetic" or "the product voice"
without the thing being defined anywhere in the doc. The first time
a concept is named, it must be defined or cited; later references
resolve to that definition. Ungrounded mentions invite each reader
to fill in their own meaning.

### Filler without evidence

Sections whose body could be deleted without losing information —
rhetorical buildup, restatement of the section title, meta-commentary
about the importance of the section. If a paragraph says "this
section describes our principles" and then lists the principles, the
first sentence is filler. Delete and move on.

### Invented personas

User traits that don't trace to the brief's JTBD. A design system
that says "our users value elegance" when the brief says nothing
about elegance has invented a trait. Voice and tone decisions
downstream inherit from these invented traits and lock in an
incorrect register.

### Generic interaction-pattern wording

"Make feedback clear" or "ensure visibility of system status" —
describes no concrete behavior. Compare the specific alternative:
"Errors surface inline next to the input that produced them; never
as top-level toasts." A pattern is concrete when a reviewer can read
it and say "yes this is followed" or "no this is violated" on any
given screen.

## Visual / content slop (preview HTML)

### Purple gradients

Signature of AI-generated hero sections. Indicates the producer
defaulted to a well-known "pretty" pattern rather than earning the
palette from positioning. Same pattern appears across hundreds of
SaaS landing pages; no signal, just vibes.

### Three-column icon grids with centered lorem

The most overused landing-page pattern of the last decade. If it
appears in a preview without positioning-specific reasoning (why
three? why grid? why icons at this size?), it is slop. The pattern
is zero-cost to generate and zero-signal to readers.

### Decorative blobs / abstract shapes

When they do not encode brand signal — decoration in place of
meaning. Blobs earn their keep if they reference a product metaphor
named in the brief (e.g., fluid data in a data-pipeline tool); they
don't earn their keep as "visual interest."

### Emoji as design

Emoji standing in for icons or visual accents. Signals lack of icon
system, not a taste call. Two narrow exceptions: (1) inside CLI
output samples where Unicode glyphs are the design; (2) product
intentionally uses emoji as part of its voice (e.g., a consumer chat
product). Default stance: emoji in a design system preview is a gap,
not a choice.

### Colored-left-border cards

Ubiquitous "callout" pattern from modern docs sites (red left
border = warning, yellow = note, green = success). Include only if
earned by the voice spec or docs conventions — otherwise it's
imported decoration. Not every product needs a four-color callout
system.

### Uniform bubbly radii

Large `border-radius` applied to every surface (buttons, cards,
inputs, alerts) with no rationale. A register choice, but only a
choice if explicit — otherwise it's the 2023 default. Explicit
alternative: sharp radii for a technical register, generous radii
for a consumer register, mixed radii with a named rule.

### Centered-everything layouts

Centering as a default — nav centered, hero centered, cards centered,
footer centered. Looks like a landing page, not a product. Product
UI usually earns asymmetry from information density.

### Generic hero copy

"Ship faster." / "Build better." / "The fastest X for Y." / "Move at
the speed of thought." Fits any category. A preview that uses these
phrases shows the producer did not ground the copy in positioning.

### Overused display fonts

Inter, Roboto, Poppins used without rationale. Popular ≠ reasoned.
Any of these is fine if the rationale names why them over
alternatives (e.g., "Inter for its genuine numeric legibility in
dashboard density" is a rationale; "Inter because it's clean" is not).

### Token-less palettes

Raw hex strings in the palette section with no role names. `#0066cc`
next to `#cc0000` with no "primary", "error", "accent" tokens. Color
without role is decoration; color with role is a system.
