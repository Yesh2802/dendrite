# Contributing to DENDRITE

## Branches

- `main` — stable, tagged releases only
- Feature work: `feat/<name>`, bug fixes: `fix/<name>`

Open a PR against `main`. CI must pass before merge.

## Running the smoke test locally

```bash
bash scripts/test-setup.sh
```

Requires bash (Git Bash on Windows). No other dependencies.

## Running shellcheck locally

```bash
shellcheck scripts/*.sh
```

Install shellcheck: `winget install koalaman.shellcheck` (Windows) or `brew install shellcheck` (Mac).

## Proposing a new vault template

1. Add the template file to `vault-scaffold/templates/<name>.md`
2. Use YAML frontmatter with at least `created`, `type` fields
3. Add a usage note to `vault-scaffold/meta/workflow.md`
4. Open a PR with a short description of when a user would reach for this template

## Commit style

```
type: short imperative description

feat:   new feature
fix:    bug fix
chore:  maintenance, deps, CI
docs:   documentation only
```

## Cutting a release

See [RELEASING.md](RELEASING.md).
