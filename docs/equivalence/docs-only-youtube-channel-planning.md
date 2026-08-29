# Docs-only — `Robben-Media/youtube-channel-planning`

Status: `held`. RM private docs tree.

Compared 2026-08-28 via `gh api` (no clone):

- Root: `README.md`, `START-HERE.md`, `LAUNCH-READY-SUMMARY.md`, `POSITIONING-UPDATE.md`, `CLAUDE.md`, `content-strategy/`, `foundation/`, `growth-marketing/`, `legal-compliance/`, `operations/`, `production/`, `.gitignore`, `.github/`, `.greptile/`
- No `go.mod`, `package.json`, lockfile, `pyproject.toml`, `requirements.txt`, `Cargo.toml`, `Pipfile`, `uv.lock`, `composer.json`, `Gemfile`, or `deno.json`
- Workflows: `ci.yml` (echo-stub on `blacksmith-2vcpu-ubuntu-2404`), `claude.yml`
- Shared: `docs-only.yml@472bfa1` (optional class-drift check)

`write-a-book` is another RM docs-only tree (markdown + hooks + echo-stub). Not chosen; this repo has a fuller docs layout.

## Existing checks (copied CI)

Same echo-stub as other RM placeholders: checkout, then echo setup/lint/test. Not a class-drift check.

## Shared `docs-only.yml` checks

Fail if a supported or out-of-catalog app marker is present. Pass when none are.

On this default branch, the expanded marker list would pass (no marker files at root).

## Comparison

| Check | Verdict | Notes |
| --- | --- | --- |
| Echo setup/lint/test | omitted (intentional) | Catalog says remove echo-stub CI on docs-only, do not replace it with a caller. |
| Class-drift (`docs-only.yml@v1`) | added (optional) | Only if someone wants CI to fail when an app manifest appears. Not required. |
| `claude.yml` | caller-specific | Unchanged. |

## Gate

Do not delete the echo-stub until the adoption gate is green **and** the chosen replacement (nothing, or an optional `docs-only.yml@v1` caller) has a successful authoritative run. This change does not remove it.
