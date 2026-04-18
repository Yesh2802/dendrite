#!/usr/bin/env bash
# check-prerequisites.sh — detects tier B/C/D and reports missing components

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; }
warn() { echo -e "  ${YELLOW}?${NC} $1"; }

TIER="B"
MISSING=()

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  DENDRITE — Prerequisite Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# git
if command -v git &>/dev/null; then
  ok "git $(git --version | awk '{print $3}')"
else
  fail "git — not found. Install from https://git-scm.com"
  MISSING+=("git")
fi

# bun
if command -v bun &>/dev/null || [ -f "$HOME/.bun/bin/bun" ]; then
  ok "bun"
  TIER="C"
else
  fail "bun — will auto-install"
fi

# gstack
if [ -f "$HOME/.claude/skills/gstack/browse/dist/browse" ] || [ -f "$HOME/gstack/browse/dist/browse" ]; then
  ok "gstack"
  TIER="C"
else
  fail "gstack — will auto-install"
fi

# Claude Code
if command -v claude &>/dev/null; then
  ok "Claude Code"
  TIER="C"
else
  warn "Claude Code — not detected in PATH (may still be running)"
fi

# Obsidian REST API
OBSIDIAN_UP=false
if curl -sk https://127.0.0.1:27124/ 2>/dev/null | grep -q "Local REST API"; then
  ok "Obsidian Local REST API — running"
  OBSIDIAN_UP=true
  TIER="D"
else
  fail "Obsidian Local REST API — not running (Obsidian must be open with plugin enabled)"
  MISSING+=("obsidian-rest-api")
fi

# MCP Tools
if [ "$OBSIDIAN_UP" = true ]; then
  if netstat -an 2>/dev/null | grep -q "27123.*LISTEN"; then
    ok "MCP Tools — server running on port 27123"
  else
    fail "MCP Tools — plugin installed but server not running"
    MISSING+=("mcp-tools")
  fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "  Detected Tier: ${YELLOW}%s${NC}\n" "$TIER"

if [ ${#MISSING[@]} -eq 0 ]; then
  echo -e "  Status: ${GREEN}Ready to install${NC}"
else
  echo -e "  Status: ${YELLOW}Some steps need manual action${NC}"
  echo "  Missing: ${MISSING[*]}"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

export DENDRITE_TIER="$TIER"
export DENDRITE_MISSING="${MISSING[*]}"
