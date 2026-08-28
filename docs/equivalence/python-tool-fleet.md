# Python tool — `itsjeremyjohnson/fleet`

Status: `held`. Personal private repo. Visible via `gh api` as `itsjeremyjohnson`.

Compared 2026-08-28 via `gh api` (no clone):

- Root: `fleet.py`, `requirements.txt`, `tests/`, `adapters/`, `schemas/`, … — **no** `.github` (`GET .../contents/.github` → 404)
- `requirements.txt`: `PyYAML>=6.0,<7` and `jsonschema>=4.10,<5`
- `tests/`: `test_apply.py`, `test_check_upstream.py`, `test_clickup.py`, `test_code_review.py`, `test_ox_alpha.py`, `test_preview.py`, `test_rollback.py`, `test_unslop.py`, `test_validate.py`, `test_verify.py`, `test_zeus_preview.py`
- Shared: `python-tool.yml@472bfa1`

`hermes` and `robben-triage` were checked as alternates. Neither has a root `pyproject.toml` or `requirements.txt`. They are not this representative.

RM alternate `domain-info-fetcher` has `requirements.txt` + `domain_info_fetcher.py` and an echo-stub `ci.yml`. Not chosen; Charlie's list prefers fleet/hermes/robben-triage.

## Existing checks

None. There is no workflow file to retain.

## Shared `python-tool.yml` checks

- Require `pyproject.toml` or `requirements.txt` or `requirements-test.txt`
- `pip install -r requirements.txt` (no `requirements-test.txt` here)
- `pip install pytest`
- `python -m pytest` because `tests/` exists

## Comparison

| Check | Verdict | Notes |
| --- | --- | --- |
| Manifest install | added | From `requirements.txt`. |
| `pytest` | added | `tests/` is present. |
| `compileall` fallback | omitted | Not used when `tests/` exists. |
| Copied CI | none | Nothing to delete. A later caller is still `held`. |

## Gate

Do not add a caller until `#8` fixtures are green and Nash/Jeremy review. Repo Surgeon owns callers.
