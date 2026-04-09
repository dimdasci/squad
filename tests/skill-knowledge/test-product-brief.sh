#!/usr/bin/env bash
# Test: product-brief skill knowledge
# Verifies that Claude loaded the skill and understands its process
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Test: product-brief skill knowledge ==="
echo ""

# Test 1: Knows the checklist steps and their order
echo "Test 1: Checklist order..."

output=$(run_claude_knowledge "In the product-brief skill, what are the main steps in order? List them briefly." 60)

assert_contains "$output" "problem\|Problem" "Mentions problem framing" || exit 1
assert_contains "$output" "user\|User\|JTBD" "Mentions target users" || exit 1
assert_contains "$output" "review\|Review" "Mentions review step" || exit 1
assert_order "$output" "problem\|Problem" "review\|Review" "Problem framing before review" || exit 1
assert_order "$output" "review\|Review" "approv\|CPTO" "Review before approval" || exit 1

echo ""

# Test 2: Knows problem framing uses open-ended questions
echo "Test 2: Open-ended question requirement..."

output=$(run_claude_knowledge "In the product-brief skill, how should problem framing questions be asked? Should the agent use multiple-choice or open-ended questions?" 60)

assert_contains "$output" "open-ended\|open ended" "Mentions open-ended questions" || exit 1
assert_contains "$output" "not.*multiple.choice\|no.*multiple.choice\|avoid.*multiple.choice\|never.*multiple.choice\|NOT.*predefined\|not.*predefined\|never.*predefined" "Warns against multiple-choice" || exit 1

echo ""

# Test 3: Knows review runs in fresh context
echo "Test 3: Fresh context review..."

output=$(run_claude_knowledge "In the product-brief skill, how does the independent review work? Does the reviewer see the conversation history?" 60)

assert_contains "$output" "fresh\|independent\|fork\|separate\|isolated" "Review uses fresh context" || exit 1
assert_contains "$output" "product-brief-review\|review skill\|context.*fork\|fork.*context\|separate.*subagent\|isolated.*subagent" "Identifies the review mechanism" || exit 1

echo ""

# Test 4: Knows FAIL findings have three response modes
echo "Test 4: Address findings modes..."

output=$(run_claude_knowledge "In the product-brief skill step 9, when the review returns FAIL, what are the different ways the agent can respond to each finding?" 60)

assert_contains "$output" "fix\|Fix" "Mentions fixing" || exit 1
assert_contains "$output" "option\|path\|approach\|multiple" "Mentions multiple paths" || exit 1
assert_contains "$output" "disagree\|challenge\|reasoning" "Mentions challenging findings" || exit 1

echo ""

# Test 5: Knows artifact output path
echo "Test 5: Artifact path..."

output=$(run_claude_knowledge "Where does the product-brief skill save the brief artifact? What is the file path?" 60)

assert_contains "$output" "product_home\|product/brief.md" "Knows artifact path" || exit 1

echo ""

echo "=== All product-brief knowledge tests passed ==="
