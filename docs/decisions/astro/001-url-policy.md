# 001 — URL policy

Status: approved 2026-08-29. Part of the [Astro profile](../../profiles/astro.md).

## Decision

HTML pages are directory URLs. Every Astro repo sets `trailingSlash: "always"` and `build.format: "directory"`. The canonical form of an HTML route is `https://<preferred-host>/<path>/`, where the preferred host is the origin configured in `Astro.site`.

File-like endpoints stay file-like: RSS, sitemaps, JSON routes, `/.well-known/`, and downloads keep file names with no trailing slash.

Canonical URLs derive from `Astro.site` only. They never use the request `Host`, `X-Forwarded-Host`, or `Astro.url.origin`.

One-hop 301 matrix (every row is a single 301 to the target — no chains):

| From | To |
| --- | --- |
| `http://<any approved host>/…` | `https://<preferred-host>/…` |
| Approved production alias host (apex, `www`, legacy domain) | `https://<preferred-host>/…` |
| HTML path without the trailing slash | same path with `/` |
| `/path/index.html` | `/path/` |
| Retired route | nearest live parent, else `/` |

Host cases:

1. **Approved production aliases** redirect to the preferred HTTPS origin.
2. **Known nonproduction hosts** (staging, preview) stay behind authentication and send `X-Robots-Tag: noindex, nofollow` on every response ([006](006-seo-contract.md), [008](008-security-headers.md)).
3. **Unknown `Host` / `X-Forwarded-Host`** is rejected before rendering: no page, no canonical, no SEO surface — the artifact refuses to serve an identity the host config does not name.

## Reason

Directory URLs match static-hosting defaults and remove the slash/no-slash duplicate-content pair. A single canonical host keeps one indexable identity when a site is reachable from apex, `www`, staging, or a platform preview host, and rejecting unknown hosts turns a hostile-host mount into a hard failure instead of a duplicate site.

## Static behavior

`astro build` emits `<route>/index.html`. The host must serve `<route>/index.html` at `<route>/` and apply the 301 matrix in host config. Canonical tags, sitemaps, and internal links use `Astro.site` + the trailing-slash path.

## Server delta

Same config values and the same matrix, implemented in middleware or host rules. The standalone server compares the effective host (`Host`, plus `X-Forwarded-Host` when proxied) against the configured allowlist before rendering, and canonicalization to the preferred origin stays one hop. File-like endpoints from `output: "server"` API routes are exempt from the slash rule.

## CI proof

The repository `ci` script ([007](007-ci-order.md)) runs rendered audits (`audit:seo`, `audit:links`) and the served-response audit: every internal HTML link ends in `/`, every canonical equals `Astro.site` + path, and redirects in the matrix are one-hop 301s. Host policy is proven in both modes ([007](007-ci-order.md) step 11): static repos test the generated real host configuration for approved-alias, nonproduction, and unknown-host handling; server repos send hostile `Host` and `X-Forwarded-Host` requests to the standalone service/proxy test setup. `fixtures/astro-static` and `fixtures/astro-server` validate the config values in this repo.

## Exceptions

Register entries only, in the [profile register](../../profiles/astro.md#exception-register): intentionally unredirected legacy paths, third-party-verified `/.well-known/` paths, file endpoints served at HTML-like paths, and any additional approved alias host.

## Migration notes

Turning this on for an existing site requires same-PR host redirects for every row of the matrix the site violates, sitemap regeneration, and a rendered link audit. Do not ship the config change without the redirects.
