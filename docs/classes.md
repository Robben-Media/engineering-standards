# Repo classes

Classify by what is on the default branch, not by the GitHub language badge.

## Go CLI

Detect: `go.mod` and a `cmd/` tree (or a `package main` at the root).

Caller: `.github/workflows/ci.yml` that only calls `go-cli.yml@v1`.

The reusable workflow runs `gofmt`, `go vet`, and `go test ./...`. It uses `make fmt-check` / `make test` when those targets exist.

Examples: `itsjeremyjohnson/wpssh`, `itsjeremyjohnson/cli-template`.

Not this class: `homebrew-tap`.

## Live Node

Detect: `package.json` plus a lockfile (`bun.lock` / `bun.lockb`, `pnpm-lock.yaml`, `package-lock.json`, or `yarn.lock`).

Caller: `node-bun.yml@v1`. The workflow picks the package manager from the lockfile. Do not add a fifth class for pnpm.

Hold the caller until there is source to lint or test.

Examples: `meal-planning` (keep its extra QC job), `insurance`, `program-moms-scanner`, `appraisals`, `DOAR` (pass `working-directory` if needed). `finance` is this class but stays caller-less until it has source.

## Python tool

Detect: `requirements.txt` or `pyproject.toml`, plus tests or a runnable module.

Caller: `python-tool.yml@v1`. Installs `requirements-test.txt` when present, otherwise `requirements.txt` or `pyproject.toml`, then `pytest` (or `compileall` when there is no test tree).

Examples: `fleet`, `hermes`, `robben-triage`.

## Docs-only

Detect: markdown, HTML, or other docs with no app manifest.

No caller by default. `docs-only.yml@v1` is a class-drift check: it fails if `go.mod`, `package.json`, a JS lockfile, `pyproject.toml`, `requirements.txt`, or `Cargo.toml` appears.

Examples: `loan-negotiations`, `appraisal-training`, `johnson-family-insurance`, `vicki-adams-career`, `gstack-artifacts-jeremydjohnson`.

## Out of catalog

Do not invent a class for these. Leave them alone unless GitHub Manager assigns a one-off.

- Homebrew taps
- OpenClaw / agent workspace trees
- Archives and forks
- Empty twins (409 / no default-branch content)
