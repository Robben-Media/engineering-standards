# Astro server profile fixture

Proves the server profile through `node-bun.yml`: `output: "server"`, the
`@astrojs/node` adapter in `standalone` mode with the Node standalone start entry
(`dist/server/entry.mjs`), and the toolchain pins from the environment contract.
The test imports `astro.config.mjs` against local no-registry stubs of `astro/config`
and the Node adapter and asserts the actual exported values — no Astro or Playwright
packages come from the registry.

This fixture is explicitly exempt from the full script vocabulary under the
[003](../../docs/decisions/astro/003-script-contract.md) fixture carveout: its `test`
and `ci` scripts run this probe only. It proves profile detection plus Bun/Node workflow
plumbing, not framework installation, and it is a profile, not a class.
See [docs/profiles/astro.md](../../docs/profiles/astro.md).
