# Repo classes

Classify by what is on the default branch, not by the GitHub language badge.

## Go CLI

Detect: `go.mod` and a `cmd/` tree (or a `package main` at the root).

Caller: `.github/workflows/ci.yml` that only calls `go-cli.yml@v1`.

The reusable workflow runs `gofmt`, `go vet`, and `go test ./...`. It uses `make fmt-check` / `make test` when those targets exist.

Examples: `itsjeremyjohnson/wpssh` (intended representative, `held`), `itsjeremyjohnson/cli-template`.

Not this class: `homebrew-tap`.

## Live Node

Detect: `package.json` plus a lockfile (`bun.lock` / `bun.lockb`, `pnpm-lock.yaml`, `package-lock.json`, or `yarn.lock`).

Caller: `node-bun.yml@v1`. The workflow picks the package manager from the lockfile. Do not add a fifth class for pnpm.

Hold the caller until there is source to lint or test.

Intended representative: `Robben-Media/police-scanner-feed` (`held`). Examples: `meal-planning` (keep its extra QC job), `insurance`, `program-moms-scanner`, `appraisals`, `DOAR` (pass `working-directory` if needed). `finance` is this class but stays caller-less until it has source.

## Python tool

Detect: `requirements.txt` or `pyproject.toml`, plus tests or a runnable module.

Caller: `python-tool.yml@v1`. Installs `requirements-test.txt` when present, otherwise `requirements.txt` or `pyproject.toml`, then `pytest` (or `compileall` when there is no test tree).

Examples: `fleet`, `hermes`, `robben-triage`. `fleet` is the intended representative (`held`). `hermes` and `robben-triage` have no root `pyproject.toml` or `requirements.txt` on the default branch observed 2026-08-28; they stay unclassified until a manifest appears. See [inventory.md](inventory.md).

## Docs-only

Detect: markdown, HTML, or other docs with no app manifest.

No caller by default. `docs-only.yml@v1` is a class-drift check. It fails when a supported or out-of-catalog app marker appears, and names the file plus the class or `out of catalog`.

Supported markers: `go.mod` (Go CLI); `package.json` and JS lockfiles (Live Node); `pyproject.toml`, `requirements.txt`, `requirements-test.txt`, `Pipfile` (Pipenv), `uv.lock` (uv) (Python tool).

Out-of-catalog markers: `Cargo.toml` (Rust), `composer.json` (Composer/PHP), `Gemfile` (Ruby), `deno.json` / `deno.jsonc` (Deno).

Examples: `Robben-Media/youtube-channel-planning` (intended representative, `held`), `loan-negotiations`, `appraisal-training`, `johnson-family-insurance`, `vicki-adams-career`, `gstack-artifacts-jeremydjohnson`.

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
- [equivalence/](equivalence/) — representative comparisons (all `held`)
- [migration.md](migration.md) — gates and exception approval
