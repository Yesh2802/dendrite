# Releasing DENDRITE

## Process

1. **Update CHANGELOG.md** — add a new `## [vX.Y.Z] - YYYY-MM-DD` section summarizing changes.

2. **Pin URLs in SETUP.md** — update every `raw.githubusercontent.com/Yesh2802/dendrite/vX.Y.Z/...` URL to the new version:
   ```bash
   sed -i "s|/v[0-9.]\+/|/vX.Y.Z/|g" SETUP.md
   ```

3. **Commit**:
   ```bash
   git add SETUP.md CHANGELOG.md
   git commit -m "chore: release vX.Y.Z"
   ```

4. **Tag and push**:
   ```bash
   git tag vX.Y.Z
   git push origin main --tags
   ```

5. **Create a GitHub release** pointing at the new tag — paste the CHANGELOG entry as the release notes.

## Version scheme

`vMAJOR.MINOR.PATCH` — semantic versioning.

- PATCH: bug fixes, script hardening, doc updates
- MINOR: new features (new templates, new tier detection, new scripts)
- MAJOR: breaking changes to SETUP.md flow or vault-scaffold structure
