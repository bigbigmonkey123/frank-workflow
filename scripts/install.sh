#!/usr/bin/env bash
set -euo pipefail
DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1
TARGET="${FRANK_WORKFLOW_HOME:-$HOME/.frank-workflow}"
if [[ "$DRY_RUN" == "1" ]]; then
  echo "dry-run: would create $TARGET and copy templates"
  exit 0
fi
mkdir -p "$TARGET/templates" "$TARGET/overlays"
cp -R templates/. "$TARGET/templates/"
echo "installed templates to $TARGET"
