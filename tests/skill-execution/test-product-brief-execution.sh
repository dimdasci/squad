#!/usr/bin/env bash
# Test: product-brief full execution
# Runs the complete product-brief workflow against a temp project
# and verifies the output artifact.
#
# This is a SLOW test (5-15 minutes). Run with: --tier execution
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Test: product-brief full execution ==="
echo ""

# Create temp project with product_home
PROJECT_DIR=$(create_test_project)
PRODUCT_HOME="$PROJECT_DIR"
BRIEF_PATH="$PRODUCT_HOME/product/brief.md"

echo "Project dir: $PROJECT_DIR"
echo "Expected artifact: $BRIEF_PATH"
echo ""

# Copy context fixture into the project
cp "$SCRIPT_DIR/fixtures/product-context.md" "$PROJECT_DIR/README.md"

# Build a rich prompt that provides all context upfront
# so the agent can produce a brief without interactive questions
PROMPT="Use the product-brief skill to create a product brief.

Here is all the context you need:

Problem: Remote team leads have no visibility into whether agreed-upon team practices are actually happening. They find out weeks later when quality drops. Existing tools like Jira and Slack track tasks, not habits.

Users: Remote team leads managing 5-15 people across timezones who want visibility without micromanaging. Individual contributors who want to show consistency without writing status reports.

When I notice my team's code review quality dropping, I want to see which practices we agreed on are actually being followed, so I can address the gap before it becomes a crisis.

Solution boundary:
- IS: A habit tracking dashboard for team practices, Slack integration for check-ins, weekly trend reports for team leads
- IS NOT: A task manager, a gamification app, a time tracker, a performance review tool

Success criteria: 80% of team members complete daily check-ins within 2 weeks of onboarding. Team leads report improved visibility in post-pilot survey by week 4.

Appetite: 4 weeks, solo developer. No-gos: no gamification, no individual performance scoring, no replacing existing project management tools.

Product home is: $PRODUCT_HOME

Write the brief, run the review, and present for approval. When asking for CPTO approval, just write AWAITING CPTO APPROVAL and stop."

# Run the skill with enough turns for produce -> review -> present cycle
TIMESTAMP=$(date +%s)
LOG_FILE="/tmp/squad-tests/${TIMESTAMP}/execution/product-brief/claude-output.json"
mkdir -p "$(dirname "$LOG_FILE")"

echo "Running product-brief skill (this may take several minutes)..."
echo ""

cd "$PROJECT_DIR"
run_claude_json "$PROMPT" "$LOG_FILE" 600 30

echo ""
echo "=== Checking Results ==="
echo ""

# Test 1: Brief artifact was created
echo "Test 1: Artifact exists..."
if [ -f "$BRIEF_PATH" ]; then
    echo "  [PASS] Brief created at $BRIEF_PATH"
else
    echo "  [FAIL] Brief not found at $BRIEF_PATH"
    echo "  Files in project:"
    find "$PROJECT_DIR" -type f | sed 's/^/    /'
    cleanup_test_project "$PROJECT_DIR"
    exit 1
fi

# Read the brief for content checks
BRIEF_CONTENT=$(cat "$BRIEF_PATH")

# Test 2: Brief has required sections
echo ""
echo "Test 2: Required sections..."
assert_contains "$BRIEF_CONTENT" "How [Mm]ight [Ww]e\|HMW" "Has HMW question" || exit 1
assert_contains "$BRIEF_CONTENT" "When.*I want.*so I can\|JTBD\|[Jj]ob [Ss]tor" "Has JTBD job stories" || exit 1
assert_contains "$BRIEF_CONTENT" "IS NOT\|is not\|Is Not" "Has IS NOT list" || exit 1
assert_contains "$BRIEF_CONTENT" "[Ss]uccess [Cc]riteria\|[Mm]easurable" "Has success criteria section" || exit 1
assert_contains "$BRIEF_CONTENT" "[Aa]ppetite\|[Cc]onstraint" "Has appetite/constraints section" || exit 1
assert_contains "$BRIEF_CONTENT" "[Nn]o.go\|will not" "Has no-gos" || exit 1

# Test 3: No architecture leaked into the brief
echo ""
echo "Test 3: No architecture leakage..."
assert_not_contains "$BRIEF_CONTENT" "React\|Node\.js\|PostgreSQL\|MongoDB\|REST API\|GraphQL\|Docker\|Kubernetes" "No tech stack in brief" || true

# Test 4: Review skill was invoked
echo ""
echo "Test 4: Review invocation..."
assert_skill_triggered "$LOG_FILE" "product-brief-review" "Review skill was invoked" || true

# Test 5: CPTO approval was requested
echo ""
echo "Test 5: CPTO approval..."
if grep -qi "CPTO\|approval\|approve" "$LOG_FILE"; then
    echo "  [PASS] CPTO approval requested"
else
    echo "  [FAIL] No CPTO approval request found in transcript"
fi

echo ""
echo "=== Execution test complete ==="
echo ""
echo "Brief artifact: $BRIEF_PATH"
echo "Session log: $LOG_FILE"

# Cleanup
cleanup_test_project "$PROJECT_DIR"
