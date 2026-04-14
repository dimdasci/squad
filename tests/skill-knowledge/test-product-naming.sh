#!/usr/bin/env bash
# Test: product-naming skill knowledge
# Verifies that Claude loaded the skill and understands its process
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

echo "=== Test: product-naming skill knowledge ==="
echo ""

# Test 1: Hard gate on approved brief
echo "Test 1: Hard gate on approved brief..."

output=$(run_claude_knowledge "In the product-naming skill, what happens if no approved product brief exists? Can the skill run without one?" 60)

assert_contains "$output" "stop\|cannot\|hard.gate\|requires\|need.*brief\|brief.*required" "Refuses to run without brief" || exit 1
assert_contains "$output" "product-brief\|squad:product-brief" "Points to product-brief skill" || exit 1

echo ""

# Test 2: Knows the candidate generation method
echo "Test 2: Parallel subagent generation..."

output=$(run_claude_knowledge "In the product-naming skill, how are candidate names generated? Is it a single LLM call, or something else?" 60)

assert_contains "$output" "parallel\|4 subagent\|four subagent\|four lens\|4 lens\|dispatch" "Mentions parallel dispatch" || exit 1
assert_contains "$output" "lens\|differentiated\|isolated context" "Mentions differentiated lenses or contexts" || exit 1

echo ""

# Test 3: Knows the three automated filters
echo "Test 3: Three automated filters..."

output=$(run_claude_knowledge "In the product-naming skill, what are the three automated filters applied to the candidate pool?" 60)

assert_contains "$output" "linguistic\|phonetic\|SCRATCH" "Mentions linguistic/SCRATCH filter" || exit 1
assert_contains "$output" "brand collision\|collision search\|WebSearch\|web search" "Mentions brand collision filter" || exit 1
assert_contains "$output" "TLD\|domain\|RDAP\|.com" "Mentions primary TLD probe filter" || exit 1

echo ""

# Test 4: Trademark check is optional
echo "Test 4: Trademark check is optional..."

output=$(run_claude_knowledge "In the product-naming skill, is the trademark check mandatory? What does the skill do for trademark validation?" 60)

assert_contains "$output" "optional\|not mandatory\|skip\|may.*skip" "Mentions trademark is optional" || exit 1
assert_contains "$output" "USPTO\|WIPO\|registry\|registries" "Mentions trademark registries" || exit 1
assert_contains "$output" "human\|user\|CPTO\|manual" "Mentions human-run not automated" || exit 1

echo ""

# Test 5: Artifact location
echo "Test 5: Artifact path..."

output=$(run_claude_knowledge "In the product-naming skill, where is the final naming artifact saved?" 60)

assert_contains "$output" "identity/naming" "Mentions identity/naming path" || exit 1
assert_contains "$output" "user_config.product_home\|product_home" "Uses product_home env var" || exit 1

echo ""

# Test 6: Two CPTO gates
echo "Test 6: Two CPTO gates in process..."

output=$(run_claude_knowledge "In the product-naming skill, how many times does the CPTO get involved during the process before final approval? What are the gates?" 60)

assert_contains "$output" "two\|2\|shortlist\|finalist" "Mentions multiple gates" || exit 1
assert_contains "$output" "shortlist\|pick" "Mentions shortlist pick" || exit 1
assert_contains "$output" "final\|winner\|chosen" "Mentions final pick" || exit 1

echo ""

echo "=== All product-naming knowledge tests passed ==="
