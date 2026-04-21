# Design System Review Checklist

Detailed pass/fail criteria for each review check. The reviewer reads
this file during the review process. Every FAIL must cite a section
and a quoted span from `design/system.md` or the preview HTML.

## Per-category checks

### Principles

### P1: Principles are specific, not generic

**How to check:** Read each principle. A generic principle could apply to any product ("be delightful", "be fast"). A specific principle names the trade-off or what it rules out.
**PASS if:** Each principle is specific enough to guide a concrete decision.
**FAIL if:** Any principle is generic enough to fit on any product. Cite the specific principle.

### P2: Principles derive from the brief

**How to check:** For each principle, identify which brief element it derives from (JTBD trait, constraint, success criterion).
**PASS if:** Each principle has a visible line to the brief.
**FAIL if:** A principle is invented without brief support. Cite the principle.

### P3: Principle count is reasonable

**How to check:** Count the principles in the Principles section.
**PASS if:** 3 to 7 principles, each distinct.
**FAIL if:** Fewer than 3 (too thin to guide decisions) or more than 7 (dilution; principles that restate each other). Cite the overlap or the gap.

### Voice and tone

### V1: Voice register is concrete

**How to check:** Look for named registers with a sample sentence (e.g., "technical-direct — 'Build failed: exit code 2. Check the config path.'"). Adjective-only voices ("friendly but professional") are a common slop pattern.
**PASS if:** Each declared register is named and has at least one example sentence that shows it in action.
**FAIL if:** Voice is described only with adjectives, or no example sentences are given. Cite the adjective string.

### V2: Tone shifts per surface are declared

**How to check:** For each declared surface (GUI, CLI, API, docs), verify the tone is specified separately. Voice is not uniform: a GUI helper string reads differently from a CLI error from an API error payload from a docs body paragraph.
**PASS if:** Tone is declared per surface with surface-specific guidance.
**FAIL if:** A single uniform tone is applied across all declared surfaces, or a declared surface has no tone guidance. Cite the surface.

### V3: Voice traits trace to the brief

**How to check:** For each voice trait, identify which brief element (JTBD, audience trait, positioning line) it derives from.
**PASS if:** Each trait has a visible line to a brief element.
**FAIL if:** A trait is invented without brief support. Cite the trait.

### Terminology

### T1: Terminology table present and product-specific

**How to check:** Look for a terminology table or glossary. Verify it names product-specific terms, not generic software vocabulary.
**PASS if:** A terminology table exists with product-specific terms and their definitions.
**FAIL if:** No terminology table, or the table only lists generic terms ("user", "session", "error") without product-specific entries.

### T2: Forbidden variants and aliases declared

**How to check:** Read the table for a "NOT called" column or equivalent. Cross-reference against `identity/naming.md` for forbidden short forms or variants.
**PASS if:** Key terms declare their forbidden variants and the naming document's aliases are honored.
**FAIL if:** A term has known variants but the table does not declare them, or the table contradicts `identity/naming.md`. Cite the conflict.

### Information architecture

### IA1: IA covers declared surfaces only

**How to check:** Cross-reference IA subsections against surfaces declared in `architecture/record.md`. GUI IA covers navigation and information hierarchy; CLI IA covers command structure and verbs; API IA covers resource naming and version prefix; docs IA covers a diátaxis-style split or a declared alternative.
**PASS if:** Every declared surface has an IA subsection with surface-appropriate content.
**FAIL if:** A declared surface has no IA subsection, or an undeclared surface has one. Cite the surface.

### IA2: IA specifies structure, not aspirations

**How to check:** Read each IA subsection. Look for concrete structure (named routes, verb lists, resource path shapes, heading hierarchy) rather than goals ("information should be findable").
**PASS if:** Each IA subsection names concrete structural elements.
**FAIL if:** An IA subsection only describes goals or qualities without structure. Cite the span.

### Interaction patterns

### IP1: Interaction patterns are specific, not vague

**How to check:** Look for concrete placement and behavior ("errors surface inline next to the input that produced them, never as top-level toasts") rather than vague intent ("make feedback clear").
**PASS if:** Each pattern names a concrete placement, trigger, or behavior.
**FAIL if:** A pattern is stated only as intent or quality. Cite the pattern.

### IP2: Interaction patterns cover declared surfaces only

**How to check:** For each declared surface, verify the pattern set is appropriate (GUI: inputs, feedback, navigation; CLI: prompts, confirmation, progress; API: retries, idempotency; docs: callouts, cross-links).
**PASS if:** Patterns are scoped to declared surfaces with surface-appropriate coverage.
**FAIL if:** Patterns exist for an undeclared surface, or a declared surface has no pattern coverage. Cite the surface.

### Visual language

### VL1: SAFE and RISK decisions are earned, not cosmetic

**How to check:** For each decision marked SAFE or RISK, verify it names the category norm, the departure, and what signal the departure creates. Fake rebellion — cosmetic departures without signal (e.g., "use #007acc instead of #0066cc") — is a FAIL. See [anti-slop.md](anti-slop.md).
**PASS if:** Every SAFE/RISK call names norm, departure, and signal.
**FAIL if:** A RISK call is cosmetic, or a SAFE call does not name the norm it conforms to. Cite the decision.

### VL2: Palette carries role tokens, not just hex

**How to check:** Read the palette section. Look for role tokens (background, surface, primary, accent, error, warning, success, muted) paired with hex values.
**PASS if:** Every color token has both a role name and a hex value.
**FAIL if:** Raw hex values appear without role names, or role names appear without hex values. Cite the token.

### VL3: Typography declares faces with rationale

**How to check:** Look for named display and body faces, each with a rationale tied to voice, audience, or brand. Defaults without rationale (Inter, Roboto, Poppins "because popular") are a slop pattern per [anti-slop.md](anti-slop.md).
**PASS if:** Each face is named and has a rationale that ties to the brief or identity.
**FAIL if:** A face is named without rationale, or the rationale is generic ("clean and modern"). Cite the face.

### Surface conventions

### SC1: Conventions cover declared surfaces with specifics

**How to check:** For each declared surface, look for surface-specific rules (GUI: focus ring, spacing rhythm; CLI: verb set, exit codes, output modes; API: error envelope shape, versioning; docs: heading depth, admonition set).
**PASS if:** Each declared surface has a subsection with surface-specific rules.
**FAIL if:** A declared surface has no subsection, or a subsection contains only generic guidance that would fit any surface. Cite the surface.

### SC2: No subsections for undeclared surfaces

**How to check:** Cross-reference against declared surfaces from `architecture/record.md`.
**PASS if:** No subsection exists for a surface that is not declared.
**FAIL if:** A subsection exists for an undeclared surface (adaptive-scope violation). Cite the subsection.

## Cross-cutting checks

### X1: Research citation presence

**How to check:** For each SAFE/RISK decision and each decision that references a standard or peer product, look for at least one citation (link, doc reference, or named source).
**PASS if:** Every SAFE/RISK decision cites at least one peer or standard.
**FAIL if:** A SAFE/RISK call has no citation. Cite the decision.

### X2: Brief alignment

**How to check:** For each JTBD trait that surfaces in voice or tone, trace it back to `product/brief.md`.
**PASS if:** Every voice/tone trait has a supporting element in the brief.
**FAIL if:** A trait has no brief support. Cite the trait.

### X3: Decisions Log row present

**How to check:** Read the Decisions Log section. Verify a row exists for the current doc version with date, mode, and summary. On fresh-start mode, verify a `replaced` row points at `design/system.<date>.md.bak`.
**PASS if:** A row exists for the current version, and on fresh-start a `replaced` row references the backup file.
**FAIL if:** No row for the current version, or fresh-start mode without a `replaced` row pointing at the backup. Cite the gap.

### X4: Preview alignment

**How to check:** Open `design/preview/<latest>.html`. List the surface blocks it contains. Compare against surfaces declared in the doc.
**PASS if:** Preview covers every declared surface with a block, and contains no blocks for undeclared surfaces.
**FAIL if:** Preview is missing a declared surface's block, or includes a block for an undeclared surface. Cite the surface.

### X5: SAFE/RISK discipline — no fake rebellion

**How to check:** For each RISK decision, verify the departure from the category norm creates a real signal (product differentiation, voice reinforcement, audience fit). Cosmetic departures without signal are fake rebellion. The `#007acc vs #0066cc` example in [anti-slop.md](anti-slop.md) is the canonical fake-rebellion case.
**PASS if:** Every RISK decision creates a real signal that ties to brief, identity, or voice.
**FAIL if:** A RISK decision is cosmetic (changed value, same signal) or the signal is not named. Cite the decision.

### X6: Adaptive-scope discipline

**How to check:** Cross-reference declared surfaces (from `architecture/record.md`) against every section of the doc that mentions a surface. No fabricated sections for undeclared surfaces; no missing sections for declared surfaces.
**PASS if:** Every declared surface has its expected sections (IA, interaction patterns, surface conventions) and no undeclared surface has any section.
**FAIL if:** A section fabricates coverage for an undeclared surface, or a declared surface is absent from a section it belongs in. Cite the surface and the section.
