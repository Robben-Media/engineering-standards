#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DETECT="$ROOT/scripts/detect-node-lockfile.sh"
FIX="$ROOT/fixtures/node-lockfile"
pass=0
fail=0
assert_ok() {
  local desc="$1" wd="$2" exp_name="$3" exp_lf="$4" exp_path="$5"
  shift 5
  local out rc
  set +e
  out=$("$DETECT" --working-directory "$wd" "$@" 2>&1)
  rc=$?
  set -e
  if [ "$rc" -ne 0 ]; then
    echo "FAIL $desc (exit $rc)"
    echo "$out"
    fail=$((fail+1))
    return
  fi
  echo "$out" | grep -q "^name=${exp_name}$" || { echo "FAIL $desc name"; echo "$out"; fail=$((fail+1)); return; }
  echo "$out" | grep -q "^lockfile=${exp_lf}$" || { echo "FAIL $desc lockfile"; echo "$out"; fail=$((fail+1)); return; }
  echo "$out" | grep -q "^lockfile-path=${exp_path}$" || { echo "FAIL $desc path"; echo "$out"; fail=$((fail+1)); return; }
  echo "$out" | grep -q "Detected lockfile path: ${exp_path}" || { echo "FAIL $desc log path"; echo "$out"; fail=$((fail+1)); return; }
  echo "PASS $desc"
  pass=$((pass+1))
}

assert_fail() {
  local desc="$1"
  shift
  local out rc
  set +e
  out=$("$DETECT" "$@" 2>&1)
  rc=$?
  set -e
  if [ "$rc" -eq 0 ]; then
    echo "FAIL $desc (expected failure)"
    echo "$out"
    fail=$((fail+1))
    return
  fi
  echo "PASS $desc"
  pass=$((pass+1))
}

cd "$ROOT"

# Root fixtures: exactly one lockfile in the fixture directory.
for d in "$FIX"/*-root; do
  [ -d "$d" ] || continue
  rel="${d#$ROOT/}"
  lf=""
  cands="bun.lock bun.lockb pnpm-lock.yaml yarn.lock package-lock.json"
  for c in $cands; do
    if [ -f "$d/$c" ]; then lf="$c"; break; fi
  done
  case "$lf" in
    bun.lock|bun.lockb) name=bun ;;
    pnpm-lock.yaml) name=pnpm ;;
    yarn.lock) name=yarn ;;
    package-lock.json) name=npm ;;
  esac
  assert_ok "$rel" "$rel" "$name" "$lf" "$rel/$lf"
done

# Subdirectory fixtures: lockfile is nested.
for d in "$FIX"/*-subdir; do
  [ -d "$d" ] || continue
  lf_path=""
  cands="bun.lock bun.lockb pnpm-lock.yaml yarn.lock package-lock.json"
  while IFS= read -r f; do
    base=$(basename "$f")
    for c in $cands; do
      if [ "$base" = "$c" ]; then lf_path="$f"; break 2; fi
    done
  done < <(find "$d" -type f)
  rel_path="${lf_path#$ROOT/}"
  wd=$(dirname "$rel_path")
  lf=$(basename "$rel_path")
  case "$lf" in
    bun.lock|bun.lockb) name=bun ;;
    pnpm-lock.yaml) name=pnpm ;;
    yarn.lock) name=yarn ;;
    package-lock.json) name=npm ;;
  esac
  assert_ok "$rel_path" "$wd" "$name" "$lf" "$rel_path"
done

assert_fail "multi lockfile without override" --working-directory "fixtures/node-lockfile/multi-lockfile"
assert_fail "both bun without override" --working-directory "fixtures/node-lockfile/both-bun"
assert_fail "empty no lockfile" --working-directory "fixtures/node-lockfile/empty"
assert_fail "invalid manager" --working-directory "fixtures/node-lockfile/npm-root" --package-manager cargo
assert_fail "manager mismatch" --working-directory "fixtures/node-lockfile/npm-root" --package-manager bun
assert_fail "missing directory" --working-directory "fixtures/node-lockfile/does-not-exist"
assert_ok "multi resolved npm" "fixtures/node-lockfile/multi-lockfile" npm package-lock.json "fixtures/node-lockfile/multi-lockfile/package-lock.json" --package-manager npm
assert_ok "multi resolved yarn" "fixtures/node-lockfile/multi-lockfile" yarn yarn.lock "fixtures/node-lockfile/multi-lockfile/yarn.lock" --package-manager yarn
assert_ok "both bun prefers text lock" "fixtures/node-lockfile/both-bun" bun bun.lock "fixtures/node-lockfile/both-bun/bun.lock" --package-manager bun

gout=$(mktemp)
GITHUB_OUTPUT="$gout" "$DETECT" --working-directory "fixtures/node-lockfile/npm-root" >/dev/null
if grep -q "^name=npm$" "$gout" && grep -q "^lockfile=package-lock.json$" "$gout"; then
  echo "PASS github output keys"
  pass=$((pass+1))
else
  echo "FAIL github output keys"
  cat "$gout"
  fail=$((fail+1))
fi
rm -f "$gout"

echo "Passed: $pass  Failed: $fail"
if [ "$fail" -ne 0 ]; then
  exit 1
fi
