#!/usr/bin/env bash
# sync-architecture.sh — detects local architecture changes and syncs to fork
# Runs via Claude Code SessionStart hook. Never blocks on failure.
#
# Usage:
#   bash sync-architecture.sh           # auto-push (requires DENDRITE_SYNC_CONFIRMED=1)
#   bash sync-architecture.sh --dry-run # show diff only, never push

VAULT_DIR="${DENDRITE_VAULT_PATH:-$HOME/Downloads/vault}"
DENDRITE_DIR="${DENDRITE_REPO_PATH:-$HOME/dendrite}"
LOG="$HOME/.claude/dendrite-sync.log"
DRY_RUN=false

if [[ "$1" == "--dry-run" ]]; then
  DRY_RUN=true
fi

log() { echo "[$(date '+%Y-%m-%d %H:%M')] $1" >> "$LOG"; }

# Allowlist: only these paths are ever synced
ALLOWED_PATHS=(
  "vault-scaffold/CLAUDE.md"
  "vault-scaffold/meta/"
  "vault-scaffold/templates/"
  "docs/"
  "CLAUDE.md"
)

# Denylist: abort if any staged file matches these patterns
DENY_PATTERNS=(
  "*.env"
  "*.pem"
  "*.key"
  "*api-key*"
  "*secret*"
  ".obsidian/plugins/*/data.json"
  ".mcp.json"
)

# Check remote is configured
if ! git -C "$DENDRITE_DIR" remote get-url origin &>/dev/null; then
  echo ""
  echo "⚠️  DENDRITE sync: No remote configured."
  echo "   Run: cd ~/dendrite && git remote add origin <your-fork-url>"
  echo ""
  log "SKIP: no remote configured"
  exit 0
fi

cd "$DENDRITE_DIR" || exit 0

# Sync vault scaffold from live vault (allowlisted paths only)
if [ -d "$VAULT_DIR/meta" ]; then
  cp -r "$VAULT_DIR/meta/." vault-scaffold/meta/ 2>/dev/null
  cp -r "$VAULT_DIR/templates/." vault-scaffold/templates/ 2>/dev/null
  cp "$VAULT_DIR/CLAUDE.md" vault-scaffold/CLAUDE.md 2>/dev/null
fi

# Stage only allowlisted paths
git reset HEAD -- . &>/dev/null
for path in "${ALLOWED_PATHS[@]}"; do
  git add "$path" 2>/dev/null
done

# Check if anything changed
if git diff --staged --quiet; then
  log "OK: no changes to sync"
  exit 0
fi

# Denylist check: abort if any staged file matches secret patterns
for pattern in "${DENY_PATTERNS[@]}"; do
  if git diff --staged --name-only | grep -qiE "${pattern//\*/.*}"; then
    echo ""
    echo "⛔  DENDRITE sync: Refusing to push — possible secret matched pattern: $pattern"
    echo "   Check: git diff --staged"
    echo ""
    log "ABORT: secret pattern matched: $pattern"
    git reset HEAD -- . &>/dev/null
    exit 0
  fi
done

# Dry-run mode: show diff and exit
if [ "$DRY_RUN" = true ]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  DENDRITE sync --dry-run"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  git diff --staged --stat
  echo ""
  echo "  Would run: git push origin main"
  echo "  To enable auto-push: export DENDRITE_SYNC_CONFIRMED=1"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  git reset HEAD -- . &>/dev/null
  exit 0
fi

# Require explicit opt-in for auto-push
if [ "${DENDRITE_SYNC_CONFIRMED:-0}" != "1" ]; then
  echo ""
  echo "⚠️  DENDRITE sync: Auto-push is disabled by default."
  echo "   To enable: export DENDRITE_SYNC_CONFIRMED=1"
  echo "   To preview: bash ~/dendrite/scripts/sync-architecture.sh --dry-run"
  echo ""
  log "SKIP: DENDRITE_SYNC_CONFIRMED not set"
  git reset HEAD -- . &>/dev/null
  exit 0
fi

# Commit and push
DATE=$(date '+%Y-%m-%d')
git commit -m "sync: $DATE architecture changes" >> "$LOG" 2>&1

if git push origin main >> "$LOG" 2>&1; then
  log "OK: synced to remote"
else
  log "WARN: push failed — will retry next session"
fi
