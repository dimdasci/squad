# Naming Playbook

Methodology depth for the `product-naming` skill. Loaded on demand
from SKILL.md when entering Step 3 (generation) or Step 5 (ranking).

## Sources

This skill is inspired by three publicly available naming frameworks
and one proprietary practice; it does not reproduce any of them
literally:

- **Igor Naming Guide** (Jurisich & Manning, Igor International, 2022).
  Free PDF: https://www.igorinternational.com/process/i/Igor%20Naming%20Guide%202022A.pdf
  Source of the 4-category taxonomy.
- **SMILE / SCRATCH** from *Hello, My Name Is Awesome*
  (Alexandra Watkins, Berrett-Koehler, 2018). Acronyms widely
  summarized in public sources. Source of the evaluation rubric.
- **Rob Meyerson's 7-step process** (howbrandsarebuilt.com, 2022).
  Free blog post. Source of the operational stage vocabulary.
- **Lexicon Branding** (David Placek). Proprietary; cited only for
  the parallel-team-with-decoy-briefs philosophy that motivates the
  4-lens parallel subagent generation.

## Igor 4-category taxonomy

Real names fall into one of four categories. Functional names are the
most common and the weakest; evocative names are rarer and the
strongest, but also the hardest to land.

- **Functional** — descriptive, founder, acronym. Literal connection
  to what the product does. *Examples: Microsoft, Pizza Hut, IBM,
  Salesforce.* Easy to approve, hard to defend in trademark, weak
  brand legs.
- **Invented** — coined or obscure non-English. No prior associations.
  *Examples: Google, Kodak, Häagen-Dazs, Pentium.* Maximum
  trademark strength, requires marketing to load with meaning.
- **Experiential** — literal but imaginative connection to a real
  experience. *Examples: Netscape, Palm Pilot, Bumble.* Bridges
  functional and evocative.
- **Evocative** — evokes positioning without describing function.
  *Examples: Apple, Virgin, Amazon, Patagonia.* Strongest brand legs,
  hardest to land, requires confident positioning.

The skill generates across all four categories to escape single-mode
correlation, not because each is equally appropriate for every brief.
The positioning brief weights the generation toward whichever
categories fit the appetite and tone (functional for short-horizon
MVPs and technical audiences; evocative/invented for long-horizon
consumer plays).

## SMILE rubric (evaluation)

Score each candidate 0–2 per dimension. Total 0–10.

- **Suggestive** (0–2) — Does the name evoke the brand, category, or
  experience? "Suggestive" is the sweet spot between literal
  (functional) and abstract (invented).
- **Meaningful** (0–2) — Does it resonate with the target users (not
  just the founder)? Does it tap a metaphor or association the
  audience will recognize?
- **Imagery** (0–2) — Can someone hearing it picture something? Strong
  imagery makes a name memorable.
- **Legs** (0–2) — Can it extend into a brand theme — taglines, sub-
  brands, visual language? Names that lock you into one association
  fail when the product line grows.
- **Emotional** (0–2) — Does it move people? Emotional resonance is
  what separates brands from products.

## SCRATCH rubric (elimination)

Any hit on these is an elimination signal. SCRATCH runs in Filter 1
(linguistic / phonetic viability) before any tool calls.

- **Spelling-challenged** — hard to spell from hearing it spoken
- **Copycat** — too close to existing brands in the category
- **Restrictive** — locks the brand into one product or geography
- **Annoying / forced** — sounds desperate, marketing-cliché, or
  awkwardly engineered
- **Tame** — generic, forgettable, indistinguishable
- **Curse-of-knowledge** — only makes sense to insiders
- **Hard to pronounce** — friction in sharing word-of-mouth

## Lens 2 adjacent domain list

The skill picks one of these per run by index `(day-of-month %
len(domain_list))`. Rerun rotation increments the index.

1. nature (rivers, forests, mountains, weather, seasons)
2. craft (woodworking, smithing, weaving, pottery)
3. mythology (Greek, Norse, Celtic, Yoruba, Hindu)
4. food (cooking techniques, ingredients, kitchen tools)
5. geology (minerals, formations, processes)
6. music (instruments, intervals, dynamics, rhythm)
7. architecture (forms, materials, structural elements)
8. weaving (knots, patterns, fibers, looms)

The domain list is fixed but not sacred — extend it during a future
revision if the catalog feels exhausted.

## Lens prompt templates

Each subagent receives one template. The skill substitutes the
positioning brief (target users, category, tone, appetite, must-avoid)
into the relevant slots.

### Lens 1 — Functional / descriptive

```
You are generating product name candidates in the FUNCTIONAL category:
descriptive names, founder names, acronyms, and compound words that
literally describe what the product does or who built it.

Target ~60 candidates. Write one name per line in the format `Name|1`
to /tmp/naming-pool-lens1.txt.

Positioning brief:
[POSITIONING_BRIEF]

Generate names that are easy to understand, descriptive of the core
function, and clearly aligned with the category. Don't worry about
trademark — the next stage filters that. Range from boring-literal
to clever-compound. Include some founder-style options if the brief
mentions a single founder.
```

### Lens 2 — Evocative / metaphorical (decoy-anchored)

```
You will generate product name candidates anchored in the domain of
[ADJACENT_DOMAIN]. Before reading the brief, immerse yourself in this
domain: think about its vocabulary, its tools, its rhythms, its
metaphors. Make a mental list of 20 words from this domain.

Now read the positioning brief and generate ~60 candidate names that
bridge [ADJACENT_DOMAIN] to the product. Names should evoke positioning
without being literal — use metaphor, indirect connection, or single-
word resonance. Write one name per line in the format `Name|2` to
/tmp/naming-pool-lens2.txt.

Positioning brief:
[POSITIONING_BRIEF]
```

### Lens 3 — Invented / coined

```
You are generating product name candidates in the INVENTED category:
coined words, morpheme play, Latin/Greek/Romance roots, and
phonetically pleasing constructions that don't exist as English words.

Target ~60 candidates. Write one name per line in the format `Name|3`
to /tmp/naming-pool-lens3.txt.

Positioning brief:
[POSITIONING_BRIEF]

Generate names that sound real but are not real English words. Combine
roots that gesture at meaning without naming it. Aim for phonetic
fitness — names should be easy to say and have rhythm. Avoid pure
nonsense (xqzltl is not a name); aim for plausible-but-novel.
```

### Lens 4 — Experiential / verb-forward

```
You are generating product name candidates in the EXPERIENTIAL
category: verb-forward names, action words, names that describe what
the user DOES or FEELS rather than what the product IS.

Target ~60 candidates. Write one name per line in the format `Name|4`
to /tmp/naming-pool-lens4.txt.

Positioning brief:
[POSITIONING_BRIEF]

Generate names that capture user experience or action: imperative
verbs, gerunds, sensory words, words for the moment of use. The user
is the protagonist; the product is the prop. Avoid functional
descriptions of the product itself.
```

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

## When pools are tight

If fewer than 12 candidates survive the filter pass, surface this in
the Gate 1 presentation as a warning:

> "Pool was tight — only N candidates survived. This usually means
> the positioning is over-constrained. Want to broaden it and rerun,
> or proceed with the surviving N?"
