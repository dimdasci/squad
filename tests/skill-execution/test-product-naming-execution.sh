#!/usr/bin/env bash
# Test: product-naming full execution
# Runs the complete product-naming workflow against a temp project
# with an approved brief, and verifies the output artifact.
#
# This is a SLOW test (5-15 minutes). Run with: --tier execution
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Test: product-naming full execution ==="
echo ""

# Create temp project with product_home and approved brief
PROJECT_DIR=$(create_test_project)
PRODUCT_HOME="$PROJECT_DIR"
BRIEF_PATH="$PRODUCT_HOME/product/brief.md"
NAMING_PATH="$PRODUCT_HOME/identity/naming.md"

# Set up the approved brief fixture
mkdir -p "$PRODUCT_HOME/product"
mkdir -p "$PRODUCT_HOME/identity"
cp "$SCRIPT_DIR/fixtures/product-naming-brief.md" "$BRIEF_PATH"

echo "Project dir: $PROJECT_DIR"
echo "Brief: $BRIEF_PATH"
echo "Expected artifact: $NAMING_PATH"
echo ""

# Build a rich prompt with enough context for non-interactive execution
PROMPT="Use the product-naming skill to choose a name for this product.

The approved product brief is at: $BRIEF_PATH
Product home is: $PRODUCT_HOME

Run the full naming process. For any open-ended question about
positioning, use these defaults:
- Tone: practical, lightly playful, founder-direct
- Must-avoid: anything that sounds like a corporate productivity SaaS

For the trademark check at step 7, mark all jurisdictions as 'skipped'
for all finalists — this test does not actually run trademark searches.

For the final pick at Gate 2, accept Claude's leaned recommendation.

When asking for CPTO approval at step 13, just write AWAITING CPTO
APPROVAL and stop."

# Run the skill
TIMESTAMP=$(date +%s)
LOG_FILE="/tmp/squad-tests/${TIMESTAMP}/execution/product-naming/claude-output.json"
mkdir -p "$(dirname "$LOG_FILE")"

echo "Running product-naming skill (this may take several minutes)..."
echo ""

cd "$PROJECT_DIR"
run_claude_json "$PROMPT" "$LOG_FILE" 900 50

echo ""
echo "=== Checking Results ==="
echo ""

# Test 1: Artifact was created
echo "Test 1: Artifact exists..."
if [ -f "$NAMING_PATH" ]; then
    echo "  [PASS] Naming artifact created at $NAMING_PATH"
else
    echo "  [FAIL] Naming artifact not found at $NAMING_PATH"
    echo "  Files in project:"
    find "$PROJECT_DIR" -type f | sed 's/^/    /'
    cleanup_test_project "$PROJECT_DIR"
    exit 1
fi

# Read the artifact for content checks
NAMING_CONTENT=$(cat "$NAMING_PATH")

# Test 2: Has required header fields
echo ""
echo "Test 2: Required header fields..."
assert_contains "$NAMING_CONTENT" "Status:" "Has Status field" || exit 1
assert_contains "$NAMING_CONTENT" "Date:" "Has Date field" || exit 1
assert_contains "$NAMING_CONTENT" "Brief:" "Has Brief reference" || exit 1

# Test 3: Status is draft (skill should not auto-approve)
echo ""
echo "Test 3: Status is draft, not approved..."
assert_contains "$NAMING_CONTENT" "Status: draft" "Status remains draft" || exit 1

# Test 4: Has chosen name section
echo ""
echo "Test 4: Chosen name section..."
assert_contains "$NAMING_CONTENT" "## Chosen name" "Has chosen name section" || exit 1
assert_contains "$NAMING_CONTENT" "Category:" "Has category field" || exit 1
assert_contains "$NAMING_CONTENT" "Pronunciation:" "Has pronunciation field" || exit 1
assert_contains "$NAMING_CONTENT" "Stylization:" "Has stylization field" || exit 1

# Test 5: Has philosophy section
echo ""
echo "Test 5: Philosophy section..."
assert_contains "$NAMING_CONTENT" "## Philosophy" "Has philosophy section" || exit 1

# Test 6: Has all 5 usage rules subsections
echo ""
echo "Test 6: Usage rules subsections..."
assert_contains "$NAMING_CONTENT" "Approved short forms\|short forms" "Has approved short forms" || exit 1
assert_contains "$NAMING_CONTENT" "Forbidden variants" "Has forbidden variants" || exit 1
assert_contains "$NAMING_CONTENT" "How it appears in sentences\|in sentences" "Has sentence usage" || exit 1
assert_contains "$NAMING_CONTENT" "NOT called" "Has not-called section" || exit 1
assert_contains "$NAMING_CONTENT" "Context-specific\|Marketing:\|Product UI:" "Has context-specific usage" || exit 1

# Test 7: Has validation record with all 3 filters
echo ""
echo "Test 7: Validation record — automated filters..."
assert_contains "$NAMING_CONTENT" "Linguistic\|phonetic\|SCRATCH" "Filter 1 recorded" || exit 1
assert_contains "$NAMING_CONTENT" "Brand collision\|collision" "Filter 2 recorded" || exit 1
assert_contains "$NAMING_CONTENT" "TLD\|domain" "Filter 3 recorded" || exit 1

# Test 8: Has trademark table with 3 jurisdictions
echo ""
echo "Test 8: Trademark table..."
assert_contains "$NAMING_CONTENT" "USPTO" "USPTO row present" || exit 1
assert_contains "$NAMING_CONTENT" "WIPO" "WIPO row present" || exit 1
assert_contains "$NAMING_CONTENT" "EUIPO" "EUIPO row present" || exit 1
assert_contains "$NAMING_CONTENT" "skipped" "Skipped state recorded honestly" || exit 1

# Test 9: Has generation context
echo ""
echo "Test 9: Generation context..."
assert_contains "$NAMING_CONTENT" "Pool size\|pool size" "Pool size recorded" || exit 1
assert_contains "$NAMING_CONTENT" "Lens 2\|lens 2\|adjacent domain" "Lens 2 domain recorded" || exit 1

# Test 10: Review skill was invoked
echo ""
echo "Test 10: Review invocation..."
assert_skill_triggered "$LOG_FILE" "product-naming-review" "Review skill was invoked" || true

# Test 11: CPTO approval was requested
echo ""
echo "Test 11: CPTO approval requested..."
if grep -qi "AWAITING CPTO APPROVAL\|CPTO\|approval" "$LOG_FILE"; then
    echo "  [PASS] CPTO approval requested"
else
    echo "  [FAIL] No CPTO approval request found in transcript"
fi

echo ""
echo "=== Execution test complete ==="
echo ""
echo "Naming artifact: $NAMING_PATH"
echo "Session log: $LOG_FILE"

# Cleanup
cleanup_test_project "$PROJECT_DIR"
