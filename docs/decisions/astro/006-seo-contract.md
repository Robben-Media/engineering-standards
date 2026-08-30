# 006 — SEO contract

Status: approved 2026-08-29. Part of the [Astro profile](../../profiles/astro.md).

## Decision

SEO checks are release-blocking: a failing SEO or link audit blocks the release, the same as a failing build.

**Per-page metadata**

- Title rules, exact and site-wide:
  - Home: one complete editorial title, written by hand, containing the site name once. No automatic suffix is appended.
  - Every inner page: `{Page title} | {Site name}`, each side exactly once.
- Exactly one description per page, unique across the site, nonempty. No hard truncation of titles or descriptions anywhere — length is advisory; software must never silently cut a title or meta description.
- `og:url` equals the page's canonical URL.
- Social image: 1200x630 JPG or PNG, absolute URL, with `og:image:alt`. Every indexable page has one (page-specific or a declared site default).
- Production robots directive: `index,follow,max-image-preview:large`.

**Nonproduction**

- Staging and preview stay behind authentication and send exactly `X-Robots-Tag: noindex, nofollow` on every response, with a matching `<meta name="robots" content="noindex, nofollow">` in the HTML. Header and meta never disagree.

**Crawled surfaces**

- Sitemap: canonical URLs only, indexable pages only, 2xx responses only.
- RSS: absolute canonical links (never relative, never host-derived).
- Error responses are real 404s: `noindex`, served at the requested URL (never redirected home), no canonical tag, excluded from the sitemap.
- Pagination: every paginated listing is crawlable and self-canonical — page 2 canonicals to page 2, linked from the sequence, never collapsed onto page 1.

**Structured data**

- One stable, connected JSON-LD graph generated from `src/lib/seo/` ([004](004-source-layout.md)), not hand-copied per page. Nodes carry stable `@id`s, exact forms: `https://<preferred-origin>/#organization`, `https://<preferred-origin>/#website`, `{canonical}#webpage`, plus `#primaryimage`, `#breadcrumb`, `#article`, `#service` as applicable.
- The homepage emits the full `WebSite` node; the full `Organization` node sits on the homepage or the About page; every other page references those nodes by their stable `@id`s.
- `LocalBusiness` (or a subclass) only for a real business with a real customer-facing location. No `ProfessionalService` fallback default.
- Unsupported schema fields are **rejected** (validation failure in build or audit), never silently dropped — a dropped field hides an authoring mistake.

**Enforcement**

- Audits run against rendered output (the production build or the started server), not against source files. Static and server repos meet the same bar.
- Hostile-host check, aligned with [001](001-url-policy.md): production alias hosts redirect to the preferred HTTPS origin; known nonproduction hosts stay authenticated with `X-Robots-Tag: noindex, nofollow`; an unknown `Host`/`X-Forwarded-Host` is **rejected before rendering**. Canonical pinning alone is not sufficient for an unknown host — the artifact must refuse to serve it at all.
- Passing the rendered audits is **mandatory to claim profile conformance**. An existing site may carry only a dated migration gap registered in the [profile register](../../profiles/astro.md#exception-register) — and even then, canonical hygiene, 404 behavior, and staging `noindex` cannot be carried as gaps.

## Reason

Robben Media is an SEO company; the survey found canonical, title, and sitemap drift across otherwise similar sites. Exact formulas and exact header values make the checks binary, and rendered-output audits are the only checks that see what a crawler sees.

## Static behavior

Audits crawl the built `dist/` output: title formula, description uniqueness, canonicals, `og:url`, JSON-LD graph connectivity, social-image presence/size/alt, robots directives, sitemap and `robots.txt` agreement, RSS links.

## Server delta

The `ci` pipeline starts the built server ([007](007-ci-order.md)) and runs the same audits against its responses, then serves the artifact from a wrong `Host` and asserts the hostile-host behavior. Staging adds authentication plus the exact `X-Robots-Tag` header and meta pair.

## CI proof

`audit:seo` and `audit:links` in the `ci` order, after the production build and before e2e/a11y. Failure exits non-zero and blocks release ([007](007-ci-order.md)).

## Shared library status

`rm-astro-seo` is the intended shared SEO implementation and is **not** ready. It becomes mandatory only after its known defects are fixed, it has CI, it has a release, and pilot sites pass on it. Until then each site implements this contract with its own components and `src/lib/seo/` helpers; the contract — not the library — is the requirement.

## Exceptions

Register entries only, in the [profile register](../../profiles/astro.md#exception-register), naming decision, exception, reason, compensating control, owner, approval and review dates, and exit condition. There is no exception to canonical-host pinning, 404 behavior, or nonproduction `noindex` — a dated migration gap can cover the rest only while its exit condition is unmet.

## Migration notes

Sites adopt the audits incrementally, but canonical hygiene, 404 behavior, and nonproduction `noindex` are fixed immediately — those are the defects the survey actually found. Keep the audits honest: a check that cannot fail is not a check.
