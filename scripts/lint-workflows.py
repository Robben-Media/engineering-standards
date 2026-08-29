#!/usr/bin/env python3
"""Parse every GitHub Actions workflow YAML file. Exit 1 on syntax errors."""

from __future__ import annotations

import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("PyYAML is required (pip install pyyaml)", file=sys.stderr)
    sys.exit(2)


def main() -> int:
    root = Path(".github/workflows")
    files = sorted(root.glob("*.yml")) + sorted(root.glob("*.yaml"))
    if not files:
        print(f"No workflow files under {root}", file=sys.stderr)
        return 1
    failed = 0
    for path in files:
        try:
            docs = list(yaml.safe_load_all(path.read_text()))
        except yaml.YAMLError as exc:
            print(f"FAIL {path}: {exc}", file=sys.stderr)
            failed += 1
            continue
        print(f"OK {path} ({len(docs)} document(s))")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
