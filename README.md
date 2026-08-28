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

## CI contract

Each CI-enabled class has one explicit contract. The reusable workflow supplies the environment, dependency install, and safe defaults. The repository owns the check list.

| Class | Contract | Fallback when the contract is absent |
| --- | --- | --- |
| Go CLI | `make ci` | Existing Makefile targets among `fmt-check`/`fmt`, `lint`, `vet`, `test`, `build`; otherwise `gofmt` / `go vet` / `go test` as today |
| Live Node | package-manager `ci` script | `lint`, `typecheck`, `test`, and `build` scripts when present; `bun test` if Bun and there is no `test` script |
| Python tool | `make ci` | Makefile `lint`/`test` if present; else ruff/black/mypy/pytest when configured or declared; else pytest or compileall |
| Docs-only | Unchanged (class-drift only) | — |

A repository with source, no contract, and a fallback that would run zero checks fails and points at [docs/classes.md](docs/classes.md). A lockfile or manifest scaffold with no application source stays caller-less (skip, do not fail).

Add the class contract when convenient; issue #5 will add migration gates, and copied CI should not be removed until the replacement has a successful authoritative run.

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

`node-bun.yml` accepts `working-directory` when `package.json` is not at the repo root (DOAR).

## Templates

Gitignore starters live in [`templates/gitignore/`](templates/gitignore/). Copy the one that matches the class. Do not paste workflows.

Label names for new repos are in [docs/labels.md](docs/labels.md).
