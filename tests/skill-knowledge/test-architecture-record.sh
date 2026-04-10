#!/usr/bin/env bash
# Test: architecture-record skill knowledge
# Verifies that Claude loaded the skill and understands its process
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Test: architecture-record skill knowledge ==="
echo ""

# Test 1: Knows the two-phase process and step order
echo "Test 1: Two-phase process..."

output=$(run_claude_knowledge "In the architecture-record skill, what are the two phases and their main steps? List them briefly." 60)

assert_contains "$output" "survey\|Survey\|research\|Research" "Mentions survey/research phase" || exit 1
assert_contains "$output" "record\|Record\|C4\|component" "Mentions record/C4 phase" || exit 1
assert_order "$output" "brief\|Brief\|context" "C4\|diagram\|component map" "Brief analysis before C4 diagrams" || exit 1

echo ""

# Test 2: Knows Mermaid diagram rules
echo "Test 2: Mermaid rules..."

output=$(run_claude_knowledge "In the architecture-record skill, what are the rules for Mermaid diagrams? What should you avoid?" 60)

assert_contains "$output" "label\|Label\|short\|word" "Mentions short labels" || exit 1
assert_contains "$output" "style\|styling\|color\|CSS" "Mentions no styling" || exit 1
assert_contains "$output" "valid\|validat\|mmdc" "Mentions validation" || exit 1

echo ""

# Test 3: Knows ADR format
echo "Test 3: ADR format..."

output=$(run_claude_knowledge "In the architecture-record skill, what format should Architecture Decision Records follow? What fields are required?" 60)

assert_contains "$output" "Nygard\|nygard\|Status\|status" "Mentions Nygard or Status field" || exit 1
assert_contains "$output" "Context\|context" "Mentions Context field" || exit 1
assert_contains "$output" "Decision\|decision" "Mentions Decision field" || exit 1
assert_contains "$output" "Consequence\|consequence" "Mentions Consequences field" || exit 1

echo ""

# Test 4: Knows review has three passes
echo "Test 4: Review passes..."

output=$(run_claude_knowledge "In the architecture-record-review skill, what are the three review passes? What does each one check?" 60)

assert_contains "$output" "structural\|Structural\|completeness\|Completeness" "Mentions structural completeness" || exit 1
assert_contains "$output" "fitness\|Fitness" "Mentions architectural fitness" || exit 1
assert_contains "$output" "brief\|Brief\|alignment\|Alignment" "Mentions brief alignment" || exit 1

echo ""

echo "=== All architecture-record knowledge tests passed ==="
