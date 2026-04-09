#!/usr/bin/env bash
# Test skill triggering with a prompt
# Usage: ./run-test.sh <expected-skill> <prompt-file> [max-turns]
#
# Tests whether Claude triggers the expected skill given a prompt.
# Works for both explicit requests and implicit triggering.
set -e

EXPECTED_SKILL="$1"
PROMPT_FILE="$2"
MAX_TURNS="${3:-3}"

if [ -z "$EXPECTED_SKILL" ] || [ -z "$PROMPT_FILE" ]; then
    echo "Usage: $0 <expected-skill> <prompt-file> [max-turns]"
    echo "Example: $0 product-brief ./prompts/product-brief-explicit.txt"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

TIMESTAMP=$(date +%s)
OUTPUT_DIR="/tmp/squad-tests/${TIMESTAMP}/skill-triggering/${EXPECTED_SKILL}"
mkdir -p "$OUTPUT_DIR"

PROMPT=$(cat "$PROMPT_FILE")

echo "=== Skill Triggering Test ==="
echo "Expected skill: $EXPECTED_SKILL"
echo "Prompt: $PROMPT"
echo ""

# Create minimal project directory
PROJECT_DIR="$OUTPUT_DIR/project"
mkdir -p "$PROJECT_DIR"

# Copy prompt for reference
cp "$PROMPT_FILE" "$OUTPUT_DIR/prompt.txt"

# Run Claude
LOG_FILE="$OUTPUT_DIR/claude-output.json"
cd "$PROJECT_DIR"

run_claude_json "$PROMPT" "$LOG_FILE" 300 "$MAX_TURNS"

echo "=== Results ==="

assert_skill_triggered "$LOG_FILE" "$EXPECTED_SKILL" "Skill '$EXPECTED_SKILL' triggered" || exit 1
assert_no_premature_action "$LOG_FILE" "No premature action before skill load" || true

# Show what skills were triggered
echo ""
echo "All skills triggered:"
grep -o '"skill":"[^"]*"' "$LOG_FILE" 2>/dev/null | sort -u | sed 's/^/  /' || echo "  (none)"

echo ""
echo "Full log: $LOG_FILE"
