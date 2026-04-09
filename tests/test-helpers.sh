#!/usr/bin/env bash
# Helper functions for squad skill tests
# Adapted from Superpowers test infrastructure

# Resolve plugin and project directories
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_DIR="$REPO_ROOT/squad"

# Run Claude Code with a prompt and capture output
# Usage: run_claude "prompt text" [timeout_seconds] [max_turns]
run_claude() {
    local prompt="$1"
    local timeout="${2:-60}"
    local max_turns="${3:-}"
    local output_file
    output_file=$(mktemp)

    local cmd=(claude -p "$prompt"
        --plugin-dir "$PLUGIN_DIR"
        --dangerously-skip-permissions)

    if [ -n "$max_turns" ]; then
        cmd+=(--max-turns "$max_turns")
    fi

    if timeout "$timeout" "${cmd[@]}" > "$output_file" 2>&1; then
        cat "$output_file"
        rm -f "$output_file"
        return 0
    else
        local exit_code=$?
        cat "$output_file" >&2
        rm -f "$output_file"
        return $exit_code
    fi
}

# Run Claude for knowledge questions (max-turns 1 to prevent skill execution)
# Usage: run_claude_knowledge "question" [timeout_seconds]
run_claude_knowledge() {
    run_claude "$1" "${2:-60}" 5
}

# Run Claude with stream-json output for transcript analysis
# Usage: run_claude_json "prompt text" output_file [timeout] [max_turns]
run_claude_json() {
    local prompt="$1"
    local log_file="$2"
    local timeout="${3:-300}"
    local max_turns="${4:-3}"

    timeout "$timeout" claude -p "$prompt" \
        --plugin-dir "$PLUGIN_DIR" \
        --dangerously-skip-permissions \
        --max-turns "$max_turns" \
        --output-format stream-json \
        > "$log_file" 2>&1 || true
}

# Check if output contains a pattern
# Usage: assert_contains "output" "pattern" "test name"
assert_contains() {
    local output="$1"
    local pattern="$2"
    local test_name="${3:-test}"

    if echo "$output" | grep -qi "$pattern"; then
        echo "  [PASS] $test_name"
        return 0
    else
        echo "  [FAIL] $test_name"
        echo "  Expected to find: $pattern"
        echo "  In output (first 500 chars):"
        echo "$output" | head -c 500 | sed 's/^/    /'
        return 1
    fi
}

# Check if output does NOT contain a pattern
# Usage: assert_not_contains "output" "pattern" "test name"
assert_not_contains() {
    local output="$1"
    local pattern="$2"
    local test_name="${3:-test}"

    if echo "$output" | grep -qi "$pattern"; then
        echo "  [FAIL] $test_name"
        echo "  Did not expect to find: $pattern"
        echo "  In output (first 500 chars):"
        echo "$output" | head -c 500 | sed 's/^/    /'
        return 1
    else
        echo "  [PASS] $test_name"
        return 0
    fi
}

# Check if output matches a count
# Usage: assert_count "output" "pattern" expected_count "test name"
assert_count() {
    local output="$1"
    local pattern="$2"
    local expected="$3"
    local test_name="${4:-test}"

    local actual
    actual=$(echo "$output" | grep -ci "$pattern" || echo "0")

    if [ "$actual" -eq "$expected" ]; then
        echo "  [PASS] $test_name (found $actual instances)"
        return 0
    else
        echo "  [FAIL] $test_name"
        echo "  Expected $expected instances of: $pattern"
        echo "  Found $actual instances"
        return 1
    fi
}

# Check if pattern A appears before pattern B
# Usage: assert_order "output" "pattern_a" "pattern_b" "test name"
assert_order() {
    local output="$1"
    local pattern_a="$2"
    local pattern_b="$3"
    local test_name="${4:-test}"

    local line_a line_b
    line_a=$(echo "$output" | grep -ni "$pattern_a" | head -1 | cut -d: -f1)
    line_b=$(echo "$output" | grep -ni "$pattern_b" | head -1 | cut -d: -f1)

    if [ -z "$line_a" ]; then
        echo "  [FAIL] $test_name: pattern A not found: $pattern_a"
        return 1
    fi

    if [ -z "$line_b" ]; then
        echo "  [FAIL] $test_name: pattern B not found: $pattern_b"
        return 1
    fi

    if [ "$line_a" -lt "$line_b" ]; then
        echo "  [PASS] $test_name (A at line $line_a, B at line $line_b)"
        return 0
    else
        echo "  [FAIL] $test_name"
        echo "  Expected '$pattern_a' before '$pattern_b'"
        echo "  But found A at line $line_a, B at line $line_b"
        return 1
    fi
}

# Check if a skill was triggered in stream-json output
# Usage: assert_skill_triggered "log_file" "skill-name" "test name"
assert_skill_triggered() {
    local log_file="$1"
    local skill_name="$2"
    local test_name="${3:-Skill triggered}"

    local skill_pattern='"skill":"([^"]*:)?'"${skill_name}"'"'
    if grep -q '"name":"Skill"' "$log_file" && grep -qE "$skill_pattern" "$log_file"; then
        echo "  [PASS] $test_name"
        return 0
    else
        echo "  [FAIL] $test_name"
        echo "  Skills triggered:"
        grep -o '"skill":"[^"]*"' "$log_file" 2>/dev/null | sort -u | sed 's/^/    /' || echo "    (none)"
        return 1
    fi
}

# Check that no tools were invoked before the Skill tool
# Usage: assert_no_premature_action "log_file" "test name"
assert_no_premature_action() {
    local log_file="$1"
    local test_name="${2:-No premature action}"

    local first_skill_line
    first_skill_line=$(grep -n '"name":"Skill"' "$log_file" | head -1 | cut -d: -f1)

    if [ -z "$first_skill_line" ]; then
        echo "  [FAIL] $test_name: no Skill invocation found"
        return 1
    fi

    local premature
    premature=$(head -n "$first_skill_line" "$log_file" | \
        grep '"type":"tool_use"' | \
        grep -v '"name":"Skill"' | \
        grep -v '"name":"TodoWrite"' | \
        grep -v '"name":"TaskCreate"' | \
        grep -v '"name":"TaskUpdate"' || true)

    if [ -n "$premature" ]; then
        echo "  [FAIL] $test_name"
        echo "  Tools invoked before Skill:"
        echo "$premature" | head -5 | sed 's/^/    /'
        return 1
    else
        echo "  [PASS] $test_name"
        return 0
    fi
}

# Create a temporary test project with product_home structure
# Usage: project_dir=$(create_test_project)
create_test_project() {
    local test_dir
    test_dir=$(mktemp -d)
    mkdir -p "$test_dir/product"
    echo "$test_dir"
}

# Cleanup test project
# Usage: cleanup_test_project "$test_dir"
cleanup_test_project() {
    local test_dir="$1"
    if [ -d "$test_dir" ]; then
        rm -rf "$test_dir"
    fi
}

# Export functions for use in test scripts
export REPO_ROOT
export PLUGIN_DIR
export -f run_claude
export -f run_claude_knowledge
export -f run_claude_json
export -f assert_contains
export -f assert_not_contains
export -f assert_count
export -f assert_order
export -f assert_skill_triggered
export -f assert_no_premature_action
export -f create_test_project
export -f cleanup_test_project
