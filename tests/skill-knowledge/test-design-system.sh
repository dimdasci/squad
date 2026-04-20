#!/usr/bin/env bash
# Test: design-system skill knowledge
# Verifies that Claude loaded the skill and understands its process
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Test: design-system skill knowledge ==="
echo ""

# Test 1: Knows the seven phases and prerequisite gate
echo "Test 1: Seven phases and hard gate..."
output=$(run_claude_knowledge "In the design-system skill, what are the seven phases and which phase is a hard prerequisite gate? List the phases briefly." 60)
assert_contains "$output" "prereq\|prerequisite\|Phase 1\|hard gate\|HARD-GATE" "Mentions prerequisite gate" || exit 1
assert_contains "$output" "existing\|pre-check\|update.*fresh\|archive" "Mentions existing-doc pre-check" || exit 1
assert_contains "$output" "identity\|naming\|product-naming" "Mentions product identity / naming check" || exit 1
assert_contains "$output" "research\|WebFetch\|WebSearch" "Mentions inline research" || exit 1
assert_contains "$output" "draft\|preview\|HTML" "Mentions draft + preview" || exit 1
assert_contains "$output" "validation\|review\|design-system-review" "Mentions fork validation" || exit 1
assert_contains "$output" "finalize\|approval\|Decisions Log" "Mentions finalize" || exit 1
echo ""

# Test 2: Knows SAFE/RISK applies only to visual language + voice/tone
echo "Test 2: SAFE/RISK scope..."
output=$(run_claude_knowledge "In the design-system skill, which categories use SAFE vs RISK framing, and which use plain one-line 'because' rationale instead?" 60)
assert_contains "$output" "visual language\|visual\|typography\|palette" "Mentions visual language for SAFE/RISK" || exit 1
assert_contains "$output" "voice\|tone" "Mentions voice/tone for SAFE/RISK" || exit 1
assert_contains "$output" "because\|rationale\|one.line\|plain" "Mentions plain one-line rationale for others" || exit 1
echo ""

# Test 3: Knows adaptive surface scope from architecture-record
echo "Test 3: Adaptive surface scope..."
output=$(run_claude_knowledge "In the design-system skill, how are surfaces (GUI, CLI, API, docs) determined, and what happens to categories for surfaces a product doesn't declare?" 60)
assert_contains "$output" "architecture\|architecture-record\|arch.record\|declared" "Reads declared surfaces from architecture-record" || exit 1
assert_contains "$output" "skip\|omit\|not included\|adaptive\|don.t appear" "Skips/omits categories for undeclared surfaces" || exit 1
assert_not_contains "$output" "N/A\|not applicable placeholder" "No N/A placeholder sections" || exit 1
echo ""

# Test 4: Knows existing-doc pre-check modes
echo "Test 4: Existing-doc pre-check..."
output=$(run_claude_knowledge "In the design-system skill, if a design/system.md already exists, what does the skill do and what options does it offer?" 60)
assert_contains "$output" "update\|(u)" "Offers update mode" || exit 1
assert_contains "$output" "fresh\|(f)" "Offers fresh start mode" || exit 1
assert_contains "$output" "cancel\|(c)\|chat" "Offers cancel / chat escape" || exit 1
assert_contains "$output" "archive\|\.bak\|replaced" "Archives old doc on fresh start" || exit 1
echo ""

# Test 5: Knows preview is a companion HTML artifact
echo "Test 5: HTML preview..."
output=$(run_claude_knowledge "In the design-system skill, what is the HTML preview, where is it written, and what does it contain?" 60)
assert_contains "$output" "preview\|HTML\|html" "Mentions HTML preview" || exit 1
assert_contains "$output" "design/preview\|preview/.*\.html\|<date>\.html" "Mentions preview path" || exit 1
assert_contains "$output" "swatch\|type\|terminal\|component\|error\|sample" "Lists preview content types" || exit 1
echo ""

echo "=== All design-system knowledge tests passed ==="
