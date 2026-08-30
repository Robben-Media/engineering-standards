# Astro profile

One profile for every Robben Media Astro repo. Normative.

Astro stays inside the **Live Node** class: label `class:node-bun`, caller `node-bun.yml@v1`. There is no `class:astro` label and no fifth reusable workflow. The profile adds contracts on top of the class; the class workflow itself does not grow Astro steps.

Detect: an Astro repo is a Live Node repo with an `astro` dependency and an `astro.config.*` file. Detection is a catalog convention here — CI is still just the class contract: the package-manager `ci` script.

## Output modes

Static output is the default. Node standalone is the only server extension.

| Mode | Config | Use |
| --- | --- | --- |
| static (default) | `output: "static"` | Marketing and content sites |
| server (extension) | `output: "server"` + `@astrojs/node`, `mode: "standalone"` | Apps that need runtime rendering |

Static and server share the URL, SEO, source, tooling, CI, accessibility, environment, security, artifact, and rollback contracts. Server adds only the deltas named in each record.

## Toolchain pins

- Bun is the package manager and task runner. Node is the tooling runtime and the standalone server runtime.
- Every profiled repo pins `"packageManager": "bun@1.4.0"`, `"engines": { "node": ">=22.23.2 <23" }`, and a `.node-version` of exactly `22.23.2`.
- Callers pass `node-version: 22.23.2` to `node-bun.yml`. The class default stays `22`; this profile does not change it for non-Astro repos.

## Decisions

Each record covers decision, reason, static behavior, server delta, CI proof, exceptions, and migration notes.

| Record | Decision |
| --- | --- |
| [001 — URL policy](../decisions/astro/001-url-policy.md) | Directory URLs, canonical host, one-hop 301 matrix, host allow/deny cases |
| [002 — Lint and format](../decisions/astro/002-lint-format.md) | ESLint 10 flat + typed typescript-eslint + eslint-plugin-astro, Prettier 3, `astro/tsconfigs/strictest` |
| [003 — Script contract](../decisions/astro/003-script-contract.md) | Mandatory fixed script vocabulary owned by `ci`; server adds `start` |
| [004 — Source layout](../decisions/astro/004-source-layout.md) | Approved `src/` tree, loader collections, Astro-first, React islands only |
| [005 — Environment contract](../decisions/astro/005-environment-contract.md) | Pinned Bun and Node, typed env schema, complete `.env.example`, no secrets in artifacts |
| [006 — SEO contract](../decisions/astro/006-seo-contract.md) | Release-blocking rendered SEO/link audits, canonical and hostile-host rules |
| [007 — CI order](../decisions/astro/007-ci-order.md) | Frozen pipeline owned by the repository `ci` script |
| [008 — Security headers](../decisions/astro/008-security-headers.md) | One header owner, enforced CSP, HSTS ramp, header/cache response table |
| [009 — Deployment](../decisions/astro/009-deployment.md) | Immutable artifact, atomic switch, smoke matrix, rollback; server runtime contract |

## Exception register

One register for every Astro profile exception. Site repos link their local entries here; this repo owns the rows. Nash or Jeremy approve each entry, and every entry names the decision, the exception, the reason, the compensating control, the owner, approval and review dates, and the exit condition. The caller-extra-job table in [inventory.md](../inventory.md) stays separate — it records extra CI jobs, not profile exceptions.

| Repo | Decision | Exception | Reason | Compensating control | Owner | Approved | Review | Exit |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| — none — | | | | | | | | |

## Shared SEO library status

`rm-astro-seo` is the intended shared SEO implementation. It is **not** ready and nothing here makes it mandatory. It becomes the required implementation only after its defects are fixed, it has CI and a release, and pilot sites pass on it. Until then, sites implement [006](../decisions/astro/006-seo-contract.md) directly. `create-astro-site` may generate and audit conformance; this repo owns the policy.

## Fixtures

`fixtures/astro-static` and `fixtures/astro-server` in this repo prove profile detection and the Bun/Node workflow path through `node-bun.yml`. They run reduced `ci` probes under the [003](../decisions/astro/003-script-contract.md) fixture carveout, use local no-registry stubs instead of real packages, and are not classes.
