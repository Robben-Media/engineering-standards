# Astro static profile fixture

Proves the static profile through `node-bun.yml`: `output: "static"`, no adapter,
directory URLs with trailing slashes, and the toolchain pins from the environment
contract. The test imports `astro.config.mjs` against a local no-registry stub of
`astro/config` and asserts the actual exported values — no Astro packages come from
the registry.

This fixture is explicitly exempt from the full script vocabulary under the
[003](../../docs/decisions/astro/003-script-contract.md) fixture carveout: its `test`
and `ci` scripts run this probe only. It proves profile detection plus Bun/Node workflow
plumbing, not framework installation, and it is a profile, not a class.
See [docs/profiles/astro.md](../../docs/profiles/astro.md).
