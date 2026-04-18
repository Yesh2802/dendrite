# Troubleshooting

## MCP Tools shows "Local REST API key is not configured"

The MCP Tools plugin reads the key from the Local REST API plugin's `data.json` automatically.

1. Open Obsidian → Settings → Community plugins → confirm **Local REST API** is toggled ON
2. Open Settings → Local REST API → note the API key shown there
3. Restart Obsidian
4. If the error persists: open `<vault>/.obsidian/plugins/obsidian-local-rest-api/data.json` and confirm `apiKey` is non-empty

## Port 27123 not listening

The MCP Tools server only starts when Obsidian is open and the plugin is enabled.

1. Open Obsidian
2. Settings → Community plugins → confirm **MCP Tools** is toggled ON
3. Run: `netstat -an | grep 27123` — should show LISTENING
4. If still not listening: disable and re-enable the MCP Tools plugin

## `bunx: command not found` during gstack setup

bun on Windows doesn't ship a separate `bunx` binary. Fix:

```bash
echo '#!/usr/bin/env bash' > ~/.bun/bin/bunx
echo 'exec "$(dirname "$0")/bun" x "$@"' >> ~/.bun/bin/bunx
chmod +x ~/.bun/bin/bunx
```

Then re-run `./setup` in the gstack directory.

## `search_vault_smart` returns no results

Smart Connections needs to build its embedding index first.

1. Open Obsidian → click the Smart Connections icon in the left ribbon
2. Click **Rebuild index** or wait for initial indexing to complete (progress shown in status bar)
3. Once indexed, semantic search works instantly

## Auto-sync not pushing

Check `~/.claude/dendrite-sync.log` for the last error:

```bash
tail -20 ~/.claude/dendrite-sync.log
```

Common causes:
- No remote configured: `cd ~/dendrite && git remote add origin <your-fork-url>`
- Auth issue: `gh auth login` then retry
- Push rejected: `cd ~/dendrite && git pull --rebase origin main && git push`

## Claude Code can't find the MCP server on startup

The `.mcp.json` path to `mcp-server.exe` must use Windows backslash format.

Check `<vault>/.mcp.json` — the `command` field should look like:
```
C:\\Users\\you\\...\\mcp-server.exe
```

If it has forward slashes, rewrite the path:
```bash
# In the vault directory:
cat .mcp.json  # inspect current path
# Edit .mcp.json and replace forward slashes with double backslashes
```

## gstack install fails

Ensure bun is installed and on PATH:

```bash
export PATH="$HOME/.bun/bin:$PATH"
cd ~/gstack && ./setup --team
```

If `./setup` fails with a permission error: `chmod +x ~/gstack/setup && ./setup --team`
