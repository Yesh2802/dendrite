# CLAUDE.md — DENDRITE Setup

You are setting up the DENDRITE architecture: Claude Code + Obsidian + Gstack wired together into a local-first, semantically searchable knowledge system.

**Run this setup automatically.** Self-heal errors where possible. Only pause to ask the user when a manual action is required (GUI install, plugin enable). Always tell the user exactly what to do when you need their help.

---

## Step 1 — Detect Tier

Run the prerequisite check:

```bash
curl -fsSL https://raw.githubusercontent.com/Yesh2802/dendrite/v0.1.0/scripts/check-prerequisites.sh | bash
```

Report the detected tier clearly:
- **Tier B**: git present, bun/gstack missing, Obsidian not running
- **Tier C**: bun + git present, Obsidian not running
- **Tier D**: everything present, Obsidian running with plugins

Then proceed to Step 2.

---

## Step 2 — Install Missing Components

### bun (auto-install if missing)
```bash
if ! command -v bun &>/dev/null && [ ! -f "$HOME/.bun/bin/bun" ]; then
  curl -fsSL https://bun.sh/install | bash
  export PATH="$HOME/.bun/bin:$PATH"
fi

# Persist PATH for future sessions (idempotent — skip if already present)
if ! grep -q 'bun/bin' ~/.bashrc 2>/dev/null; then
  echo 'export PATH="$HOME/.bun/bin:$PATH"' >> ~/.bashrc
fi

# Create bunx wrapper only if bun doesn't already ship one
if ! command -v bunx &>/dev/null; then
  echo '#!/usr/bin/env bash' > ~/.bun/bin/bunx
  echo 'exec "$(dirname "$0")/bun" x "$@"' >> ~/.bun/bin/bunx
  chmod +x ~/.bun/bin/bunx
fi
```

### gstack (auto-install if missing)
```bash
if [ ! -f "$HOME/gstack/browse/dist/browse" ] && [ ! -f "$HOME/.claude/skills/gstack/browse/dist/browse" ]; then
  git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git ~/gstack
  PATH="$HOME/.bun/bin:$PATH" bash -c 'cd ~/gstack && ./setup --team'
fi
```

### Obsidian (manual — pause and instruct user)
If Obsidian is not installed, print:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ACTION REQUIRED — Install Obsidian
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Go to: https://obsidian.md/download
2. Download and install Obsidian for Windows
3. Open Obsidian and create a new vault
4. Note the vault path (you'll need it next)

Tell me the vault path when ready (e.g. C:/Users/you/Documents/my-vault)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Wait for user confirmation before continuing.

### Obsidian Plugins (manual — instruct one at a time)
For each plugin (Local REST API, MCP Tools, Smart Connections, Templater):

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ACTION REQUIRED — Install Obsidian Plugin
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

In Obsidian:
1. Open Settings (gear icon bottom-left)
2. Go to Community plugins → Turn off Safe mode → Browse
3. Search for: "{PLUGIN_NAME}"
4. Click Install → Enable

Tell me when done.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

After MCP Tools installed, instruct user to open its settings and confirm the Local REST API key is configured (green checkmark).

---

## Step 3 — Scaffold Vault

After confirming vault path, scaffold the structure:

```bash
VAULT="$VAULT_PATH"  # use path provided by user

# Create folders
for folder in 00-inbox 01-ideas 02-projects 03-research 04-knowledge 05-life 06-finance 07-work 08-writing; do
  mkdir -p "$VAULT/$folder"
done

# Copy scaffold files from repo
SCAFFOLD_URL="https://raw.githubusercontent.com/Yesh2802/dendrite/v0.1.0/vault-scaffold"

# meta files
mkdir -p "$VAULT/meta"
for f in vault-map.md ai-rules.md workflow.md; do
  curl -fsSL "$SCAFFOLD_URL/meta/$f" -o "$VAULT/meta/$f"
done

# templates
mkdir -p "$VAULT/templates"
for f in inbox.md idea.md project-overview.md research.md concept.md; do
  curl -fsSL "$SCAFFOLD_URL/templates/$f" -o "$VAULT/templates/$f"
done

# CLAUDE.md
curl -fsSL "$SCAFFOLD_URL/CLAUDE.md" -o "$VAULT/CLAUDE.md"
```

Get the Obsidian REST API key:
```bash
cat "$VAULT/.obsidian/plugins/obsidian-local-rest-api/data.json" | python3 -c "import sys,json; print(json.load(sys.stdin)['apiKey'])"
```

Write .mcp.json:
```bash
MCP_EXE=$(find "$VAULT/.obsidian/plugins/mcp-tools/bin" -name "mcp-server.exe" 2>/dev/null | head -1)
API_KEY=$(cat "$VAULT/.obsidian/plugins/obsidian-local-rest-api/data.json" | python3 -c "import sys,json; print(json.load(sys.stdin)['apiKey'])")

cat > "$VAULT/.mcp.json" << EOF
{
  "mcpServers": {
    "obsidian": {
      "command": "$(cygpath -w "$MCP_EXE" 2>/dev/null || echo "$MCP_EXE")",
      "env": {
        "OBSIDIAN_API_KEY": "$API_KEY"
      }
    }
  }
}
EOF
```

---

## Step 4 — Verify Connections

Check each component:

```bash
echo "Checking Obsidian REST API..."
curl -sk https://127.0.0.1:27124/ | python3 -c "import sys,json; d=json.load(sys.stdin); print('✓ REST API:', d['status'])" 2>/dev/null || echo "✗ REST API not responding"

echo "Checking gstack..."
[ -f "$HOME/gstack/browse/dist/browse" ] || [ -f "$HOME/.claude/skills/gstack/browse/dist/browse" ] && echo "✓ gstack ready" || echo "✗ gstack not found"
```

On any failure: diagnose the specific error and attempt to fix automatically. If fix requires user action, print exact steps and wait.

---

## Step 5 — Setup Auto-Sync Hook

Add env vars for sync script:
```bash
echo "export DENDRITE_VAULT_PATH=\"$VAULT_PATH\"" >> ~/.bashrc
echo "export DENDRITE_REPO_PATH=\"$HOME/dendrite\"" >> ~/.bashrc
```

Add the sync hook to Claude Code settings by editing `~/.claude/settings.json` — add to the `SessionStart` hooks array:
```json
{
  "type": "command",
  "command": "bash ~/dendrite/scripts/sync-architecture.sh"
}
```

Then instruct user:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ACTION REQUIRED — Connect your fork for sync
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Fork the DENDRITE repo on GitHub
2. Run this command with your fork URL:

   cd ~/dendrite && git remote set-url origin <your-fork-url>

Tell me when done and I'll run the first sync.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

After user confirms, run first sync:
```bash
bash ~/dendrite/scripts/sync-architecture.sh
```

---

## Done ✅

Print final status:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  DENDRITE Setup Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ gstack — web browsing via /browse
✓ Obsidian vault — scaffolded with 9 folders + templates
✓ MCP Tools — Claude reads/writes vault natively
✓ Smart Connections — semantic search active
✓ Auto-sync — changes push to your fork on every session

Your vault is at: {VAULT_PATH}
Your repo is at:  {FORK_URL}

Start by dropping an idea into 00-inbox/ and asking Claude about it.
Feed it signals. Watch it branch. 🧠
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
