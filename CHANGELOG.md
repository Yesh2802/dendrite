# Changelog

All notable changes to DENDRITE follow [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format.

---

## [v0.1.0] - 2026-04-18

### Added
- `SETUP.md` — bootstrap CLAUDE.md that self-installs the full Claude Code + Obsidian + Gstack stack
- `scripts/check-prerequisites.sh` — tier B/C/D detection with coloured output and portable MCP Tools port probe
- `scripts/sync-architecture.sh` — SessionStart hook with `--dry-run` mode, allowlist, and secret denylist
- `scripts/test-setup.sh` — smoke test for tier detection under three fixture conditions
- `vault-scaffold/` — 9 note templates + meta files (vault-map, ai-rules, workflow)
- `README.md` — architecture diagram, setup flowchart (Mermaid), before/after comparison, requirements
- `docs/troubleshooting.md` — self-service fixes for common setup errors
- `docs/architecture.md` — deep-dive into component design and data flow
- `.github/workflows/ci.yml` — shellcheck + syntax check + markdown link check + smoke test
- MIT license
