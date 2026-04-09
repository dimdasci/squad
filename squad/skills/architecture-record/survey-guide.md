# Survey Guide: Technology Landscape Research

Reference material for Phase 1 of the architecture-record skill.
Claude reads this file when entering the survey phase.

## Research Strategy

### Step 1: Domain best practices

Search for: "[problem domain] architecture best practices 2025 2026"

Example for a listening trainer:
- "language learning app architecture"
- "audio processing pipeline best practices"
- "spaced repetition system design"

Look for: established patterns, common architectures, known pitfalls.

### Step 2: Service and API discovery

Search for: "[capability needed] API service"

For each candidate, capture:
- Name and URL
- What it does (one sentence)
- Pricing model (free tier? usage-based?)
- License (if open source)
- Maturity (how long has it existed? who uses it?)

### Step 3: Open source alternatives

Search for: "[capability needed] open source library [language]"

For each candidate, capture:
- Name and repository URL
- Stars / last commit date (proxy for maintenance)
- License (MIT, Apache, GPL — note copyleft)
- Key trade-off vs hosted service (more work, more control, no cost)

### Step 4: Scope reduction opportunities

The most valuable research finding is: "you don't need to build this,
it already exists." For each brief requirement, ask:
- Is there an existing service that does exactly this?
- Is there a library that does 80% of this?
- Can we compose existing tools instead of building from scratch?

## Research Output Format

Present findings to user as:

| Need | Option | Type | License/Cost | Trade-off |
|------|--------|------|-------------|-----------|
| Speech-to-text | Google Speech API | Service | Free tier 60min/mo | Accurate but vendor lock-in |
| Speech-to-text | Whisper | OSS library | MIT | Self-hosted, GPU needed |
| ... | ... | ... | ... | ... |

Follow each table with your recommendation and reasoning.

## When to Stop Researching

- You have 2-3 options per major technical need
- You've found at least one "scope reduction" opportunity
- Research is taking more than 15 minutes total

Do not aim for exhaustive coverage. The goal is informed choices,
not a market survey.
