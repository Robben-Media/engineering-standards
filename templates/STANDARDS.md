# Standards

Class: CLASS

Profile: none

Adoption: declared

Workflow: local

Canon: https://github.com/Robben-Media/engineering-standards

Do not copy workflows or class rules into this repo. This file does not configure CI. A pinned caller makes CI call `Robben-Media/engineering-standards/.github/workflows/CLASS.yml@v1`. Until this repo pins one, `Workflow` stays `local`. If a review conflicts with the canon, the canon wins. Change it there, not here.

`Adoption: declared` names this repo's catalog target — the class, or the class plus its profile — and does not claim conformance. Adoption values are defined in `docs/classes.md` in the canon. `Workflow: local` means the default branch is not verified as pinned. Profile conformance, workflow migration, and approved exceptions are tracked in the canon, not here.

`Profile` is `astro` for Astro repos and `none` otherwise. The profile never changes the class: Astro repos keep the `node-bun` class and, when pinned, the `node-bun.yml@v1` caller. Astro profile rules live in `docs/profiles/astro.md` in the canon.
