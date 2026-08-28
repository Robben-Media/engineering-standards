#!/usr/bin/env bash
set -euo pipefail
# Downloads rhysd/actionlint v1.7.12 (linux amd64) and verifies the published SHA-256.
# Checksum observed from the GitHub release asset digest on 2026-08-28:
# https://github.com/rhysd/actionlint/releases/tag/v1.7.12
version="${ACTIONLINT_VERSION:?}"
expect="${ACTIONLINT_SHA256:?}"
archive="actionlint_${version}_linux_amd64.tar.gz"
url="https://github.com/rhysd/actionlint/releases/download/v${version}/${archive}"
curl -fsSL -o "${archive}" "${url}"
echo "${expect}  ${archive}" | sha256sum -c -
tar -xzf "${archive}" actionlint
./actionlint -color
