// Local stub. Returns the descriptor the fixture test asserts on: the adapter name,
// the requested mode, and the standalone start entry from docs/decisions/astro/009-deployment.md.
// The real @astrojs/node returns a hook-based adapter; the fixture only needs the
// testable descriptor.
function node(options = {}) {
  return {
    name: "@astrojs/node",
    mode: options.mode,
    entry: "./dist/server/entry.mjs",
  };
}

export default node;
