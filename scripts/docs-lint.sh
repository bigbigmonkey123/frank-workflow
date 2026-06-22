#!/usr/bin/env bash
set -euo pipefail
for f in README.md AGENTS.md CLAUDE.md LICENSE NOTICE SECURITY.md CONTRIBUTING.md CHANGELOG.md; do
  [[ -f "$f" ]] || { echo "missing $f" >&2; exit 1; }
done
echo "docs lint clean"
