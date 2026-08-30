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

Astro repos are Live Node repos with the [Astro profile](docs/profiles/astro.md). They call `node-bun.yml@v1` when pinned; declaring the profile does not configure CI. There is no `class:astro` and no fifth reusable workflow.

Hold a live-Node caller when the repo is a lockfile scaffold with no source (`finance` is the example).

Out of catalog: Homebrew taps, agent workspace/soul trees, archives, forks, empty twins.

## CI contract

Each CI-enabled class has one explicit contract. The reusable workflow supplies the environment, dependency install, and safe defaults. The repository owns the check list.

| Class | Contract | Fallback when the contract is absent |
| --- | --- | --- |
| Go CLI | `make ci` | Existing Makefile targets among `fmt-check`/`fmt`, `lint`, `vet`, `test`, `build`; otherwise `gofmt` / `go vet` / `go test` as today |
| Live Node | package-manager `ci` script | `lint`, `typecheck`, `test`, and `build` scripts when present; `bun test` if Bun and there is no `test` script |
| Python tool | `make ci` | Makefile `lint`/`test` if present; else ruff/black/mypy/pytest when configured or declared; else pytest or compileall |
| Docs-only | Unchanged (class-drift only) | — |

A repository with source, no contract, and a fallback that would run zero checks fails and points at [docs/classes.md](docs/classes.md). A lockfile or manifest scaffold with no application source stays caller-less (skip, do not fail).

Add the class contract when convenient. Copied CI must not be removed until the replacement has a successful authoritative run; the gates are in [docs/migration.md](docs/migration.md).

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

`node-bun.yml` inputs:

- `working-directory` (default `.`) when package.json is not at the repo root (DOAR).
- `node-version` (default `22`). setup-node runs for every package manager, including Bun; its cache stays off for Bun (`cache: bun` is unsupported).
- `bun-version` (default `1.4.0`) pinned for reproducibility. Callers can override.
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

All four workflows accept `working-directory` (default `.`) when the manifest is not at the repo root (`node-bun.yml` already did; the others gained it so this repo can host fixtures). DOAR is the Node subdirectory example.

## Release

See [docs/release.md](docs/release.md). Callers stay on `@v1`. Jeremy moves that tag after Nash/Jeremy review. Third-party actions in this repo are pinned to full commit SHAs.

In-repo Fixture CI (`.github/workflows/fixture-ci.yml`) exercises every reusable workflow against [fixtures/](fixtures/) before `v1` moves. The initial `v1` record is [docs/releases/v1.md](docs/releases/v1.md).

## Agent pointer

Each repo gets a short [`templates/STANDARDS.md`](templates/STANDARDS.md). Replace `CLASS` with `go-cli`, `node-bun`, `python-tool`, or `docs-only`, and set `Profile` to `astro` or `none`. Keep `Adoption: declared` and `Workflow: local` until [docs/inventory.md](docs/inventory.md) records otherwise. The pointer names the catalog entry. It does not configure CI. The canon records adoption and workflow status. Do not overwrite `AGENTS.md`.

## Templates

Gitignore starters live in [`templates/gitignore/`](templates/gitignore/). Copy the one that matches the class. Do not paste workflows.

Label names for new repos are in [docs/labels.md](docs/labels.md).

## Migration

Class inventory and migration status live in this repo, not in each caller.

- [docs/inventory.md](docs/inventory.md) — class list, status (`not-started` / `held` / `caller-open` / `pinned`), exceptions
- [docs/equivalence/](docs/equivalence/) — retained / added / omitted / caller-specific checks for each representative
- [docs/migration.md](docs/migration.md) — gates, extra-job approval, when copied CI may be removed
