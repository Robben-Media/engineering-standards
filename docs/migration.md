# Migration gates

How a repo moves from copied CI to `Robben-Media/engineering-standards/.github/workflows/<class>.yml@v1`.

Inventory and status live in [inventory.md](inventory.md). Equivalence records live in [equivalence/](equivalence/). Callers do not keep a second copy of either.

## Gate (in order)

1. **Fixtures green.** Shared workflows must pass the executable fixtures. Fixture CI is on `main` (merged via [engineering-standards#8](https://github.com/Robben-Media/engineering-standards/pull/8)). This gate clears only with an observed green Fixture CI run on the release SHA; none is claimed here.
2. **Equivalence recorded.** Before migrating a representative, compare its existing checks to the shared workflow. Record retained, added, intentionally omitted, and caller-specific checks under [equivalence/](equivalence/).
3. **One representative per class.** Migrate only the named representative in [inventory.md](inventory.md) first. Current names and status `held`:
   - Go CLI: `itsjeremyjohnson/wpssh`
   - Live Node: `Robben-Media/police-scanner-feed`
   - Python tool: `itsjeremyjohnson/fleet`
   - Docs-only: `Robben-Media/youtube-channel-planning` (no caller by default)
4. **Review.** Nash or Jeremy review the equivalence record and the caller PR.
5. **Authoritative `@v1` run.** The caller PR must get a successful run against `.../<class>.yml@v1` (the moving tag, today `472bfa146993442c7ab32fe3920622a030905bec`). Do not claim a run you have not opened in the Actions UI or API.
6. **Then delete copied CI.** Do not remove the copied workflow until step 5 succeeds. Docs-only echo-stubs are removed, not replaced; still wait for step 5 if the optional `docs-only.yml@v1` caller is the replacement, or for an explicit Nash/Jeremy note that "no caller" is the replacement.

Repo Surgeon owns caller repos. GitHub Standards does not open PRs on `wpssh`, `meal-planning`, `fleet`, `police-scanner-feed`, or other callers from this issue.

## What "held" means right now

- Fixture CI is on `main`, but `v1` still points at `472bfa1` and no authoritative `@v1` run exists. Adoption gates stay closed until that run.
- Nash told Surgeon to hold further callers.
- Three Surgeon caller PRs are already open (`police-scanner-feed#58`, `robbenmedia-site#135`, `cmart10#123`). They stay open. Do not merge them from this work. Do not treat them as a successful `@v1` pin.

Wave the rest of a class only after that class's representative is `pinned` in [inventory.md](inventory.md).

## Pointer declarations are not callers

A pointer-only `STANDARDS.md` declaration PR (adding `Profile` / `Adoption` / `Workflow` per [profiles/astro.md](profiles/astro.md)) is not a reusable-workflow caller PR and is not blocked by the current hold. It does not delete copied CI, does not alter a caller, and does not change the gates above. It also must not claim that the default branch pins `@v1`: only the released caller on the default branch makes `Workflow` `node-bun.yml@v1`.

## Exceptions and extra jobs

The class workflow is the minimum. Extra jobs stay **in the caller repo**.

Examples already named in the catalog:

- `meal-planning` release QC (`release-qc` job: Bun, Python test deps, Playwright, `bun run qc:release`)
- `DOAR` `working-directory` when `package.json` is not at the root
- `wpssh` `make lint` (golangci-lint) if Nash/Jeremy want it kept

Process:

1. Record the extra job in the equivalence file (caller-specific).
2. Nash or Jeremy approve. GitHub Standards does not self-approve.
3. Add a row to the exception register in [inventory.md](inventory.md): repo, job, who approved, date.
4. Land the extra job in the caller's `ci.yml` **next to** `uses: .../<class>.yml@v1`. Do not fork the reusable workflow.
5. Keep the extra job when the copied class CI is later deleted.

Unapproved extras do not block recording. They do block deleting the copied workflow.

## Pin and rollback

Pin `@v1`, not `@main`. Jeremy moves `v1`. Rollback is retag; the procedure is in [release.md](release.md). `v1` is still `472bfa1`.

## Docs-only

Docs-only repos do not need a caller. `docs-only.yml` fails when a supported or out-of-catalog app marker appears. The failure names the file and the class or `out of catalog`. See [classes.md](classes.md).
