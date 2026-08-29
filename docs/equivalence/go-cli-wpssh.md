# Go CLI — `itsjeremyjohnson/wpssh`

Status: `held`. Personal public repo. Charlie's cited example in `#5`.

Compared 2026-08-28 via `gh api` (no clone):

- `itsjeremyjohnson/wpssh/.github/workflows/ci.yml`
- `itsjeremyjohnson/wpssh/Makefile`
- `itsjeremyjohnson/wpssh/go.mod` (`go 1.25.1`, module `github.com/builtbyrobben/wpssh`)
- `itsjeremyjohnson/wpssh` root: `cmd/`, `.golangci.yml`, `.goreleaser.yaml`
- Shared: `Robben-Media/engineering-standards/.github/workflows/go-cli.yml@472bfa1`

No `engineering-standards` caller in `ci.yml`. Steps use `actions/checkout@v4` and `actions/setup-go@v5` only.

## Existing checks (copied CI)

`ci.yml` job `build` on `ubuntu-latest`:

1. `actions/setup-go@v5` with `go-version: '1.25.1'`
2. `go mod download`
3. `make fmt-check`
4. `make lint`
5. `make test`

Makefile targets (read in full):

- `fmt-check`: `goimports` + `gofumpt` after `make tools`
- `lint`: `golangci-lint run` after `make tools`
- `test`: `go test -race -count=1 ./internal/...`

## Shared `go-cli.yml` checks

- Require `go.mod`
- `setup-go` default `1.25.1`, `go mod download`
- Format: `make fmt-check` when that target exists, else `gofmt -l .`
- `go vet ./...`
- Test: `make test` when that target exists, else `go test ./...`

## Comparison

| Check | Verdict | Notes |
| --- | --- | --- |
| `setup-go` 1.25.1 | retained | Same version as the shared default. |
| `go mod download` | retained | Shared step. |
| `make fmt-check` | retained | Shared workflow prefers this Makefile target. Keeps goimports/gofumpt, not raw `gofmt`. |
| `make test` | retained | Shared workflow prefers this target. Keeps `-race` and `./internal/...`. |
| `go vet ./...` | added | Not a standalone step in wpssh `ci.yml`. `golangci.yml` enables `govet`. |
| `make lint` / golangci-lint | caller-specific | Not in `go-cli.yml`. Keep as an extra job in the caller after migration. Record on [inventory.md](../inventory.md). |
| goreleaser | omitted (intentional) | `.goreleaser.yaml` exists. Release is not class CI. Do not fold it into `go-cli.yml`. |
| `make test-integration` / `test-all` | omitted (intentional) | Not invoked by current `ci.yml`. Do not add them to the shared workflow. |

## Gate

Do not replace `ci.yml` until `#8` fixtures are green, Nash/Jeremy review, and a later `@v1` caller run succeeds. Do not delete the copied workflow first.
