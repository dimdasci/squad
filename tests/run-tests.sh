#!/usr/bin/env bash
# Test runner for squad skill tests
# Usage: ./run-tests.sh [options]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "========================================"
echo " Squad Skills Test Suite"
echo "========================================"
echo ""
echo "Repository: $REPO_ROOT"
echo "Test time: $(date)"
echo "Claude version: $(claude --version 2>/dev/null || echo 'not found')"
echo ""

# Check if Claude Code is available
if ! command -v claude &> /dev/null; then
    echo "ERROR: Claude Code CLI not found"
    echo "Install Claude Code first: https://code.claude.com"
    exit 1
fi

# Parse arguments
VERBOSE=false
SPECIFIC_TEST=""
TIMEOUT=""
TIMEOUT_EXPLICIT=false
TIER="all"

while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --test|-t)
            SPECIFIC_TEST="$2"
            shift 2
            ;;
        --timeout)
            TIMEOUT="$2"
            TIMEOUT_EXPLICIT=true
            shift 2
            ;;
        --tier)
            TIER="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --verbose, -v        Show verbose output"
            echo "  --test, -t NAME      Run only the specified test file"
            echo "  --timeout SECONDS    Set timeout per test (default: 600 fast tier, 1500 execution tier)"
            echo "  --tier TIER          Run specific tier: knowledge, triggering, execution, all (default: all)"
            echo "  --help, -h           Show this help"
            echo ""
            echo "Tiers:"
            echo "  knowledge    Fast (~30s) — does Claude understand the skill?"
            echo "  triggering   Fast (~30s) — does the right skill activate?"
            echo "  execution    Slow (5-15min) — does the full workflow produce correct output?"
            echo "  all          Run knowledge + triggering (use --tier execution explicitly for slow tests)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Default timeout depends on tier: execution tests can run up to ~15 min
# internally (run_claude_json budget = 900s in the current scripts), so
# the outer wrapper needs at least that + overhead. Fast tier batches
# cap around 6-7 min.
if [ "$TIMEOUT_EXPLICIT" = false ]; then
    if [ "$TIER" = "execution" ]; then
        TIMEOUT=1500
    else
        TIMEOUT=600
    fi
fi

# Collect tests to run
tests=()

if [ -n "$SPECIFIC_TEST" ]; then
    tests=("$SPECIFIC_TEST")
else
    case "$TIER" in
        knowledge)
            for f in "$SCRIPT_DIR"/skill-knowledge/test-*.sh; do
                [ -f "$f" ] && tests+=("$f")
            done
            ;;
        triggering)
            tests+=("$SCRIPT_DIR/skill-triggering/run-all.sh")
            ;;
        execution)
            for f in "$SCRIPT_DIR"/skill-execution/test-*.sh; do
                [ -f "$f" ] && tests+=("$f")
            done
            ;;
        all)
            for f in "$SCRIPT_DIR"/skill-knowledge/test-*.sh; do
                [ -f "$f" ] && tests+=("$f")
            done
            if [ -f "$SCRIPT_DIR/skill-triggering/run-all.sh" ]; then
                tests+=("$SCRIPT_DIR/skill-triggering/run-all.sh")
            fi
            echo "Note: Execution tests excluded from 'all'. Use --tier execution to run them."
            echo ""
            ;;
    esac
fi

if [ ${#tests[@]} -eq 0 ]; then
    echo "No tests found for tier: $TIER"
    exit 0
fi

# Track results
passed=0
failed=0
skipped=0

# Run each test
for test in "${tests[@]}"; do
    test_name=$(basename "$test")
    echo "----------------------------------------"
    echo "Running: $test_name"
    echo "----------------------------------------"

    if [ ! -f "$test" ]; then
        echo "  [SKIP] Test file not found: $test_name"
        skipped=$((skipped + 1))
        continue
    fi

    chmod +x "$test" 2>/dev/null || true

    start_time=$(date +%s)

    if [ "$VERBOSE" = true ]; then
        if timeout "$TIMEOUT" bash "$test"; then
            end_time=$(date +%s)
            duration=$((end_time - start_time))
            echo ""
            echo "  [PASS] $test_name (${duration}s)"
            passed=$((passed + 1))
        else
            exit_code=$?
            end_time=$(date +%s)
            duration=$((end_time - start_time))
            echo ""
            if [ $exit_code -eq 124 ]; then
                echo "  [FAIL] $test_name (timeout after ${TIMEOUT}s)"
            else
                echo "  [FAIL] $test_name (${duration}s)"
            fi
            failed=$((failed + 1))
        fi
    else
        if output=$(timeout "$TIMEOUT" bash "$test" 2>&1); then
            end_time=$(date +%s)
            duration=$((end_time - start_time))
            echo "  [PASS] (${duration}s)"
            passed=$((passed + 1))
        else
            exit_code=$?
            end_time=$(date +%s)
            duration=$((end_time - start_time))
            if [ $exit_code -eq 124 ]; then
                echo "  [FAIL] (timeout after ${TIMEOUT}s)"
            else
                echo "  [FAIL] (${duration}s)"
            fi
            echo ""
            echo "  Output:"
            echo "$output" | sed 's/^/    /'
            failed=$((failed + 1))
        fi
    fi

    echo ""
done

# Summary
echo "========================================"
echo " Test Results Summary"
echo "========================================"
echo ""
echo "  Passed:  $passed"
echo "  Failed:  $failed"
echo "  Skipped: $skipped"
echo ""

if [ "$TIER" = "all" ]; then
    echo "Note: Execution tests were not run (they take 5-15 minutes)."
    echo "Use --tier execution to run full workflow tests."
    echo ""
fi

if [ $failed -gt 0 ]; then
    echo "STATUS: FAILED"
    exit 1
else
    echo "STATUS: PASSED"
    exit 0
fi
