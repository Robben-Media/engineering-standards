#!/usr/bin/env bash
set -euo pipefail
# Keep in sync with the Detect package manager step in .github/workflows/node-bun.yml
WD="${WORKING_DIRECTORY:-.}"
PM="${PACKAGE_MANAGER:-}"
while [ $# -gt 0 ]; do
  case "$1" in
    --working-directory) WD="$2"; shift 2 ;;
    --package-manager) PM="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done
WD="${WD%/}"; WD="${WD#./}"; [ -z "$WD" ] && WD="."
PM="$(printf "%s" "$PM" | tr "[:upper:]" "[:lower:]" | tr -d "[:space:]")"
[ -d "$WD" ] || { echo "working-directory does not exist: $WD" >&2; exit 1; }
if [ -n "$PM" ]; then
  case "$PM" in
    bun|pnpm|yarn|npm) ;;
    *) echo "Invalid package-manager: $PM" >&2; exit 1 ;;
  esac
fi
found=""
count=0
if [ -n "$PM" ]; then
  case "$PM" in
    bun) cands="bun.lock bun.lockb" ;;
    pnpm) cands="pnpm-lock.yaml" ;;
    yarn) cands="yarn.lock" ;;
    npm) cands="package-lock.json" ;;
  esac
else
  cands="bun.lock bun.lockb pnpm-lock.yaml yarn.lock package-lock.json"
fi
for lf in $cands; do
  if [ -f "$WD/$lf" ]; then found="$found $lf"; count=$((count+1)); fi
done
found="${found# }"
if [ "$count" -eq 0 ]; then
  if [ -n "$PM" ]; then echo "package-manager=$PM but no matching lockfile in $WD" >&2
  else echo "No supported lockfile in $WD" >&2; fi
  exit 1
fi
if [ -z "$PM" ] && [ "$count" -gt 1 ]; then
  echo "Multiple lockfiles found in $WD: $found" >&2
  echo "Pass package-manager (bun|pnpm|yarn|npm) to disambiguate." >&2
  exit 1
fi
lockfile="${found%% *}"
case "$lockfile" in
  bun.lock|bun.lockb) name=bun ;;
  pnpm-lock.yaml) name=pnpm ;;
  yarn.lock) name=yarn ;;
  package-lock.json) name=npm ;;
esac
if [ "$WD" = "." ]; then path="$lockfile"; else path="$WD/$lockfile"; fi
echo "Detected package manager: $name"
echo "Detected lockfile: $lockfile"
echo "Detected lockfile path: $path"
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "name=$name" >> "$GITHUB_OUTPUT"
  echo "lockfile=$lockfile" >> "$GITHUB_OUTPUT"
  echo "lockfile-path=$path" >> "$GITHUB_OUTPUT"
fi
echo "name=$name"
echo "lockfile=$lockfile"
echo "lockfile-path=$path"
