# 008 — Security headers

Status: approved 2026-08-29. Part of the [Astro profile](../../profiles/astro.md).

## Decision

**One header owner per site.** Exactly one layer (host config, server middleware, or edge config) sets the final security headers; the app never sets competing values, and the owner is named in the repo.

**Baseline headers (enforced on every HTML response):**

| Header | Value |
| --- | --- |
| `Content-Security-Policy` | site policy, enforced (never report-only in production), meeting the minimum below |
| `Strict-Transport-Security` | ramped per this record; target `max-age=63072000` |
| `X-Content-Type-Options` | `nosniff` |
| `Referrer-Policy` | `strict-origin-when-cross-origin` |
| `Permissions-Policy` | `accelerometer=(), camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), payment=(), usb=()` |
| `X-Frame-Options` | `DENY` — legacy fallback that must match CSP `frame-ancestors 'none'`; a framing exception changes both coherently |

**Minimum CSP directives:** `default-src 'self'; object-src 'none'; base-uri 'self'; form-action 'self'; frame-ancestors 'none'` — `frame-ancestors` becomes a real allowlist only where framing is a deliberate feature, and any such exception updates `X-Frame-Options` in the same change.

**Static repos:** CSP is delivered as an HTTP response header by the host config. Hashes for inline scripts and styles are generated in CI from the final built HTML, included in the host config, audited, archived, and digested there ([007](007-ci-order.md)); the audit fails on built inline code with no matching hash. Deployment only verifies and installs the exact config. `<meta http-equiv="Content-Security-Policy">` is not a substitute — it cannot carry `frame-ancestors` or report-only semantics and arrives too late to govern the document load.

**Server repos:** when a response needs inline code, middleware attaches a per-response cryptographically random nonce. A nonce is never reused, never static, and responses carrying one must not be cacheable by shared caches.

- **No second CSP.** The reverse proxy forwards the one CSP unchanged; appending a second CSP only further restricts and breaks the intended policy.
- **No `unsafe-inline`, no `unsafe-eval`** without a dated register entry.
- **Third-party origin inventory:** every origin any header allows is listed in a site inventory (with a reason per origin); the inventory and the headers change in the same PR.

**HSTS rollout without `preload`:** ramp `max-age` from minutes up to `max-age=63072000`; add `includeSubDomains` only after a subdomain audit proves every subdomain serves HTTPS; `preload` is never a default.

**Cache policy (exact):**

| Response | `Cache-Control` |
| --- | --- |
| Fingerprinted build output (`/_astro/**`) | `public, max-age=31536000, immutable` |
| Public static HTML | `no-cache` |
| Redirect responses (301) | `no-cache` |
| Nonproduction HTML | `no-store` |
| Public SSR HTML | `no-store`, unless the route has a reviewed public-cache design |
| Personalized or authenticated responses | `private, no-store` |
| `/health/*` | `no-store` |
| Error responses | `no-store` |

No profile-mandated duration exists for unhashed public assets, sitemap, or RSS; the site picks a defensible value and records it with the header owner.

**Public-response checks** ([007](007-ci-order.md) step 9): the served-response audit asserts the baseline headers and cache values on 200 pages, 301 redirects, 404 responses, assets, proxy error pages, and health endpoints (where applicable), plus `X-Robots-Tag: noindex, nofollow` and authentication on nonproduction ([006](006-seo-contract.md)).

## Reason

Header settings were per-site folklore: inconsistent CSP, no HSTS plan, and caches that could serve a stale release. One owner makes "who set this header" answerable, and enforced CSP is the control that actually stops injected script.

## Static behavior

The host/CDN config owns the headers. CSP hashes and the final host configuration are generated from the built output and audited in CI, before archive/digest ([007](007-ci-order.md)); the audit fails on built inline code with no matching hash. Deployment only verifies and installs the exact config — it never generates or mutates hashes.

## Server delta

The Node standalone server (or its reverse proxy, per [009](009-deployment.md)) owns headers. Middleware attaches nonces for dynamic responses that need them; the trusted proxy must forward — never strip, never append to — the security headers.

## CI proof

Step 9 of the `ci` order runs the served-response audit described above. Failure exits non-zero and blocks release.

## Exceptions

Register entries only, in the [profile register](../../profiles/astro.md#exception-register): `preload` HSTS, report-only CSP in production, `unsafe-inline`/`unsafe-eval`, a second header-writing layer, and any header or cache-value deviation. Each entry names decision, exception, reason, compensating control, owner, approval and review dates, and exit condition.

## Migration notes

Inventory inline scripts and styles before switching on hash CSP, then roll out report-only briefly to catch stragglers before enforcement. Ramp HSTS `max-age` from minutes to months; audit subdomains before `includeSubDomains`; do not add `preload` while ramping.
