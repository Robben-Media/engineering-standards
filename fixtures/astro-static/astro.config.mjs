// @ts-check
import { defineConfig } from "astro/config";

// Static profile fixture. Values must match docs/decisions/astro/001-url-policy.md
// and docs/profiles/astro.md. No real or registry-hosted Astro packages are used;
// the local file stub of astro/config is what gets installed.
export default defineConfig({
  site: "https://astro-static.fixture.invalid",
  output: "static",
  trailingSlash: "always",
  build: {
    format: "directory",
  },
});
