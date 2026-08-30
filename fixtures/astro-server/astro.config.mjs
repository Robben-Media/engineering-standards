// @ts-check
import { defineConfig } from "astro/config";
import node from "@astrojs/node";

// Server profile fixture. Values must match docs/decisions/astro/001-url-policy.md,
// docs/decisions/astro/009-deployment.md, and docs/profiles/astro.md. No real or
// registry-hosted Astro packages are used; local file stubs of astro/config and
// @astrojs/node are what get installed.
export default defineConfig({
  site: "https://astro-server.fixture.invalid",
  output: "server",
  trailingSlash: "always",
  build: {
    format: "directory",
  },
  adapter: node({
    mode: "standalone",
  }),
});
