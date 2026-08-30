# 002 — Lint and format

Status: approved 2026-08-29. Part of the [Astro profile](../../profiles/astro.md).

## Decision

- ESLint 10 with flat config. The config file is exactly `eslint.config.mjs` at the repo root; no legacy `.eslintrc*`, no other config filename.
- Prettier 3 with `prettier-plugin-astro` for `.astro` formatting. The config file is exactly `prettier.config.mjs` at the repo root. Prettier owns formatting; ESLint owns correctness and accessibility. Formatting rules stay off in ESLint so the two never fight.
- TypeScript extends `astro/tsconfigs/strictest`.
- Typed linting: `typescript-eslint` with type-checked parsing over `*.ts`, `*.tsx`, `*.mts`, and `*.cts`. TSX is always in the parse set so a later React island cannot land untyped.
- `eslint-plugin-astro` with its accessibility rules enabled for `.astro` files.
- The `lint` script is exactly `eslint . --max-warnings 0`; `lint:fix` is the same with `--fix`. Warnings are failures.
- React/Hooks rules (`eslint-plugin-react-hooks`, React-specific plugin config) are added only in repos that actually have React islands.
- `prettier-plugin-tailwindcss` is the **last** entry in the Prettier `plugins` array, configured with `tailwindStylesheet: "./src/styles/global.css"` and `tailwindFunctions` (baseline `["clsx", "cn"]`, extended where a site uses more class-name helpers).
- No Biome. Biome is not part of the baseline; adopting it is a change to this record, not a per-site choice.

## Reason

The estate already uses these tools but versions, plugin sets, and strictness drifted. Astro-specific accessibility defects are exactly what `eslint-plugin-astro` exists for, `astro/tsconfigs/strictest` flags the undefined-index and optional-property bugs the survey kept finding, and `--max-warnings 0` keeps warning creep from becoming a permanent shadow failure state.

## Static behavior

One flat config at the repo root covers `src/`, config files, and endpoints. No per-mode variation.

## Server delta

Same config. Server endpoints and middleware add Node globals/scopes where those files need them.

## CI proof

`format:check` then `lint` (which is `eslint . --max-warnings 0`) run in the fixed CI order ([007](007-ci-order.md)), before `typecheck`. The scripts are part of the fixed vocabulary ([003](003-script-contract.md)).

## Exceptions

Inline `eslint-disable` comments must carry a reason. Long-lived disables (whole rules, whole files), a relaxed `astro/tsconfigs/strictest` option, `unsafe` CSP-adjacent syntax, or a different config filename need a register entry in the [profile register](../../profiles/astro.md#exception-register): decision, exception, reason, compensating control, owner, approval and review dates, exit condition.

## Migration notes

Flat config only — remove `.eslintrc*`. Convert formatting duties from ESLint to Prettier in the same PR that adds the plugins, so lint and format agree before the `ci` script goes live. Sites moving to typed linting may need incremental `projectService` includes; strictness itself is not negotiable.
