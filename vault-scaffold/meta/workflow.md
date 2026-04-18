# Workflow Patterns

## Process Inbox
1. `mcp__obsidian__list_vault_files` in `00-inbox/`
2. `mcp__obsidian__get_vault_file` each note
3. Determine folder from `[[meta/vault-map.md]]`
4. `mcp__obsidian__create_vault_file` at correct path
5. `mcp__obsidian__patch_vault_file` to add wikilinks

## Capture → Idea
1. `mcp__obsidian__search_vault_smart` to check duplicates
2. `mcp__obsidian__create_vault_file` in `01-ideas/` using `[[templates/idea.md]]`

## Expand Idea → Project
1. `mcp__obsidian__search_vault_smart` for idea
2. `mcp__obsidian__get_vault_file` to read it
3. `mcp__obsidian__create_vault_file` at `02-projects/{name}/overview.md`
4. Populate with `[[templates/project-overview.md]]`

## Research a Topic
1. `mcp__obsidian__search_vault_smart` for existing research
2. Research via `mcp__obsidian__fetch` or `/browse`
3. `mcp__obsidian__create_vault_file` to `03-research/{domain}/{topic}.md`

## Build Connections
1. `mcp__obsidian__search_vault_smart` for related concepts
2. `mcp__obsidian__patch_vault_file` to append wikilinks
