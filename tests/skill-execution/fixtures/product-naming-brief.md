# Product Brief: [unnamed]

Status: approved
Date: 2026-04-01
Approved by: Test CPTO

## Problem

**How might we help solo consultants and freelancers track time across many small client projects without making time tracking feel like a second job?**

Solo consultants juggle 5-15 small client projects per month. Time tracking is essential for billing, but every existing tool (Toggl, Harvest, Clockify) is built for teams and demands too much overhead — projects, tags, descriptions, reviews. By the time the consultant logs the work, they've forgotten what they did. So they reconstruct from memory at the end of the week, billing fewer hours than they worked.

## Users

**Primary user: Solo consultant or freelancer**

1. "When I switch from one client task to another, I want to log the switch in 2 seconds, so I don't lose flow and don't forget what I just did."

2. "When I sit down at the end of the week, I want to see all my time accurately captured, so I can bill what I actually worked instead of guessing low."

3. "When I send an invoice, I want the time entries to make sense to the client, so they don't push back asking what I was doing."

## Solution Boundary

### This product IS
- A keyboard-driven time tracker for solo workers
- A way to log a client switch in under 2 seconds
- A weekly summary view that turns into invoice line items
- Single-user only — no team features, no collaboration

### This product IS NOT
- A team time tracking tool (Toggl/Harvest cover that)
- A project management tool
- A billing/invoicing system (it exports; another tool sends)
- A pomodoro timer or focus app

## Success Criteria

1. A solo consultant can log a client switch in under 3 seconds, measured from key-down to confirmation, by week 2 of using the product.
2. Weekly tracked time is within 10% of actual worked time, measured against self-reported worked hours, by week 4.
3. 70% of beta users still use the product daily 30 days after install.
4. Invoice export is accepted by a real client without follow-up questions in 90% of test cases.

## Appetite & Constraints

**Appetite:** 6 weeks for the first usable version (Shape Up cycle). The keyboard-first switch logging is the cycle anchor; everything else is scope-cuttable.

**Constraints:**
- Single-user, local-first (no server-side state required for core flow)
- Works on macOS first; Linux and Windows nice-to-have but not blocking
- Plain-text export (no proprietary file format)
- No analytics, no telemetry, no account required

**No-gos:**
- Team features
- Cloud sync as a primary requirement (offline-first)
- Pomodoro/focus enforcement
- Anything that interrupts the user's flow
