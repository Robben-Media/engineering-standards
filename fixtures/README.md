# Fixtures

Maintained, cheap integration apps for Fixture CI (`.github/workflows/fixture-ci.yml`).
Every reusable workflow branch must stay green here before `v1` moves. See [docs/release.md](../docs/release.md).

Each subdirectory is one class or package-manager branch. Keep them tiny.
When you change a reusable workflow, update the matching fixture so that branch still runs.
