#!/usr/bin/env bash
# Test: design-system-review skill knowledge
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Test: design-system-review skill knowledge ==="
echo ""

# Test 1: Verdict taxonomy and dual grading
echo "Test 1: Verdict + dual grade..."
output=$(run_claude_knowledge "In the design-system-review skill, what verdict values does it emit, and what is the dual grading scheme?" 60)
assert_contains "$output" "PASS\|pass" "Mentions PASS" || exit 1
assert_contains "$output" "PASS_WITH_NOTES\|pass with notes" "Mentions PASS_WITH_NOTES" || exit 1
assert_contains "$output" "FAIL\|fail" "Mentions FAIL" || exit 1
assert_contains "$output" "design quality\|A\|B\|C" "Mentions design-quality grade" || exit 1
assert_contains "$output" "slop\|clean\|minor-slop\|material-slop" "Mentions slop grade" || exit 1
echo ""

# Test 2: Impact triage
echo "Test 2: Impact triage..."
output=$(run_claude_knowledge "In the design-system-review skill, how are findings triaged, and what are the impact categories?" 60)
assert_contains "$output" "High\|high" "Mentions High triage" || exit 1
assert_contains "$output" "Medium\|medium" "Mentions Medium triage" || exit 1
assert_contains "$output" "Polish\|polish" "Mentions Polish triage" || exit 1
echo ""

# Test 3: Anti-slop catalog
echo "Test 3: Anti-slop catalog..."
output=$(run_claude_knowledge "In the design-system-review skill, what is the anti-slop catalog, and what two halves does it cover?" 60)
assert_contains "$output" "doc.prose\|principle\|voice\|vague" "Mentions doc-prose slop half" || exit 1
assert_contains "$output" "visual\|HTML\|preview\|gradient\|emoji" "Mentions visual/content slop half" || exit 1
echo ""

# Test 4: Fork context + does not rewrite
echo "Test 4: Fork context + no rewrite..."
output=$(run_claude_knowledge "Does the design-system-review skill rewrite the Design System Doc, and what context does it run in?" 60)
assert_contains "$output" "fork\|fresh\|isolated\|separate" "Mentions fork/fresh context" || exit 1
assert_not_contains "$output" "rewrite\|rewrites\|edits the doc\|modifies the doc" "Does NOT rewrite" || exit 1
echo ""

# Test 5: Adaptive-scope discipline
echo "Test 5: Adaptive-scope discipline..."
output=$(run_claude_knowledge "In the design-system-review skill, how does it handle sections for surfaces that are or aren't declared in the architecture record?" 60)
assert_contains "$output" "fabricated\|invented\|not declared\|undeclared" "Flags fabricated sections for undeclared surfaces" || exit 1
assert_contains "$output" "legitimately absent\|not required\|skip\|don.t flag" "Does not flag legitimately absent sections" || exit 1
echo ""

echo "=== All design-system-review knowledge tests passed ==="
