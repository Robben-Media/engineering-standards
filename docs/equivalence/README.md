# Equivalence records

One short record per intended representative. Compare the repo's existing checks to the shared workflow **before** migrating.

Representatives are `held`. Fixture CI is on `main` (merged via `#8`); the adoption gates stay closed until an authoritative `@v1` run succeeds. Do not open caller PRs from this work.

| Class | Record | Repo | Status |
| --- | --- | --- | --- |
| Go CLI | [go-cli-wpssh.md](go-cli-wpssh.md) | `itsjeremyjohnson/wpssh` | `held` |
| Live Node | [node-bun-police-scanner-feed.md](node-bun-police-scanner-feed.md) | `Robben-Media/police-scanner-feed` | `held` |
| Python tool | [python-tool-fleet.md](python-tool-fleet.md) | `itsjeremyjohnson/fleet` | `held` |
| Docs-only | [docs-only-youtube-channel-planning.md](docs-only-youtube-channel-planning.md) | `Robben-Media/youtube-channel-planning` | `held` |

Shared workflows were compared at `@v1` `472bfa146993442c7ab32fe3920622a030905bec` (`go-cli.yml`, `node-bun.yml`, `python-tool.yml`, `docs-only.yml`). `main` has since moved — it is `209db5efe3febc19ff074cf9ceadb41cc142336a` (Fixture CI merged) — while the moving `v1` tag still points at `472bfa1`. Re-compare against current `main` before migrating a representative.
