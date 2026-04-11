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

# ---------- Test 2: Dedup pipeline referenced in product-naming ----------
# Extract the /tmp/naming-dedup.sh script body from product-naming/SKILL.md
# and verify its shell syntax. Couples skill content with test pass: if
# someone edits the awk pipeline and breaks it, this test fails.
echo "Test 2: Dedup pipeline from product-naming SKILL.md..."

PN_SKILL_MD="$REPO_ROOT/squad/skills/product-naming/SKILL.md"

if [ ! -f "$PN_SKILL_MD" ]; then
    echo "  [FAIL] Skill file not found: $PN_SKILL_MD"
    exit 1
fi

# awk availability — the pipeline leans on awk
if ! command -v awk &> /dev/null; then
    echo "  [FAIL] awk not available"
    exit 1
fi

# Extract the bash code fence that begins with "#!/bin/sh" — that's the
# dedup script body in Step 3b. We take everything between the first
# "#!/bin/sh" line and the next closing ``` fence.
TMP_DIR=$(mktemp -d)
TMP_SCRIPT="$TMP_DIR/naming-dedup.sh"

awk '
    /^#!\/bin\/sh$/ { capture = 1 }
    capture && /^```$/ { capture = 0; exit }
    capture { print }
' "$PN_SKILL_MD" > "$TMP_SCRIPT"

if [ ! -s "$TMP_SCRIPT" ]; then
    echo "  [FAIL] Could not extract dedup script from $PN_SKILL_MD"
    echo "  Expected a '#!/bin/sh' block inside a bash code fence"
    rm -rf "$TMP_DIR"
    exit 1
fi

echo "  Extracted $(wc -l < "$TMP_SCRIPT") lines to $TMP_SCRIPT"

# Verify shell syntax
if sh -n "$TMP_SCRIPT" 2>&1; then
    echo "  [PASS] Dedup script syntax valid"
else
    exit_code=$?
    echo "  [FAIL] Dedup script has syntax errors (exit $exit_code)"
    cat "$TMP_SCRIPT" | sed 's/^/    /'
    rm -rf "$TMP_DIR"
    exit 1
fi

# Smoke-run it with minimal fixture input to verify the awk invocation
# parses. The script reads from /tmp/naming-pool-lens*.txt — stage a
# couple of trivial inputs so the pipeline has something to chew on.
POOL_DIR="$TMP_DIR/pool"
mkdir -p "$POOL_DIR"
# Redirect the script's hardcoded /tmp paths through a working copy that
# points to our fixture location.
SMOKE_SCRIPT="$TMP_DIR/smoke-dedup.sh"
sed \
    -e "s|/tmp/naming-pool-lens\*\.txt|$POOL_DIR/naming-pool-lens*.txt|g" \
    -e "s|/tmp/naming-pool-deduped\.txt|$POOL_DIR/naming-pool-deduped.txt|g" \
    "$TMP_SCRIPT" > "$SMOKE_SCRIPT"

cat > "$POOL_DIR/naming-pool-lens1.txt" <<'EOF'
Trabajador|1
Worklog|1
EOF
cat > "$POOL_DIR/naming-pool-lens2.txt" <<'EOF'
Trabajador|2
Sundial|2
EOF

if output=$(sh "$SMOKE_SCRIPT" 2>&1) && [ -s "$POOL_DIR/naming-pool-deduped.txt" ]; then
    # Expect 3 unique entries (Trabajador appears in both lenses and should
    # be merged into one line with lens_order "1,2")
    lines=$(wc -l < "$POOL_DIR/naming-pool-deduped.txt")
    if [ "$lines" -eq 3 ] && grep -q "^Trabajador|1,2$" "$POOL_DIR/naming-pool-deduped.txt"; then
        echo "  [PASS] Dedup script merges cross-lens hits correctly"
    else
        echo "  [FAIL] Dedup script output unexpected:"
        cat "$POOL_DIR/naming-pool-deduped.txt" | sed 's/^/    /'
        rm -rf "$TMP_DIR"
        exit 1
    fi
else
    echo "  [FAIL] Dedup script failed to run"
    echo "  Output: $output"
    rm -rf "$TMP_DIR"
    exit 1
fi

rm -rf "$TMP_DIR"

echo ""
echo "=== All dependency tests passed ==="
