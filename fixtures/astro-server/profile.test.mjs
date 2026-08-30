import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import config from "./astro.config.mjs";

const pkg = JSON.parse(
  await readFile(new URL("./package.json", import.meta.url), "utf8")
);

test("server output mode", () => {
  assert.equal(config.output, "server");
});

test("Node standalone adapter with the start entry", () => {
  assert.equal(config.adapter?.name, "@astrojs/node");
  assert.equal(config.adapter?.mode, "standalone");
  assert.equal(config.adapter?.entry, "./dist/server/entry.mjs");
});

test("directory URLs with trailing slashes", () => {
  assert.equal(config.trailingSlash, "always");
  assert.equal(config.build?.format, "directory");
});

test("Astro.site uses HTTPS", () => {
  assert.equal(new URL(config.site).protocol, "https:");
});

test("toolchain pins from the environment contract", async () => {
  assert.equal(pkg.packageManager, "bun@1.4.0");
  assert.equal(pkg.engines?.node, ">=22.23.2 <23");
  const nodeVersion = (
    await readFile(new URL("./.node-version", import.meta.url), "utf8")
  ).trim();
  assert.equal(nodeVersion, "22.23.2");
});

test("uses local Astro stub dependencies", () => {
  assert.match(pkg.dependencies?.astro ?? "", /^file:/);
  assert.match(pkg.dependencies?.["@astrojs/node"] ?? "", /^file:/);
});

test("reduced probe scripts under the 003 fixture carveout", () => {
  assert.equal(pkg.scripts.test, "node --test");
  assert.equal(pkg.scripts.ci, "node --test");
});

test("astro source present with real markup", async () => {
  const page = await readFile(
    new URL("./src/pages/index.astro", import.meta.url),
    "utf8"
  );
  assert.ok(page.includes("<html"), "index.astro must contain real markup");
});
