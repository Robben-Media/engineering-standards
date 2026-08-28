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

See [docs/classes.md](docs/classes.md).

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

Pin `@v1`, not `@main`. Add extra jobs in the caller repo when the class workflow is not enough (for example meal-planning QC).

`node-bun.yml` inputs:

- `working-directory` (default `.`) when package.json is not at the repo root (DOAR).
- `node-version` (default `22`) when the lockfile is not Bun.
- `bun-version` (default `1.2.20`) pinned for reproducibility. Callers can override.
- `package-manager` optional. Required when more than one supported lockfile is present.

Detection scans working-directory for the supported lockfiles and emits the exact file path.
That file path is passed to setup-node cache-dependency-path. Do not pass a directory.
If more than one supported lockfile exists and package-manager is unset, the job fails.

Installs stay frozen or immutable.

- bun: `bun install --frozen-lockfile`
- pnpm: `pnpm install --frozen-lockfile`
- npm: `npm ci`
- yarn: Corepack is enabled. Yarn 1 uses `--frozen-lockfile`. Yarn 2+ uses `--immutable`.

Lockfile detect fixtures live in `fixtures/node-lockfile/` and are proven by `scripts/test-detect-node-lockfile.sh`.
The reusable workflow inlines the same rules because checkout is the caller repo.

## Agent pointer

Each repo gets a short [`templates/STANDARDS.md`](templates/STANDARDS.md). Replace `CLASS` with `go-cli`, `node-bun`, `python-tool`, or `docs-only`. Do not overwrite `AGENTS.md`.

## Templates

Gitignore starters live in [`templates/gitignore/`](templates/gitignore/). Copy the one that matches the class. Do not paste workflows.

Label names for new repos are in [docs/labels.md](docs/labels.md).
