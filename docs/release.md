# Release process

This repository is the CI control plane. Callers pin reusable workflows at `@v1`.
They do not pin a commit SHA of this repo.

```yaml
jobs:
  ci:
    uses: Robben-Media/engineering-standards/.github/workflows/<class>.yml@v1
```

`<class>` is `go-cli`, `node-bun`, `python-tool`, or `docs-only`.

## Ownership

| Role | Who |
| --- | --- |
| Drafts | GitHub Standards |
| Review gate | Nash and Jeremy. At least one approval before `v1` moves. |
| Tag owner | Jeremy (`itsjeremyjohnson`) creates and moves `v1`. |

`.github/CODEOWNERS` routes workflow and release-doc reviews to Jeremy. Nash is a named reviewer; no GitHub login for Nash is recorded in this org membership list (`chelsea-arch`, `itsjeremyjohnson`, `larabooo` as of 2026-08-28 via `GET /orgs/Robben-Media/members`).

## Before a release

1. Fixture CI on the release SHA is green. That workflow calls every reusable workflow against `fixtures/`.
2. `lint-workflows` is green (PyYAML parse of `.github/workflows/*` plus actionlint).
3. Nash or Jeremy reviews the pull request. Do not move `v1` from an unreviewed SHA.
4. Record the move in `docs/releases/` (copy the previous tag SHA for rollback).

## How `v1` is moved

`v1` is a moving major tag. After review, Jeremy updates the `v1` tag to the reviewed SHA and pushes that tag (annotated preferred). Do not rewrite `main` history. Do not delete `v1` unless you immediately point it at a known-good SHA.

Callers keep `@v1`. They pick up the new workflows on the next run after the tag moves.

## Rollback

Point `v1` at the previous SHA and push the tag. The previous SHA is the commit recorded in the last `docs/releases/` note (for the initial rollout, `472bfa146993442c7ab32fe3920622a030905bec`). Callers stay on `@v1` and receive the prior workflows automatically.

If a caller is broken and cannot wait, they may temporarily pin a commit SHA of this repo, then return to `@v1` after rollback.

## Action-reference policy

Two layers:

1. **Callers of this repo** pin `@v1`. That tag moves only after the review gate above. This is a deliberately reviewed tag channel. Tradeoff: `v1` is mutable, so a bad move can reach every caller until rollback. Mitigation: Fixture CI + review + recorded previous SHA.
2. **Third-party actions inside this repo** pin a full 40-character commit SHA, with the human tag in a trailing comment, per [GitHub secure-use](https://docs.github.com/en/actions/reference/security/secure-use).

   Example: `uses: actions/checkout@11d5960a326750d5838078e36cf38b85af677262 # v4.4.0`

SHAs below were resolved with the GitHub API on 2026-08-28 (commit objects, not annotated-tag objects).

| Action | Tag | Commit SHA | How resolved |
| --- | --- | --- | --- |
| `actions/checkout` | v4.4.0 (also current `v4`) | `11d5960a326750d5838078e36cf38b85af677262` | `GET /repos/actions/checkout/commits/v4.4.0` |
| `actions/setup-node` | v4.4.0 (also current `v4`) | `49933ea5288caeca8642d1e84afbd3f7d6820020` | `GET /repos/actions/setup-node/commits/v4.4.0` |
| `actions/setup-go` | v5.6.0 (also current `v5`) | `40f1582b2485089dde7abd97c1529aa768e1baff` | `GET /repos/actions/setup-go/commits/v5.6.0` |
| `actions/setup-python` | v5.6.0 (also current `v5`) | `a26af69be951a213d495a4c3e4e4022e16d87065` | `GET /repos/actions/setup-python/commits/v5.6.0` |
| `oven-sh/setup-bun` | v2.2.0 (also current `v2`) | `0c5077e51419868618aeaa5fe8019c62421857d6` | `GET /repos/oven-sh/setup-bun/commits/v2.2.0` |
| `pnpm/action-setup` | floating `v4` | `b906affcce14559ad1aafd4ab0e942779e9f58b1` | `GET /repos/pnpm/action-setup/commits/v4` (peeled commit; `v4` is an annotated tag). Version tag `v4.4.0` is a newer commit (`fc06bc1257f339d1d5d8b3a19a8cae5388b55320`) that runs on Node 24; the floating `v4` tag was moved back to the Node 20 revert. This pin follows the floating `v4` the workflows already used. |

Majors were not upgraded (several of these actions have later latest releases). Pinning current majors avoids an unreviewed behavior change.

## Repository protections

Observed 2026-08-28 with `gh` as `itsjeremyjohnson` (token scopes: `gist`, `read:org`, `repo`, `workflow`):

| Check | Result |
| --- | --- |
| `GET /repos/Robben-Media/engineering-standards/rulesets` | `[]` (no repo rulesets) |
| `GET /repos/Robben-Media/engineering-standards/branches/main/protection` | `404 Branch not protected` |
| `GET /orgs/Robben-Media/rulesets` | `404` — this token lacks `admin:org` |

Org rulesets were **not** created or verified. Do not assume they exist.

### Intended settings (not claimed as configured)

Repo ruleset targeting `refs/heads/main`, enforcement `active`:

- Block history rewrites and branch deletion
- Require a pull request with 1 approving review (Nash or Jeremy)
- Dismiss stale reviews on new pushes
- After Fixture CI has been observed green on this repo, require the status checks GitHub actually reports for that workflow (reusable calls typically appear as `<job> / ci`). Expected job ids: `lint-workflows`, `go-cli`, `python-tool`, `docs-only`, plus one job per Node package-manager fixture and the subdirectory fixture.

Tag ruleset targeting `refs/tags/v1`:

- Only Jeremy (`itsjeremyjohnson`) may create or update the tag
- No deletion of `v1` except as part of an immediate retag

This token can create repo rulesets (admin on the repository) but cannot manage org rulesets. Repo rulesets were left uncreated so in-flight PRs #6 and #7 are not surprised by a new blocking gate. Enable the intended rulesets after this PR is reviewed.

## Fixture strategy

`.github/workflows/fixture-ci.yml` is the in-repo caller. It runs on pull requests and on `main`. It is the evidence that each reusable workflow branch executes before a release. See [fixtures/README.md](../fixtures/README.md).

`go-cli.yml`, `python-tool.yml`, and `docs-only.yml` accept `working-directory` (default `.`) so fixtures can live beside each other. `node-bun.yml` already had that input. Existing callers that omit it keep root-of-repo behavior.
