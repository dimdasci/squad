#!/usr/bin/env bash
# Test: architecture-record full execution
# Runs the complete architecture-record workflow against a temp project
# with an approved brief, and verifies the output artifact.
#
# This is a SLOW test (5-15 minutes). Run with: --tier execution
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Test: architecture-record full execution ==="
echo ""

# Create temp project with product_home and approved brief
PROJECT_DIR=$(create_test_project)
PRODUCT_HOME="$PROJECT_DIR"
BRIEF_PATH="$PRODUCT_HOME/product/brief.md"
RECORD_PATH="$PRODUCT_HOME/architecture/record.md"

# Set up the approved brief fixture
cp "$SCRIPT_DIR/fixtures/architecture-context-brief.md" "$BRIEF_PATH"
mkdir -p "$PRODUCT_HOME/architecture"

echo "Project dir: $PROJECT_DIR"
echo "Brief: $BRIEF_PATH"
echo "Expected artifact: $RECORD_PATH"
echo ""

# Build a rich prompt with enough context for non-interactive execution
PROMPT="Use the architecture-record skill to create the architecture for this product.

The approved product brief is at: $BRIEF_PATH
Product home is: $PRODUCT_HOME

Technical context from the team lead:
- Team uses Python (FastAPI) for backends and React for frontends
- Deployed on Railway (PaaS, no Kubernetes)
- Slack workspace already set up with bot permissions
- PostgreSQL preferred for data storage
- Solo developer, keep it simple — monorepo, single deploy

Skip the interactive questions — all technical context is provided above.
Create the architecture record, run the review, and present for approval.
When asking for CPTO approval, just write AWAITING CPTO APPROVAL and stop."

# Run the skill
TIMESTAMP=$(date +%s)
LOG_FILE="/tmp/squad-tests/${TIMESTAMP}/execution/architecture-record/claude-output.json"
mkdir -p "$(dirname "$LOG_FILE")"

echo "Running architecture-record skill (this may take several minutes)..."
echo ""

cd "$PROJECT_DIR"
run_claude_json "$PROMPT" "$LOG_FILE" 600 30

echo ""
echo "=== Checking Results ==="
echo ""

# Test 1: Architecture record was created
echo "Test 1: Artifact exists..."
if [ -f "$RECORD_PATH" ]; then
    echo "  [PASS] Record created at $RECORD_PATH"
else
    echo "  [FAIL] Record not found at $RECORD_PATH"
    echo "  Files in project:"
    find "$PROJECT_DIR" -type f | sed 's/^/    /'
    cleanup_test_project "$PROJECT_DIR"
    exit 1
fi

# Read the record for content checks
RECORD_CONTENT=$(cat "$RECORD_PATH")

# Test 2: Has required sections
echo ""
echo "Test 2: Required sections..."
assert_contains "$RECORD_CONTENT" "System Context\|C4 L1\|Level 1" "Has C4 L1 section" || exit 1
assert_contains "$RECORD_CONTENT" "Container\|C4 L2\|Level 2" "Has C4 L2 section" || exit 1
assert_contains "$RECORD_CONTENT" "ADR-\|Architecture Decision" "Has ADR section" || exit 1
assert_contains "$RECORD_CONTENT" "Technology Landscape\|Technology.*Research\|Research.*Summary" "Has technology landscape section" || exit 1

# Test 3: Has Mermaid diagrams
echo ""
echo "Test 3: Mermaid diagrams..."
assert_contains "$RECORD_CONTENT" '```mermaid' "Contains mermaid code blocks" || exit 1

# Test 4: Mermaid diagrams are valid via @mermaid-js/mermaid-cli
# First run downloads headless Chromium (~400MB), cached after.
echo ""
echo "Test 4: Mermaid validation..."
if command -v npx &> /dev/null; then
    MMDC_OUT=$(mktemp --suffix=.svg)
    if mmdc_output=$(npx -y -p @mermaid-js/mermaid-cli mmdc -i "$RECORD_PATH" -o "$MMDC_OUT" 2>&1); then
        echo "  [PASS] Mermaid diagrams rendered by mmdc"
    else
        echo "  [FAIL] mmdc rejected a diagram"
        echo "$mmdc_output" | head -20 | sed 's/^/    /'
        rm -f "$MMDC_OUT"
        cleanup_test_project "$PROJECT_DIR"
        exit 1
    fi
    rm -f "$MMDC_OUT"
else
    echo "  [SKIP] npx not available for mermaid validation"
fi

# Test 5: Has companion tables
echo ""
echo "Test 5: Companion tables..."
assert_contains "$RECORD_CONTENT" "| Actor\|| Container\|| System" "Has companion tables" || true

# Test 6: ADRs have Nygard fields
echo ""
echo "Test 6: ADR format..."
assert_contains "$RECORD_CONTENT" "Status.*:.*proposed\|Status.*:.*accepted" "ADR has Status field" || true
assert_contains "$RECORD_CONTENT" "Context.*:" "ADR has Context field" || true
assert_contains "$RECORD_CONTENT" "Decision.*:" "ADR has Decision field" || true
assert_contains "$RECORD_CONTENT" "Consequence" "ADR has Consequences field" || true

# Test 7: No implementation details leaked
echo ""
echo "Test 7: No implementation leakage..."
assert_not_contains "$RECORD_CONTENT" "def \|function \|class \|import \|require(" "No code in architecture record" || true

# Test 8: Review skill was invoked
echo ""
echo "Test 8: Review invocation..."
assert_skill_triggered "$LOG_FILE" "architecture-record-review" "Review skill was invoked" || true

# Test 9: CPTO approval was requested
echo ""
echo "Test 9: CPTO approval..."
if grep -qi "CPTO\|approval\|approve" "$LOG_FILE"; then
    echo "  [PASS] CPTO approval requested"
else
    echo "  [FAIL] No CPTO approval request found in transcript"
fi

echo ""
echo "=== Execution test complete ==="
echo ""
echo "Architecture record: $RECORD_PATH"
echo "Session log: $LOG_FILE"

# Cleanup
cleanup_test_project "$PROJECT_DIR"
