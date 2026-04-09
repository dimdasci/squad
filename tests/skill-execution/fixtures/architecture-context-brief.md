# Product Brief: TeamPulse

Status: approved
Date: 2026-04-01
Approved by: Test CPTO

## Problem

**How might we help remote team leads see whether agreed-upon team practices are actually happening, without micromanaging or adding status reporting overhead?**

Remote team leads managing 5-15 people across timezones have no visibility into whether agreed-upon team practices are actually happening. They find out weeks later when quality drops. Existing tools (Jira, Slack) track tasks, not habits.

## Users

**Primary user: Remote team lead**

1. "When I notice my team's code review quality dropping, I want to see which practices we agreed on are actually being followed, so I can address the gap before it becomes a crisis."

2. "When I'm preparing for a 1:1, I want to see a team member's consistency trends without asking them to write status reports, so I can have a data-informed conversation."

**Secondary user: Individual contributor**

3. "When I want to demonstrate my consistency to my lead, I want my daily habits to be tracked automatically from tools I already use, so I don't need to write status updates."

## Solution Boundary

### This product IS
- A dashboard showing team practice adherence trends
- A Slack integration for lightweight daily check-ins
- Weekly trend reports for team leads
- An API for pulling data from existing tools (GitHub, Jira)

### This product IS NOT
- A task manager or project management tool
- A gamification or rewards system
- A time tracker
- A performance review or HR tool
- A replacement for retrospectives or standups

### MVP prioritization

**Must have (week 1-2):**
- Slack check-in integration
- Practice definition (team lead configures which habits to track)
- Basic dashboard with weekly trends

**Nice to have (stretch):**
- GitHub/Jira auto-detection of practices
- Individual contributor self-view

## Success Criteria

1. **Adoption:** 80% of team members complete daily check-ins within 2 weeks of onboarding
2. **Visibility:** Team leads report improved visibility into practice adherence in post-pilot survey by week 4
3. **Low friction:** Average check-in takes under 30 seconds (measured by Slack interaction timestamps)
4. **Data quality:** Dashboard trends match manual spot-checks with 90%+ accuracy by week 3

## Appetite & Constraints

**Appetite:** 4 weeks, solo developer.

**Constraints:**
- Must integrate with Slack (team already uses it daily)
- Web dashboard, responsive for mobile viewing
- Single-team deployment for MVP

**No-gos:**
- No gamification (badges, points, streaks)
- No individual performance scoring or ranking
- No replacing existing project management tools
- No native mobile app in MVP
