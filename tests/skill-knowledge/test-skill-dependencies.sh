#!/usr/bin/env bash
# Test: external tool dependencies declared by skills actually work
#
# Fast, deterministic check — no Claude session involved.
# Catches the class of bug where a skill references an external tool
# that is misnamed, unpublished, or not runnable in the current environment.
#
# The test extracts the validation command from the skill itself and runs it,
# so a skill change and a test pass are coupled: if the skill says to run a
# command, this test proves that command actually works.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL_MD="$REPO_ROOT/squad/skills/architecture-record/SKILL.md"

echo "=== Test: skill external dependencies ==="
echo ""

# ---------- Test 1: Mermaid validator referenced in architecture-record ----------
# Verify that the Mermaid validation command in architecture-record/SKILL.md
# actually runs successfully against a trivial valid diagram.
echo "Test 1: Mermaid validator from architecture-record SKILL.md..."

if [ ! -f "$SKILL_MD" ]; then
    echo "  [FAIL] Skill file not found: $SKILL_MD"
    exit 1
fi

# Extract the validator command from the SKILL.md. The skill documents
# the command inside a bash code fence. We look for any line containing
# either "mermaid-validator" or "mmdc" (the two candidates) and pick the
# first one that looks like an invocation.
VALIDATOR_CMD=$(grep -E '^\s*(npx\s+.*mermaid|mmdc\s)' "$SKILL_MD" | head -1 | sed 's/^[[:space:]]*//')

if [ -z "$VALIDATOR_CMD" ]; then
    echo "  [FAIL] No Mermaid validator command found in $SKILL_MD"
    echo "  Expected a line matching: npx ... mermaid... OR mmdc ..."
    exit 1
fi

echo "  Found command in skill: $VALIDATOR_CMD"

# Build a trivial valid Mermaid file
TMP_DIR=$(mktemp -d)
TMP_MD="$TMP_DIR/diagram.md"
TMP_OUT="$TMP_DIR/diagram.svg"

cat > "$TMP_MD" <<'EOF'
# Test diagram

```mermaid
flowchart TD
    A --> B
```
EOF

# Substitute placeholder paths in the extracted command with real ones.
# The skill's command uses ${user_config.product_home}/architecture/record.md
# as input. We replace that with $TMP_MD and any output path with $TMP_OUT.
#
# Two known command shapes:
#   npx mermaid-validator validate-md <path> --fail-fast
#   npx -y -p @mermaid-js/mermaid-cli mmdc -i <path> -o <out>
RUNNABLE_CMD="$VALIDATOR_CMD"
RUNNABLE_CMD=${RUNNABLE_CMD//\$\{user_config.product_home\}\/architecture\/record.md/$TMP_MD}
RUNNABLE_CMD=${RUNNABLE_CMD//<file>/$TMP_MD}
RUNNABLE_CMD=${RUNNABLE_CMD//<path-to-record.md>/$TMP_MD}
RUNNABLE_CMD=${RUNNABLE_CMD//<out>/$TMP_OUT}

echo "  Runnable command: $RUNNABLE_CMD"

# Execute it
if output=$(eval "$RUNNABLE_CMD" 2>&1); then
    echo "  [PASS] Validator command from SKILL.md ran successfully"
else
    exit_code=$?
    echo "  [FAIL] Validator command failed (exit $exit_code)"
    echo "  Command: $RUNNABLE_CMD"
    echo "  Output:"
    echo "$output" | head -20 | sed 's/^/    /'
    rm -rf "$TMP_DIR"
    exit 1
fi

rm -rf "$TMP_DIR"

echo ""
echo "=== All dependency tests passed ==="
