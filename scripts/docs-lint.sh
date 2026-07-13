#!/usr/bin/env bash
set -euo pipefail
for f in README.md AGENTS.md CLAUDE.md LICENSE NOTICE SECURITY.md CONTRIBUTING.md CHANGELOG.md VERSION \
  docs/bridge-protocol.md docs/workflow.md docs/review-gates.md docs/capacity-resilience.md docs/migration-v0.2.md; do
  [[ -f "$f" ]] || { echo "missing $f" >&2; exit 1; }
done
version="$(cat VERSION)"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "invalid VERSION: $version" >&2; exit 1; }
grep -q "release-v${version}-" README.md || { echo "README release badge does not match VERSION" >&2; exit 1; }
grep -q "^## \[v${version}\]" CHANGELOG.md || { echo "CHANGELOG does not match VERSION" >&2; exit 1; }
grep -q 'tracked change' docs/review-gates.md || { echo "review invalidation rule missing" >&2; exit 1; }
grep -q '`74`' docs/bridge-protocol.md || { echo "capacity replay contract missing" >&2; exit 1; }
echo "docs lint clean"
