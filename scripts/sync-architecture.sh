#!/usr/bin/env bash
# sync-architecture.sh — detects local architecture changes and syncs to fork
# Runs via Claude Code SessionStart hook. Never blocks on failure.

VAULT_DIR="${DENDRITE_VAULT_PATH:-$HOME/Downloads/vault}"
DENDRITE_DIR="${DENDRITE_REPO_PATH:-$HOME/dendrite}"
LOG="$HOME/.claude/dendrite-sync.log"

log() { echo "[$(date '+%Y-%m-%d %H:%M')] $1" >> "$LOG"; }

# Check remote is configured
if ! git -C "$DENDRITE_DIR" remote get-url origin &>/dev/null; then
  echo ""
  echo "⚠️  DENDRITE sync: No remote configured."
  echo "   Run: cd ~/dendrite && git remote add origin <your-fork-url>"
  echo ""
  log "SKIP: no remote configured"
  exit 0
fi

# Stage changes from tracked locations
cd "$DENDRITE_DIR" || exit 0

# Sync vault scaffold from live vault
if [ -d "$VAULT_DIR/meta" ]; then
  cp -r "$VAULT_DIR/meta/." vault-scaffold/meta/ 2>/dev/null
  cp -r "$VAULT_DIR/templates/." vault-scaffold/templates/ 2>/dev/null
  cp "$VAULT_DIR/CLAUDE.md" vault-scaffold/CLAUDE.md 2>/dev/null
fi

# Sync .mcp.json example
if [ -f "$VAULT_DIR/.mcp.json" ]; then
  cp "$VAULT_DIR/.mcp.json" vault-scaffold/.mcp.json.example 2>/dev/null
fi

# Check if anything changed
if git diff --quiet && git diff --staged --quiet; then
  log "OK: no changes to sync"
  exit 0
fi

# Commit and push
DATE=$(date '+%Y-%m-%d')
git add -A
git commit -m "sync: $DATE architecture changes" >> "$LOG" 2>&1

if git push origin main >> "$LOG" 2>&1; then
  log "OK: synced to remote"
else
  log "WARN: push failed — will retry next session"
fi
