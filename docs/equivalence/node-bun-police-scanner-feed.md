# Live Node — `Robben-Media/police-scanner-feed`

Status: `held` (representative). Surgeon PR `#58` is `caller-open` and must not merge from this work.

Compared 2026-08-28 via `gh api` (no clone):

- Default `ci.yml` blob `ce28fe421f5f752e96f445cab801be73a1b5d7f1` (echo-stub on `blacksmith-2vcpu-ubuntu-2404`)
- Root: `package.json`, `bun.lock`, `src/`, `scripts/`, `tsconfig.json`
- `package.json` scripts: many `test:*` helpers. **No** `lint` script. **No** `test` script.
- Shared: `node-bun.yml@472bfa1`
- Open PR: https://github.com/Robben-Media/police-scanner-feed/pull/58 (`merged=false`). Body says it pins `node-bun.yml@v1`. That PR was not merged and was not run as an authoritative `@v1` success.

`claude.yml` is separate and stays.

## Existing checks (copied CI)

```yaml
- Setup environment: echo "CI setup complete"
- Lint: echo "Linting complete (add lint commands as needed)"
- Test: echo "Tests complete (add test commands as needed)"
```

These are placeholders. They do not install, lint, or test.

## Shared `node-bun.yml` checks

- Detect package manager from the lockfile (`bun.lock` → bun)
- `bun install --frozen-lockfile`
- Lint if `package.json` has a `lint` script; otherwise skip
- Test if there is a `test` script; on bun with no `test` script, run `bun test`

## Comparison

| Check | Verdict | Notes |
| --- | --- | --- |
| Echo setup/lint/test | omitted (intentional) | Not real checks. Replacing them is the point of a later caller. |
| Frozen lockfile install | added | Shared bun path. Not in current `ci.yml`. |
| Lint | added (skip) | No `lint` script. Shared workflow prints `No lint script; skipping`. |
| `bun test` | added | No `test` script, so the bun fallback runs `bun test`. Existing scripts are named `test:dashboard`, `test:health`, … — `bun test` is **not** those scripts. Record that gap before anyone deletes the stub. |
| Blacksmith runner | omitted (intentional) | Shared workflow uses `ubuntu-latest`. |
| `claude.yml` | caller-specific | Unchanged. Not class CI. |

## Gate

`#58` must stay open and unmerged until the migration gates pass and an authoritative `@v1` run succeeds on it (see [../migration.md](../migration.md)). This change does not touch that PR. Do not delete the echo-stub first.
