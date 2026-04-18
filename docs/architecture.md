# Architecture Deep-Dive

## Components

### Claude Code
The AI agent. Runs in your terminal. Reads `CLAUDE.md` for instructions. Connects to MCP servers defined in `.mcp.json`.

### MCP Tools (Obsidian plugin)
Exposes a stdio MCP server (`mcp-server.exe`) that Claude Code spawns directly. Provides native tools for reading, writing, searching, and templating vault notes. Bridges Claude Code to the Obsidian REST API internally.

### Obsidian Local REST API (plugin)
HTTP server on `https://127.0.0.1:27124`. The MCP Tools server calls this internally. Also used directly for health checks.

### Smart Connections (plugin)
Runs local embeddings using `bge-micro-v2` via transformers. Indexes all vault notes. Exposes semantic search through the `mcp__obsidian__search_vault_smart` tool. Zero API cost — runs entirely on-device.

### Gstack
Headless Chromium browser controlled by Claude Code. Used for web research without leaving the terminal. Invoked via the `/browse` skill.

### sync-architecture.sh
Bash script registered as a Claude Code `SessionStart` hook. Runs every time Claude Code opens. Detects changes to vault scaffold files and pushes them to the user's GitHub fork.

---

## Data Flow

```
User prompt
  → Claude Code reads CLAUDE.md
  → Claude calls mcp__obsidian__search_vault_smart("topic")
  → MCP Tools → Obsidian REST API → Smart Connections
  → Returns top N semantically matched notes
  → Claude reads only those notes via mcp__obsidian__get_vault_file
  → Claude responds with vault-grounded answer
```

---

## Token Reduction

Without DENDRITE: entire files loaded into context = high token cost.

With DENDRITE: semantic search → top 3-5 relevant notes → 80-90% token reduction on vault queries.

---

## Why Local Embeddings

`bge-micro-v2` is a 22MB model that runs on CPU. It produces embeddings comparable to cloud APIs for personal knowledge retrieval tasks. No API calls, no cost, no latency from network requests.

---

## File Layout

```
dendrite/
├── README.md                    # Entry point — diagrams + setup
├── SETUP.md                     # Bootstrap CLAUDE.md (rename to CLAUDE.md)
├── scripts/
│   ├── check-prerequisites.sh  # Tier B/C/D detection
│   └── sync-architecture.sh    # SessionStart hook for auto-sync
├── vault-scaffold/              # Copied into the Obsidian vault
│   ├── CLAUDE.md
│   ├── meta/
│   │   ├── vault-map.md
│   │   ├── ai-rules.md
│   │   └── workflow.md
│   └── templates/
│       ├── inbox.md
│       ├── idea.md
│       ├── project-overview.md
│       ├── research.md
│       └── concept.md
└── docs/
    ├── architecture.md          # This file
    └── troubleshooting.md       # Self-service error resolution
```
