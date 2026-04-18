# CLAUDE.md — AI-BRAIN Vault

This is a personal Obsidian knowledge vault. Your role is to help build and maintain a permanent intellectual workspace.

## Environment

- Platform: Windows 11, shell is bash via Git Bash
- MCP server: `obsidian` — connected via mcp-tools plugin (authenticated)

## Vault Access — MCP Tools

Always use these MCP tools. Never read/write vault files directly.

| Tool | Purpose |
|---|---|
| `mcp__obsidian__search_vault_smart` | **Semantic search** — use this first, always |
| `mcp__obsidian__search_vault_simple` | Full-text search fallback |
| `mcp__obsidian__get_vault_file` | Read a note |
| `mcp__obsidian__create_vault_file` | Create or overwrite a note |
| `mcp__obsidian__append_to_vault_file` | Append to a note |
| `mcp__obsidian__patch_vault_file` | Edit by heading, block, or frontmatter |
| `mcp__obsidian__list_vault_files` | Browse a folder |
| `mcp__obsidian__execute_template` | Apply a Templater template |
| `mcp__obsidian__fetch` | Fetch a web page (returns Markdown) |

## Token Reduction — Search First

**Always semantic search before reading.** Never load a note without confirming it's relevant.

1. `mcp__obsidian__search_vault_smart` with keywords related to the task
2. Read only the top matching notes via `mcp__obsidian__get_vault_file`
3. Act — do not list or scan the whole vault

## Rules

- **Never delete notes.** Move to `00-inbox/` if unsure.
- **Search before creating.** Avoid duplicates.
- **Always add wikilinks.** Connect related concepts with `[[note-name]]`.
- **Keep notes concise.** Clarity over length.
- **Respect folder roles.** See `[[meta/vault-map.md]]`.
- **Use templates.** Apply the right template from `templates/`.

## Vault Structure

```
00-inbox/     → unprocessed captures
01-ideas/     → raw ideas
02-projects/  → active projects
03-research/  → external knowledge by domain
04-knowledge/ → refined long-term concepts
05-life/      → personal planning
06-finance/   → financial strategy
07-work/      → professional material
08-writing/   → long-form writing
meta/         → system notes
templates/    → note templates
```

## gstack

- Use `/browse` for all web browsing — never use `mcp__claude-in-chrome__*` tools

Available skills: `/office-hours`, `/plan-ceo-review`, `/plan-eng-review`, `/plan-design-review`, `/design-consultation`, `/design-shotgun`, `/design-html`, `/review`, `/ship`, `/land-and-deploy`, `/canary`, `/benchmark`, `/browse`, `/connect-chrome`, `/qa`, `/qa-only`, `/design-review`, `/setup-browser-cookies`, `/setup-deploy`, `/retro`, `/investigate`, `/document-release`, `/codex`, `/cso`, `/autoplan`, `/plan-devex-review`, `/devex-review`, `/careful`, `/freeze`, `/guard`, `/unfreeze`, `/gstack-upgrade`, `/learn`
