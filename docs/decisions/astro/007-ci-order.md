# 007 — CI order

Status: approved 2026-08-29. Part of the [Astro profile](../../profiles/astro.md).

## Decision

CI is one ordered pipeline, owned by the repository's `ci` script ([003](003-script-contract.md)). The order is frozen:

1. Frozen install (`node-bun.yml`, before `ci` runs)
2. Conformance (`conformance`)
3. Format (`format:check`)
4. Lint (`lint`)
5. Type check (`typecheck` — `astro check`)
6. Unit tests (`test`)
7. Production build (`build`), including generating the static hash-bearing host configuration from the final HTML — CSP hashes and the real host config — before any served-response audit
8. Rendered SEO and link audits (`audit:seo`, `audit:links`) — [006](006-seo-contract.md)
9. Served-response header and cache audit: against the served artifact (static preview server, or the started standalone server), assert status, security headers, and cache policy across 200 pages, 301 redirects, 404 responses, hashed assets, and `/health/*` endpoints where applicable — [008](008-security-headers.md)
10. Playwright e2e and axe (`test:e2e`, `test:a11y`)
11. Hostile-host checks — both modes. Static validates the generated host configuration for approved-alias, nonproduction, and unknown-host handling; server sends hostile `Host` and `X-Forwarded-Host` requests to the standalone service/proxy test setup — [001](001-url-policy.md)
12. Secret scan on the artifact
13. Artifact archive, SHA-256 digest, and release metadata (site `ci`)

The reusable workflow stays thin: `node-bun.yml` detects the package manager, installs frozen, and runs `ci`. The long sequence never moves into `node-bun.yml`.

A step a site has not adopted yet is a documented gap in that site, not a reorder. Steps land in this order; a step that exists must not be skipped silently.

### Artifact pipeline

- **Current tranche.** Step 13 produces the archive, its SHA-256 digest, and release metadata. The reusable workflows implement validation and digest only.
- **Required publisher job (future, pinned — not an optional design).** A dependent pinned publisher job — a caller job or reusable workflow pinned like everything else, carrying the `contents: write` / `attestations: write` permissions the thin `ci` contract must not hold — uploads **that exact artifact** and creates the GitHub attestation, **without rebuilding**. It has not landed, so **no site can claim full artifact conformance yet**.
- **Deploy constraint.** Deploys consume the CI-built artifact and never rebuild, and they never generate or mutate CSP hashes — the deploy verifies and installs the exact generated host configuration ([008](008-security-headers.md)). Until the publisher job lands and is pinned, a deploy must name the artifact it serves ([009](009-deployment.md)).
- **Reusable-workflow scope.** No artifact or attestation actions are added to the reusable workflows in this tranche.

## Reason

Cheapest checks fail first, audits run against the real production build rather than a dev server, and security evidence is produced before anything is published. One shared order makes CI logs comparable across the estate, and the ownership split keeps the reusable workflow permission-minimal while sites still get a verifiable digest.

## Static behavior

All thirteen steps. The served-response audit (step 9) runs against a preview server over the built output, and the hostile-host check (step 11) validates the generated host configuration: approved aliases redirect, nonproduction stays authenticated and `noindex`, unknown hosts are rejected.

## Server delta

`ci` starts the built standalone server (`start` contract, [009](009-deployment.md)) for steps 8–11 and stops it afterward. Step 9's health-endpoint checks apply where the server exposes them, and step 11 sends hostile `Host` and `X-Forwarded-Host` requests to the standalone service/proxy test setup.

## CI proof

Fixture CI proves the plumbing: `fixtures/astro-static` and `fixtures/astro-server` run a reduced `ci` (profile-config validation) through `node-bun.yml` under the [003](003-script-contract.md) carveout. Site repos run the full order through the same entry point.

## Exceptions

New steps are appended pending a record change; reordering requires changing this record first. Skipping a step in a given repo needs a register entry in the [profile register](../../profiles/astro.md#exception-register): decision, exception, reason, compensating control, owner, approval and review dates, exit condition. Steps named release-blocking in [006](006-seo-contract.md) cannot be skipped at all.

## Migration notes

Sites consolidate their existing scripts into `ci` in this order; until then the old caller stays, per the migration gates. Do not parallelize steps across this order — the order is the contract. When the publisher job lands, it consumes the step-13 archive and digest; it must not rebuild.
