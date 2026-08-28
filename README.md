# engineering-standards

The Robben Media repo class catalog and reusable GitHub Actions.

Other repos call these workflows. They do not copy them.

Pin:

```yaml
jobs:
  ci:
    uses: Robben-Media/engineering-standards/.github/workflows/<class>.yml@v1
```

`<class>` is one of `go-cli`, `node-bun`, `python-tool`, or `docs-only`.

`Robben-Media/.github` stays community-health fallbacks (profile, CONTRIBUTING, SECURITY, issue/PR templates). This repo is the canon for CI and class rules. There is no personal `itsjeremyjohnson/engineering-standards` twin.

## Classes

See [docs/classes.md](docs/classes.md). Inventory and status: [docs/inventory.md](docs/inventory.md). Gates: [docs/migration.md](docs/migration.md).

| Class | Detect | Caller | Dependabot (Supply Chain) |
| --- | --- | --- | --- |
| Go CLI | `go.mod` + `cmd/` | `go-cli.yml` | Monthly, grouped. No auto-merge. |
| Live Node | `package.json` + lockfile | `node-bun.yml` (bun, pnpm, npm, or yarn) | Weekly on live/CI apps. No auto-merge on personal repos. |
| Python tool | `requirements.txt` or `pyproject.toml` + tests | `python-tool.yml` | Monthly if there is CI. No auto-merge. |
| Docs-only | No app ecosystem | Optional `docs-only.yml` (class-drift check) | Skip. |

Docs-only repos do not need a caller. Use the workflow only if you want CI to fail when an app manifest appears. Echo-stub CI on a docs-only repo should be removed, not replaced.

Hold a live-Node caller when the repo is a lockfile scaffold with no source (`finance` is the example).

Out of catalog: Homebrew taps, agent workspace/soul trees, archives, forks, empty twins.

## Caller shape

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  ci:
    uses: Robben-Media/engineering-standards/.github/workflows/go-cli.yml@v1
```

Pin `@v1`, not `@main`. Add extra jobs in the caller repo when the class workflow is not enough (for example meal-planning QC). Nash or Jeremy approve exceptions; record them in [docs/inventory.md](docs/inventory.md). Do not delete copied CI until the `@v1` caller has a successful run. See [docs/migration.md](docs/migration.md).

`node-bun.yml` accepts `working-directory` when `package.json` is not at the repo root (DOAR).

## Templates

Gitignore starters live in [`templates/gitignore/`](templates/gitignore/). Copy the one that matches the class. Do not paste workflows.

Label names for new repos are in [docs/labels.md](docs/labels.md).

## Migration

Class inventory and migration status live in this repo, not in each caller.

- [docs/inventory.md](docs/inventory.md) — class list, status (`not-started` / `held` / `caller-open` / `pinned`), exceptions
- [docs/equivalence/](docs/equivalence/) — retained / added / omitted / caller-specific checks for each representative
- [docs/migration.md](docs/migration.md) — gates, extra-job approval, when copied CI may be removed

Representative caller migrations are `held` until fixtures on still-open `#8` are green.
