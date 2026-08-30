# Fixtures

Maintained, cheap integration apps for Fixture CI (`.github/workflows/fixture-ci.yml`).
Every reusable workflow branch must stay green here before `v1` moves. See [docs/release.md](../docs/release.md).

Each subdirectory is one class, package-manager branch, or profile. Keep them tiny.
When you change a reusable workflow, update the matching fixture so that branch still runs.

Profile fixtures (`astro-static`, `astro-server`) are **not classes**. Astro is a
[profile](../docs/profiles/astro.md) of the Live Node class; both fixtures call
`node-bun.yml`. They prove profile detection and the Bun/Node workflow path, not framework
installation: they pull no Astro or Playwright packages from the registry. Their reduced
`test`/`ci` scripts are explicitly exempt from the profile's full script vocabulary under
the [fixture carveout](../docs/decisions/astro/003-script-contract.md) — no caller site may
copy that shape.
