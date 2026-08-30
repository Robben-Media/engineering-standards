# 003 — Script contract

Status: approved 2026-08-29. Part of the [Astro profile](../../profiles/astro.md).

## Decision

`package.json` scripts use this fixed vocabulary. A script with one of these purposes uses exactly this name; no aliases.

| Script | Meaning |
| --- | --- |
| `dev` | Local dev server |
| `build` | Production build |
| `preview` | Preview the production build |
| `typecheck` | `astro check` (types + diagnostic pass) |
| `lint` | `eslint . --max-warnings 0` |
| `lint:fix` | `eslint . --max-warnings 0 --fix` |
| `format` | Prettier write |
| `format:check` | Prettier check |
| `test` | Unit tests, run once |
| `test:watch` | Unit tests in watch mode |
| `test:coverage` | Unit tests with coverage |
| `test:e2e` | Playwright end-to-end |
| `test:a11y` | axe checks on rendered pages |
| `audit:seo` | Rendered-output SEO audit |
| `audit:links` | Rendered-output link audit |
| `conformance` | Profile conformance check |
| `ci` | The ordered pipeline in [007](007-ci-order.md) |
| `start` | Server repos only: run the built Node standalone server |

For a real profiled site the full vocabulary is **mandatory**: every static repo exposes the whole list minus `start`; every server repo exposes the whole list including `start`. Every declared script does the real named work. Specifically:

- No placeholders. A script that echoes, exits 0, or defers to a comment is a defect.
- No `--passWithNoTests` in `test` (or anywhere a missing suite would silently pass).
- No hidden checks. Every check a repo runs is reachable from `ci`; a check that runs only locally or only in a side workflow does not exist as far as this profile is concerned.
- No tests that write to production. Tests run against fixtures, local services, or staging — never against production data or production URLs.

A migration gap (a script that does not exist yet) requires a dated register entry in the [profile register](../../profiles/astro.md#exception-register), and a site with a missing script **cannot claim profile conformance** until the gap closes.

**Fixture carveout:** only `fixtures/astro-static` and `fixtures/astro-server` in this repository are exempt. They declare reduced scripts (`test`, `ci`) because they are detection probes, not sites: they prove profile detection and the Bun/Node workflow plumbing with local no-registry stubs, and they install no real tooling. No caller site may copy the reduced shape.

## Reason

The Live Node class contract invokes the `ci` script, and agents and humans need one predictable vocabulary across every Astro repo instead of per-site synonyms. Real work in every script is what makes the class workflow's "run `ci`" trustworthier than the echo stubs it replaces.

## Static behavior

The full vocabulary minus `start` — `start` must not exist in a static repo.

## Server delta

Server repos add `start` (the Node standalone entry, see [009](009-deployment.md)); nothing else changes.

## CI proof

`node-bun.yml` runs the package-manager `ci` script — nothing else. `fixtures/astro-static` and `fixtures/astro-server` prove the plumbing with the carved-out reduced contract.

## Exceptions

Extra helper scripts are allowed but must not shadow or rename vocabulary names. A missing script is a migration gap only with a dated register entry in the [profile register](../../profiles/astro.md#exception-register), and the site cannot claim conformance while the gap stands. Deviations beyond that — reduced vocabularies, placeholder scripts, `--passWithNoTests` — are register entries too, not site-local choices.

## Migration notes

Renames land together with the CI and doc references that use the old name. Never keep an old-named alias "temporarily" — the old name either no longer exists or this record was wrong. Removing a placeholder script and its caller references is one PR.
