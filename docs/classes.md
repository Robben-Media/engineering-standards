# Repo classes

Classify by what is on the default branch, not by the GitHub language badge.

## CI contract

The reusable workflows supply the runner, toolchain, and install steps. Each CI-enabled repository remains the authority for the checks it declares.

| Class | Required contract | Who owns the check list |
| --- | --- | --- |
| Go CLI | `make ci` | The repository Makefile |
| Live Node | `ci` script in package.json | `package.json` scripts |
| Python tool | `make ci` | The repository Makefile |
| Docs-only | None (class-drift only) | This repo's `docs-only.yml` |

If the contract exists, the reusable workflow runs **only** that contract.

If the contract is absent, the workflow runs a documented fallback (below). It fails with a non-zero exit and a pointer to this file only when the repository has application source **and** the fallback would run zero checks (a silent green). A lockfile or manifest scaffold with no application source is caller-less: skip checks, do not fail (`itsjeremyjohnson/finance` is the Node example).

Add the class contract when convenient; issue #5 will add migration gates, and copied CI should not be removed until the replacement has a successful authoritative run. See [migration.md](migration.md). Nash or Jeremy approve exceptions; record them in [inventory.md](inventory.md).

## Go CLI

Detect: `go.mod` and a `cmd/` tree (or a `package main` at the root).

Caller: `.github/workflows/ci.yml` that only calls `go-cli.yml@v1`.

**Contract:** `make ci`. When that target exists, the reusable workflow runs only `make ci`.

**Fallback** (no `make ci`): run existing Makefile targets among `fmt-check`/`fmt` (prefer `fmt-check`), `lint`, `vet`, `test`, and `build`. If a format, vet, or test target is missing, use `gofmt -l .`, `go vet ./...`, and `go test ./...` as today. A Makefile `lint` target is never dropped.

**Caller-less / fail-clearly:** a module scaffold with no `.go` source skips checks. A repository with source, no `make ci`, and a fallback that would run zero checks fails and points here.

Examples: `itsjeremyjohnson/wpssh` (Makefile `ci` is `fmt-check lint test`), `itsjeremyjohnson/cli-template`.

Not this class: `homebrew-tap`.

## Live Node

Detect: `package.json` plus a lockfile (`bun.lock` / `bun.lockb`, `pnpm-lock.yaml`, `package-lock.json`, or `yarn.lock`).

Caller: `node-bun.yml@v1`. The workflow picks the package manager from the unique lockfile. Do not add a fifth class for pnpm.

If more than one supported lockfile is present, pass `package-manager`. `bun-version` defaults to `1.4.0` (callers can override). Yarn enables Corepack; Yarn 1 installs frozen, Yarn 2+ installs immutable. Cache keys use the detected lockfile path, not the working directory.

**Contract:** a `ci` script in `package.json`, invoked with the lockfile's package manager.

**Fallback** (no `ci` script): run `lint`, `typecheck`, `test`, and `build` when those scripts exist. If the lockfile is Bun and there is no `test` script, run `bun test` unless `test:*` scripts exist (those stay caller-owned; the reusable fallback does not run them). Frozen/immutable installs stay as on current main.

**Caller-less / fail-clearly:** a lockfile scaffold with no application source stays caller-less — hold the caller; if the workflow is invoked it skips checks rather than failing. `itsjeremyjohnson/finance` (lockfile + `package.json` + `tsconfig.json`, no source) is the example. A repository with source, no `ci` script, and no fallback checks fails and points here.

Hold the caller until there is source to lint, typecheck, test, or build.

Examples: `meal-planning` (keep its extra QC job), `insurance`, `program-moms-scanner`, `appraisals`, `DOAR` (pass `working-directory` if needed). `finance` is this class but stays caller-less until it has source.

## Python tool

Detect: `requirements.txt` or `pyproject.toml`, plus tests or a runnable module.

Caller: `python-tool.yml@v1`. Installs `requirements-test.txt` when present, otherwise `requirements.txt` or `pyproject.toml`, then runs the contract or fallback.

**Contract:** `make ci`. When that target exists, the reusable workflow runs only `make ci`.

**Fallback** (no `make ci`): if the Makefile has `lint` and/or `test`, run those; else if ruff, black, mypy, or pytest is configured or declared as a dependency, run those tools (ruff check + ruff format --check, black --check, mypy, pytest); else `pytest` when a test tree exists, or `compileall` when there is Python source and no tests.

**Caller-less / fail-clearly:** a manifest-only scaffold with no `.py` source skips checks. A repository with source, no `make ci`, and a fallback that would run zero checks fails and points here.

Examples: `fleet`, `hermes`, `robben-triage`.

## Docs-only

Detect: markdown, HTML, or other docs with no app manifest.

No caller by default. `docs-only.yml@v1` is a class-drift check. It fails when a supported or out-of-catalog app marker appears, and names the file plus the class or `out of catalog`.

Supported markers: `go.mod` (Go CLI); `package.json` and JS lockfiles (Live Node); `pyproject.toml`, `requirements.txt`, `requirements-test.txt`, `Pipfile` (Pipenv), `uv.lock` (uv) (Python tool).

Out-of-catalog markers: `Cargo.toml` (Rust), `composer.json` (Composer/PHP), `Gemfile` (Ruby), `deno.json` / `deno.jsonc` (Deno).

Examples: `loan-negotiations`, `appraisal-training`, `johnson-family-insurance`, `vicki-adams-career`, `gstack-artifacts-jeremydjohnson`.

## Out of catalog

Do not invent a class for these. Leave them alone unless GitHub Manager assigns a one-off.

- Homebrew taps
- OpenClaw / agent workspace trees
- Archives and forks
- Empty twins (409 / no default-branch content)
- WordPress / PHP trees (including Composer)
- Ruby, Deno, and Rust app trees

## Inventory and migration

Do not keep a second inventory in a caller.

- [inventory.md](inventory.md) — authoritative class list and status
- [equivalence/](equivalence/) — representative comparisons
- [migration.md](migration.md) — gates and exception approval
