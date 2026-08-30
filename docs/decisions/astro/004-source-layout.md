# 004 — Source layout

Status: approved 2026-08-29. Part of the [Astro profile](../../profiles/astro.md).

## Decision

One shared source tree for every Astro repo:

```
src/
  assets/              # processed images and fonts
  components/
    layout/            # page-frame components (headers, footers, shells)
    sections/          # composed page sections
    ui/                # primitive UI components
    forms/             # form and field components
    islands/           # React islands (the only place React lives)
  layouts/
  pages/
  styles/
    global.css         # Tailwind entry; the tailwindStylesheet target in [002]
  data/                # local structured data for non-collection content
  lib/
    client/            # browser-safe helpers
    server/            # server-only helpers
    seo/               # title/description/canonical/JSON-LD/social-image builders
  content/             # content collections content
  content.config.ts    # collection definitions
public/
tests/e2e/             # Playwright specs
scripts/               # repo scripts (audit, release, and conformance helpers)
```

The component directories are capability folders: a site omits one only when it has no such components, and when present its name never varies. SEO components' logic lives in `src/lib/seo/`, not in a component directory.

Content collections use the current loader API in `src/content.config.ts` (`glob()`/`file()` loaders, not the legacy `src/content/config.ts` types path), Zod schemas, explicit stable slugs (a slug is data, never derived from a title at render time), and `reference()` for relations.

Astro-first composition: `.astro` components are the default. React exists only under `src/components/islands/`, and each island says in its own header comment or the PR that adds it why the interaction cannot be Astro plus a small script. `client:only` requires a registered exception in the [profile register](../../profiles/astro.md#exception-register).

Static assets that ship as-is live in `public/`. Root config filenames are fixed: `astro.config.*`, `tsconfig.json`, `eslint.config.mjs`, `prettier.config.mjs`.

## Reason

The survey found the same tree under drifted names. One layout makes components, audits, and agents portable across sites; splitting `lib/` into `client`/`server`/`seo` keeps server-only code out of bundles by construction; and Astro-first keeps hydration (and its cost) opt-in.

## Static behavior

The tree above is the whole story.

## Server delta

Server repos add `src/middleware.*` when middleware is needed. Everything else is identical.

## CI proof

`typecheck` (`astro check`) and `lint` cover the tree, including typed TSX for islands. `fixtures/astro-static` and `fixtures/astro-server` carry the canonical `src/pages/` shape.

## Exceptions

Tree deviations, `client:only` usage, and any React outside `src/components/islands/` need a register entry in the [profile register](../../profiles/astro.md#exception-register): decision, exception, reason, compensating control, owner, approval and review dates, exit condition.

## Migration notes

Moves are mechanical: relocate directories, fix imports, and convert legacy `src/content/config.ts` definitions to the loader API in `src/content.config.ts` in the same PR. Slugs moved to explicit stable values must keep the live URLs (audit the redirect matrix from [001](001-url-policy.md) when a slug changes). Do not mix a layout move with behavior changes.
