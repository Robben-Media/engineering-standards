# 005 — Environment contract

Status: approved 2026-08-29. Part of the [Astro profile](../../profiles/astro.md).

## Decision

Roles: **Bun is the package manager and task runner** (install, scripts, unit tests). **Node is the tooling runtime and the standalone server runtime.**

Pins, in every profiled repo:

- `package.json`: `"packageManager": "bun@1.4.0"`.
- `package.json`: `"engines": { "node": ">=22.23.2 <23" }`.
- `.node-version`: exactly `22.23.2`.
- Callers pass `node-version: 22.23.2` to `node-bun.yml` (the class default stays `22`; the caller input is where the Astro pin lands).

Environment variables:

- Every variable is declared in the typed `astro:env` schema. Code reads environment values only through the schema — no bare `import.meta.env` or `process.env` reads scattered through components.
- Classification defaults to **server** and **secret**. A variable is `public` only by deliberate decision, and its name must make that unambiguous (the `PUBLIC_` prefix for client-visible values); nobody discovers a secret was public from a bundle dump.
- `astro:env` cannot load inside `astro.config.mjs`, so config files that need a variable use a **narrow config-time validator derived from the same definition** — it validates only what config-time code consumes, while the schema remains the single source the runtime types come from. Duplicate definitions beyond that narrow derived validator are defects.
- `.env.example` is complete: every declared variable with a safe placeholder, updated in the same PR as the schema. No committed env files of any other name.
- No secrets in artifacts. Client bundles never contain a secret; build-time-only secrets must not be recoverable from the built artifact, logs, or CI summaries; server secrets are injected at runtime ([009](009-deployment.md)).

## Reason

Bun is already the estate's install/test runtime; keeping it avoids a second toolchain, and pinning `packageManager`/`engines`/`.node-version` makes "works on my machine" checkable. Typed env schemas turn "missing variable" from a runtime surprise into a check failure, server/secret-by-default stops accidental public leaks, and complete `.env.example` files stop credential-shaped values from being pasted into chat or issues.

## Static behavior

Static sites declare public values as schema `public` variables. Any private build-time value (CMS tokens, API keys) is read only at build, and the built output must not contain it — the secret-scan step ([007](007-ci-order.md)) checks the artifact.

## Server delta

Build-time values in server repos follow the same classification as everywhere else: **server/secret by default**, with only explicitly client-visible (`PUBLIC_`) values public. Runtime secrets stay out of the client-visible side entirely and are injected at `start` by the process manager ([009](009-deployment.md)). The server never bakes a runtime secret into a rendered page.

## CI proof

`typecheck` fails on undeclared or wrongly-classified env access. The `ci` pipeline's secret-scan step scans the production artifact. `fixtures/astro-static` and `fixtures/astro-server` run through `node-bun.yml` with pinned Bun and Node. The fixture `package.json` files carry the pin shape (`packageManager`, `engines`, `.node-version`) so the contract is machine-checked here too.

## Exceptions

Any secret that must exist in an artifact, a committed env file, or a public classification that is not `PUBLIC_`-clear gets a register entry in the [profile register](../../profiles/astro.md#exception-register): decision, exception, reason, compensating control, owner, approval and review dates, exit condition. Expect this list to stay empty.

## Migration notes

Move ad-hoc `import.meta.env` reads into the schema incrementally, but a variable added to the schema must land with its `.env.example` entry in the same PR. Version bumps to the Bun/Node pins are a profile change, not a site choice. Existing hardcoded values are defects, not exceptions.
