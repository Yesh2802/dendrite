# Workflow Patterns

## Process Inbox
1. `list_vault_files` in `00-inbox/`
2. `get_vault_file` each note
3. Determine folder from `[[meta/vault-map]]`
4. `create_vault_file` at correct path
5. `patch_vault_file` to add wikilinks

## Capture → Idea
1. `search_vault_smart` to check duplicates
2. `create_vault_file` in `01-ideas/` using `[[templates/idea]]`

## Expand Idea → Project
1. `search_vault_smart` for idea
2. `get_vault_file` to read it
3. `create_vault_file` at `02-projects/{name}/overview.md`
4. Populate with `[[templates/project-overview]]`

## Research a Topic
1. `search_vault_smart` for existing research
2. Research via `fetch` or `/browse`
3. `create_vault_file` to `03-research/{domain}/{topic}.md`

## Build Connections
1. `search_vault_smart` for related concepts
2. `patch_vault_file` to append wikilinks
