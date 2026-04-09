#!/usr/bin/env bash
# Run all skill triggering tests
# Usage: ./run-all.sh
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPTS_DIR="$SCRIPT_DIR/prompts"

# Each entry: "expected-skill prompt-file"
TESTS=(
    "product-brief product-brief-explicit.txt"
    "product-brief product-brief-implicit.txt"
    "product-brief-review product-brief-negative.txt"
)

echo "=== Running Skill Triggering Tests ==="
echo ""

PASSED=0
FAILED=0
RESULTS=()

for entry in "${TESTS[@]}"; do
    skill=$(echo "$entry" | cut -d' ' -f1)
    prompt_file="$PROMPTS_DIR/$(echo "$entry" | cut -d' ' -f2)"

    if [ ! -f "$prompt_file" ]; then
        echo "  [SKIP] No prompt file: $prompt_file"
        continue
    fi

    test_name="$skill ($(basename "$prompt_file" .txt))"
    echo "Testing: $test_name"

    if "$SCRIPT_DIR/run-test.sh" "$skill" "$prompt_file" 3 2>&1 | tee "/tmp/squad-trigger-test-$skill.log"; [[ ${PIPESTATUS[0]} -eq 0 ]]; then
        PASSED=$((PASSED + 1))
        RESULTS+=("[PASS] $test_name")
    else
        FAILED=$((FAILED + 1))
        RESULTS+=("[FAIL] $test_name")
    fi

    echo ""
    echo "---"
    echo ""
done

echo ""
echo "=== Summary ==="
for result in "${RESULTS[@]}"; do
    echo "  $result"
done
echo ""
echo "Passed: $PASSED"
echo "Failed: $FAILED"

if [ $FAILED -gt 0 ]; then
    exit 1
fi
