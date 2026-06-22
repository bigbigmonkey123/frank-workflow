#!/usr/bin/env bash
set -euo pipefail
TMPDIR_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/frank-workflow-bootstrap.XXXXXX")"
cleanup() { rm -rf "$TMPDIR_ROOT"; }
trap cleanup EXIT
PROJECT="$TMPDIR_ROOT/demo-project"
HOME_DIR="$TMPDIR_ROOT/home"
mkdir -p "$PROJECT" "$HOME_DIR"
FRANK_WORKFLOW_HOME="$HOME_DIR/.frank-workflow" scripts/bootstrap.sh --project "$PROJECT" --name demo-project
for f in \
  "$PROJECT/AGENTS.md" \
  "$PROJECT/CLAUDE.md" \
  "$PROJECT/.frank-workflow/config.toml" \
  "$PROJECT/.frank-workflow/project.md" \
  "$PROJECT/.frank-workflow/review-request.md" \
  "$PROJECT/.frank-workflow/post-dev-review.md" \
  "$PROJECT/.frank-workflow/qa-report.md" \
  "$HOME_DIR/.frank-workflow/templates/AGENTS.template.md"; do
  [[ -f "$f" ]] || { echo "missing bootstrap output: $f" >&2; exit 1; }
done
grep -q 'demo-project' "$PROJECT/.frank-workflow/project.md"
grep -q 'Read AGENTS.md first' "$PROJECT/CLAUDE.md"
echo "bootstrap test passed"
