# Class inventory

Authoritative Robben Media class inventory and migration status. Callers do not keep their own copy.

Status lives here. Surgeon does not invent a parallel list.

First observed 2026-08-28; re-checked 2026-08-30 via `gh api` as `itsjeremyjohnson`. No clones. Default-branch contents only, except open caller PRs named below.

## Status values

| Status | Meaning |
| --- | --- |
| `not-started` | In catalog. No caller yet. Not the current representative. |
| `held` | Named representative, or otherwise blocked. Do not migrate. |
| `caller-open` | A caller PR exists on the repo. Do not merge it from this work. |
| `pinned` | Default branch calls `Robben-Media/engineering-standards/.github/workflows/<class>.yml@v1`. |

`held` wins over `not-started` when the adoption gate is closed. The gate is in [migration.md](migration.md).

## Org-wide facts (re-checked)

- `Robben-Media` has **70** repos (`gh api --paginate orgs/Robben-Media/repos`).
- `refs/tags/v1` points at `472bfa146993442c7ab32fe3920622a030905bec` (the `#1` merge on `main`). No GitHub Releases.
- **0** default branches pin `@v1`. Evidence: `gh search code "engineering-standards/.github/workflows" --owner Robben-Media` returns only this repo's README; a default-branch workflow scan found no `Robben-Media/engineering-standards` reference. The three caller PRs below pin `@v1` on their branches, but none is merged, so no default branch pins it.
- **3** CI-only caller PRs are open (Repo Surgeon; Nash told Surgeon to hold further callers). Known check state from the 2026-08-30 refresh — none of these is an authoritative successful representative run, and the adoption gates stay closed:
  - [police-scanner-feed#58](https://github.com/Robben-Media/police-scanner-feed/pull/58) — `node-bun.yml@v1`, state `open`, `merged=false`. Checks **fail**.
  - [robbenmedia-site#135](https://github.com/Robben-Media/robbenmedia-site/pull/135) — `node-bun.yml@v1`, state `open`, `merged=false`. Checks **fail**.
  - [cmart10#123](https://github.com/Robben-Media/cmart10/pull/123) — `node-bun.yml@v1`, state `open`, `merged=false`. Checks **passed**, but against the old `v1` (`472bfa1`), not the current workflows.
- Fixture CI is on `main` (merged via [engineering-standards#8](https://github.com/Robben-Media/engineering-standards/pull/8)). The moving `v1` tag still points at `472bfa146993442c7ab32fe3920622a030905bec`. The adoption gate is **not** cleared: nothing pins `@v1` on a default branch and no caller has an authoritative `@v1` run.
- No authoritative representative `@v1` success is claimed. The check states above are the record: `#58` and `#135` fail; `#123` passed against the old `v1`, before the current workflows.

Default branches of the three caller repos still have copied or missing class CI:

| Repo | Default workflows | Class CI on default |
| --- | --- | --- |
| `police-scanner-feed` | `ci.yml`, `claude.yml` | Echo-stub `ci.yml` (blob `ce28fe421f5f752e96f445cab801be73a1b5d7f1`) |
| `robbenmedia-site` | `claude.yml`, `deploy.yml`, `fetch-data.yml` | None |
| `cmart10` | `claude.yml`, `dependabot-auto-merge.yml`, `deploy.yml` | None |

## Intended representatives (held)

Migrate **one** representative per supported class only after Fixture CI on `main` is green and Nash/Jeremy review. This change names them and records equivalence. It does **not** open caller PRs.

| Class | Intended representative | Status | Why this one |
| --- | --- | --- | --- |
| Go CLI | [`itsjeremyjohnson/wpssh`](https://github.com/itsjeremyjohnson/wpssh) | `held` | Charlie's cited example. Public. Copied `ci.yml` + Makefile. Personal, not RM. |
| Live Node | [`Robben-Media/police-scanner-feed`](https://github.com/Robben-Media/police-scanner-feed) | `held` | RM live Node (`package.json` + `bun.lock`). Echo-stub CI. Surgeon PR `#58` is `caller-open` and must stay unmerged. |
| Python tool | [`itsjeremyjohnson/fleet`](https://github.com/itsjeremyjohnson/fleet) | `held` | Visible Python tool: `requirements.txt` + `tests/`. No `.github` on default. Personal. |
| Docs-only | [`Robben-Media/youtube-channel-planning`](https://github.com/Robben-Media/youtube-channel-planning) | `held` | RM docs tree. No app manifest. Echo-stub `ci.yml`. No caller; stub is not replaced. |

Equivalence records: [equivalence/](equivalence/).

RM alternatives that are **not** the representative:

- Go: public RM CLIs such as `clickup-cli` (`go.mod` + `cmd/` re-checked). Status `not-started`.
- Node: `robbenmedia-site` and `cmart10` are `caller-open`, not the representative.
- Python: `domain-info-fetcher` is the only RM repo observed with `requirements.txt` or `pyproject.toml` plus a runnable module. Status `not-started` (echo-stub CI).
- `hermes` and `robben-triage` are listed in [classes.md](classes.md) as Python examples. Default-branch roots have **no** `pyproject.toml` or `requirements.txt`. Not classified as `python-tool` here.

## Exception register

Extra jobs stay in the caller. Nash or Jeremy approve. Record them here.

| Repo | Extra job | Approval | Status |
| --- | --- | --- | --- |
| `itsjeremyjohnson/meal-planning` | `release-qc` in `.github/workflows/ci.yml` (Bun web install, `requirements-test.txt`, Playwright Chromium, `bun run qc:release`, artifact `artifacts/qc/`) | Intended. [classes.md](classes.md) already says keep the extra QC job. Formal Nash/Jeremy sign-off still required before a caller lands. | `held` |
| `itsjeremyjohnson/wpssh` | `make lint` (golangci-lint via Makefile) is not in `go-cli.yml` | Proposed caller-specific extra job. Not approved yet. | `held` |

No approved exception has been used to delete copied CI.

## Astro profile exceptions

Astro repos keep the Live Node class. Profile decision exceptions — URL policy, SEO, scripts, source layout, environment, headers, deployment — are registered once, in [profiles/astro.md](profiles/astro.md#exception-register). Site-local entries link there. The caller-extra-job table above stays separate and keeps recording extra CI jobs, not profile deviations.

## Robben-Media by class

Classify by default-branch markers, not the language badge. See [classes.md](classes.md).

### Go CLI

Detect: `go.mod` and a `cmd/` tree (or `package main` at repo root).

| Repo | Visibility | Current CI | Status |
| --- | --- | --- | --- |
| `apple-reminders-cli` | public | local `ci.yml` | `not-started` |
| `brightlocal-cli` | public | local `ci.yml` | `not-started` |
| `clickup-cli` | public | local `ci.yml` | `not-started` |
| `dataforseo-cli` | public | local `ci.yml` | `not-started` |
| `docusign-cli` | public | local `ci.yml` | `not-started` |
| `exa-cli` | public | local `ci.yml` | `not-started` |
| `jobtread-cli` | public | local `ci.yml` | `not-started` |
| `n8n-cli` | public | local `ci.yml` | `not-started` |
| `namecheap-cli` | public | local `ci.yml` | `not-started` |
| `notion-cli` | private | no workflows | `not-started` |
| `openclaw-alt` | private | local `ci.yml` | `not-started` |
| `posthog-cli` | public | local `ci.yml` | `not-started` |
| `postiz-cli` | public | local `ci.yml` | `not-started` |
| `quickbooks-cli` | public | local `ci.yml` | `not-started` |
| `rm-agreements` | private | no class CI (root `package main`, no `cmd/`) | `not-started` |
| `surfer-cli` | public | local `ci.yml` | `not-started` |
| `trello-cli` | public | local `ci.yml` | `not-started` |
| `unifi-cli` | public | local `ci.yml` | `not-started` |
| `uptime-kuma-cli` | public | local `ci.yml` | `not-started` |

`gogcli` is a fork of `openclaw/gogcli`. Out of catalog.

### Live Node

Detect: `package.json` plus a lockfile.

| Repo | Current CI | Status |
| --- | --- | --- |
| `police-scanner-feed` | echo-stub `ci.yml` | `held` (representative). Surgeon PR `#58` is also `caller-open`. |
| `robbenmedia-site` | deploy/fetch-data only | `caller-open` (`#135`) |
| `cmart10` | deploy/dependabot only | `caller-open` (`#123`) |
| `create-astro-site` | local `ci.yml` | `not-started` |
| `csi-omaha` | no workflows | `not-started` |
| `documenso-rm` | local CI suite | `not-started` |
| `erintuckercoaching` | local deploy | `not-started` |
| `growflow` | local `ci.yml` | `not-started` |
| `jeremyhasnoplan.com` | local deploy | `not-started` |
| `jobtread-automation` | local `ci.yml` | `not-started` |
| `llm-testing` | echo-stub | `not-started` |
| `MBR` | no workflows | `not-started` |
| `monthly-reporting` | local deploy/refresh | `not-started` |
| `rm-astro-seo` | no workflows | `not-started` |
| `watson-wdl-homepage-spacing` | local `ci.yml` | `not-started` |
| `website-build-boone-homes` | local deploy | `not-started` |
| `website-build-dentistwebbooster` | local deploy | `not-started` |
| `website-build-greenieco` | local deploy | `not-started` |
| `website-build-midwest-custom-trucks` | local deploy | `not-started` |
| `website-build-northern-sun` | local deploy | `not-started` |
| `website-build-quirky-compass-travel-co` | local deploy | `not-started` |
| `website-build-terr-homes` | local deploy | `not-started` |

`not-started` Node repos stay that way until the representative has a successful `@v1` run. Do not open more caller PRs.

### Python tool

Detect: `requirements.txt` or `pyproject.toml`, plus tests or a runnable module.

| Repo | Current CI | Status |
| --- | --- | --- |
| `domain-info-fetcher` | echo-stub `ci.yml`; `requirements.txt` + `domain_info_fetcher.py` | `not-started` |

No other RM repo was observed with a root Python manifest.

### Docs-only

No caller by default. Echo-stub CI is removed, not replaced, and only after the gate in [migration.md](migration.md). Optional `docs-only.yml@v1` is a class-drift check.

| Repo | Current CI | Status |
| --- | --- | --- |
| `youtube-channel-planning` | echo-stub `ci.yml` + `claude.yml` | `held` (representative) |
| `write-a-book` | echo-stub `ci.yml`; root is markdown/hooks | `not-started` |
| `youtube-content` | echo-stub (same-day default-branch scan) | `not-started` |

### Hold (unclear or not ready)

Not a class assignment. Do not pin.

| Repo | Why |
| --- | --- |
| `AI-Physical-Business` | Default branch `init`. `package.json` without a lockfile. Echo-stub CI. |
| `torch` | Default branch `feat/torch-mvp` (drift). `package.json` + `bun.lock`. No workflows. |
| `directories` | No root `package.json`. Nested app tree. |
| `reddit-seo` | Root `.ts` files. No `package.json` or lockfile. Echo-stub CI. |
| `our_clients` | Python scripts + tests. No `requirements.txt` or `pyproject.toml`. |
| `bni-contact-spheres` | Scripts + `test/`. No package/Python manifest. |

### Out of catalog

Leave alone unless GitHub Manager assigns a one-off.

| Repo | Why |
| --- | --- |
| `engineering-standards` | This catalog. |
| `.github` | Org community-health fallbacks. |
| `gogcli` | Fork (`openclaw/gogcli`). |
| `codex` | Fork (Rust; `Cargo.toml` is an out-of-catalog docs-only marker). |
| `docuseal` | Fork (Ruby). |
| `phonetermbridge` | Fork. |
| `demo-repository` | GitHub demo. `package.json` without a lockfile. |
| `website-build-therapistwebbooster` | Empty / no default-branch app tree. |
| `erin-tucker-coaching` | Empty twin / submodule wrapper. |
| `BNI_Ops` | Agent/ops tree. No catalog manifest. |
| `foo-pa-podcast` | Agent workspace. Default `agent/mac-jeremydjohnson/initial-setup`. |
| `microsoft-partner` | Agent workspace. Default `agent/local/microsoft-partner-research`. |
| `advanced-history-revisions-wp` | WordPress/PHP. Default `master`. |
| `dm-idx-custom-ui` | WordPress/PHP plugin. Root `composer.json` (out-of-catalog marker) plus Node lockfiles. |
| `rm-agency-core` | WordPress/PHP. |
| `rm-schema-delivery` | WordPress/PHP. Default `agent/macbook/initial-plugin`. |
| `update-functions-php` | WordPress/PHP. |
| `website-build-nds` | WordPress/PHP. |
| `como-exteriors` | WordPress/ALB content tree. |

## Personal examples (not RM)

These are `itsjeremyjohnson` repos named by [classes.md](classes.md) or Charlie. They are not RM inventory rows. Visibility was confirmed with `gh api repos/itsjeremyjohnson/<name>`.

| Repo | Role | Observed default-branch markers | Status |
| --- | --- | --- | --- |
| `wpssh` | Go representative | `go.mod`, `cmd/`, Makefile, copied `ci.yml` (not a reusable caller) | `held` |
| `cli-template` | Go example | Public Go template. Not compared in this change. | `held` |
| `meal-planning` | Live Node + extra QC | `package.json`, `bun.lock`, `requirements.txt`, `requirements-test.txt`, `ci.yml` job `release-qc` | `held` |
| `insurance`, `program-moms-scanner`, `appraisals`, `DOAR` | Live Node examples | Existence confirmed. Not re-read for checks. | `held` |
| `finance` | Live Node scaffold | Existence confirmed. Catalog says hold the caller until there is source. | `held` |
| `fleet` | Python representative | `requirements.txt`, `tests/`, no `.github` | `held` |
| `hermes` | Listed Python example | No root `pyproject.toml` or `requirements.txt`. `.github/BOOTSTRAP` only. | unclassified |
| `robben-triage` | Listed Python example | `src/robben_triage`, `tests/`. No root Python manifest. No `.github`. | unclassified |
| `loan-negotiations`, `appraisal-training`, `johnson-family-insurance`, `vicki-adams-career`, `gstack-artifacts-jeremydjohnson` | Docs-only examples | Existence confirmed. Not the RM representative. | `held` |

`itsjeremyjohnson/homebrew-tap` and `openclaw` stay out of catalog.

## How to update this file

1. Re-read default-branch contents with `gh api`. Do not invent markers.
2. Change status only for a fact you can point at (merged pin, open PR, written hold).
3. Add exception rows when Nash or Jeremy approve an extra job.
4. Do not copy this table into a caller repo.
