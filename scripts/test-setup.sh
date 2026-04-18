#!/usr/bin/env bash
# test-setup.sh — smoke test for check-prerequisites.sh under fixture conditions
# Run locally or via CI. Exit 0 = pass, exit 1 = fail.

set -euo pipefail

PASS=0
FAIL=0
SCRIPT="$(dirname "$0")/check-prerequisites.sh"

assert_tier() {
  local description="$1"
  local expected_tier="$2"
  local env_override="$3"

  output=$(env -i HOME="$FAKE_HOME" PATH="/usr/bin:/bin" $env_override bash "$SCRIPT" 2>&1 || true)
  actual_tier=$(echo "$output" | grep "Detected Tier:" | grep -oE "[BCD]" | head -1)

  if [ "$actual_tier" = "$expected_tier" ]; then
    echo "  PASS: $description (tier=$actual_tier)"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $description — expected tier $expected_tier, got '$actual_tier'"
    echo "        Output: $(echo "$output" | tail -5)"
    FAIL=$((FAIL + 1))
  fi
}

# Setup fake HOME without any tools
FAKE_HOME=$(mktemp -d)
trap 'rm -rf "$FAKE_HOME"' EXIT

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  DENDRITE — Setup Smoke Test"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Fixture 1: nothing installed → Tier B
assert_tier "nothing installed → Tier B" "B" ""

# Fixture 2: bun present → Tier C
mkdir -p "$FAKE_HOME/.bun/bin"
touch "$FAKE_HOME/.bun/bin/bun"
chmod +x "$FAKE_HOME/.bun/bin/bun"
assert_tier "bun installed → Tier C" "C" ""

# Fixture 3: gstack present → Tier C
mkdir -p "$FAKE_HOME/.claude/skills/gstack/browse/dist"
touch "$FAKE_HOME/.claude/skills/gstack/browse/dist/browse"
assert_tier "bun + gstack installed → Tier C" "C" ""

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Results: $PASS passed, $FAIL failed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

[ "$FAIL" -eq 0 ] || exit 1
