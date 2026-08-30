# 009 — Deployment

Status: approved 2026-08-29. Part of the [Astro profile](../../profiles/astro.md).

## Decision

Deploys ship the exact immutable artifact CI built ([007](007-ci-order.md)). The digest recorded by `ci` is verified at deploy time; a mismatch aborts. There is **no rebuild and no install on the host** — no `bun install`, no `npm install`, no build step in the deploy path.

**Pipeline and safety**

- Deploy workflows run against a **GitHub Environment with required reviewers**, so a human approves production.
- A **GitHub Actions concurrency group keyed by repository plus environment**, with `cancel-in-progress: false`: one Actions run never cancels another mid-switch. That is workflow hygiene, **not** a deploy lock.
- A real **on-host lock** (`flock` or equivalent) serializes the switch, so two deploys can never interleave on the machine.
- Third-party actions in deploy workflows are pinned to **full commit SHAs**, same as this repo.
- SSH access uses a **least-privilege deploy user** (write only to `releases/` and the switch), and SSH **host keys are verified from an independent trusted source** — never accepted on first connect. One `known_hosts` file listing multiple verified hosts is fine; unverified keys are not.

**Release layout**

- `releases/<digest>/` directories plus a `current` symlink; the switch is the single atomic step, so no partial release is ever served.
- **Artifact contents.** A static artifact carries `dist/`, the host config, and release metadata/digest. A server artifact carries `dist/server/`, `dist/client/`, its compatible production runtime dependencies, the process-manager config, and release metadata/digest.
- `.well-known/` is preserved across releases (held outside the release directory or merged at switch).
- The deploy verifies and installs the exact CI-generated host configuration and artifact; it never generates or mutates CSP hashes ([007](007-ci-order.md), [008](008-security-headers.md)).
- Copying into a live `public_html` (or any live directory) is banned — a registered exception is required for hosts that cannot do the switch layout.

**Smoke test** after the switch, from a matrix at minimum: `/` is 200, one deep page is 200, a known redirect is a one-hop 301 to its canonical ([001](001-url-policy.md)), a missing path is 404, the sitemap is 200, and one hashed asset is 200. On failure, roll back by repointing `current` to the previous release and re-smoke. Rollback is a documented, rehearsed step, not an improvisation.

**Server repos additionally:**

- **Target compatibility:** before switch, verify the artifact matches the host target — OS, architecture, and the exact pinned Node version ([005](005-environment-contract.md)).
- Standalone Node bound to **loopback**, behind a **trusted reverse proxy** that terminates TLS, forwards the real client IP/proto, and forwards security headers untouched ([008](008-security-headers.md)).
- A process manager (**PM2 or equivalent**) restarts the service on failure.
- **`/health/live`** (liveness) and **`/health/ready`** (readiness) endpoints; the proxy uses readiness for routing.
- **Graceful reload** on release: readiness is withdrawn, new workers take over, then old ones stop — a deploy does not drop requests. Rollback after a switch is the same repoint plus reload.
- **Runtime secrets** are injected by the process manager/environment at `start` ([005](005-environment-contract.md)); never stored in the artifact.

## Reason

The estate's deployments were mostly hand-run copies to static hosts. An immutable artifact plus an atomic switch is what makes rollback trustworthy: rolling back means serving a previous artifact, not rebuilding the past. Environment approvals, locks, and full-SHA pins keep the deploy path as reviewed as the CI path.

## Static behavior

Upload the artifact, verify its digest, place it in `releases/<digest>/`, flip `current`, run the smoke matrix; roll back by flipping back. No host rebuild or install.

## Server delta

Everything above, plus target compatibility, the loopback/proxy/process-manager contract, `/health/live` and `/health/ready`, runtime-secret injection, and graceful reload with readiness withdrawn first.

## CI proof

The deploy procedure verifies the artifact digest from CI step 13 ([007](007-ci-order.md)), and the smoke matrix covers key routes, a redirect, a 404, and an asset on the canonical host. Server deploys smoke-test the started service, including a health endpoint. This tranche does not claim full artifact conformance: release publishing and GitHub attestation wait for the future pinned artifact job ([007](007-ci-order.md)).

## Exceptions

A non-atomic deploy path (managed platform, host without symlink semantics, live-directory copy) needs a register entry in the [profile register](../../profiles/astro.md#exception-register): decision, exception, reason, compensating control, owner, approval and review dates, and exit condition. Skipping the smoke matrix is not an exception.

## Migration notes

Sites document their current deploy in-repo first, then adopt the release switch, the deploy user/host key split, and the process manager incrementally. Digest verification lands with CI step 13; until then the deploy must name the artifact it is serving.
