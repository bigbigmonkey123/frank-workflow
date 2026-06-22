#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_PROJECT="${TARGET_PROJECT:-$PWD}"
INSTALL_HOME="${FRANK_WORKFLOW_HOME:-$HOME/.frank-workflow}"
PROJECT_NAME="${PROJECT_NAME:-$(basename "$TARGET_PROJECT")}"
DRY_RUN=0
LIVE=0
FORCE=0

usage() {
  cat <<'USAGE'
Usage: scripts/bootstrap.sh [--project PATH] [--name NAME] [--home PATH] [--dry-run] [--live] [--force]

One-command setup for Frank Workflow:
  1. Check required tools.
  2. Install framework templates into FRANK_WORKFLOW_HOME (default: ~/.frank-workflow).
  3. Create project-local .frank-workflow/config.toml and project.md.
  4. Render AGENTS.md and CLAUDE.md if absent, or with --force.
  5. Run dry-run bridge smoke tests.

Options:
  --project PATH   Target project to initialize (default: current directory).
  --name NAME      Project display name (default: target directory basename).
  --home PATH      Framework install directory (default: FRANK_WORKFLOW_HOME or ~/.frank-workflow).
  --dry-run        Print actions without writing files.
  --live           Also run scripts/check-env.sh --live for optional external tools.
  --force          Overwrite generated AGENTS.md/CLAUDE.md if they already exist.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) TARGET_PROJECT="${2:?--project requires a path}"; shift 2 ;;
    --name) PROJECT_NAME="${2:?--name requires a value}"; shift 2 ;;
    --home) INSTALL_HOME="${2:?--home requires a path}"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --live) LIVE=1; shift ;;
    --force) FORCE=1; shift ;;
    --help|-h) usage; exit 0 ;;
    *) echo "error: unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

resolve_target_project() {
  local path="$1"
  if [[ "$DRY_RUN" == "1" && ! -d "$path" ]]; then
    case "$path" in
      /*) printf '%s\n' "$path" ;;
      *) printf '%s/%s\n' "$PWD" "$path" ;;
    esac
  else
    mkdir -p "$path"
    cd "$path" && pwd
  fi
}

TARGET_PROJECT="$(resolve_target_project "$TARGET_PROJECT")"

say() { printf '%s\n' "$*"; }
write_file() {
  local path="$1" content="$2"
  if [[ "$DRY_RUN" == "1" ]]; then
    say "dry-run: write $path"
  else
    mkdir -p "$(dirname "$path")"
    printf '%s\n' "$content" > "$path"
  fi
}
copy_if_needed() {
  local src="$1" dst="$2"
  if [[ -e "$dst" && "$FORCE" != "1" ]]; then
    say "skip existing: $dst"
    return 0
  fi
  if [[ "$DRY_RUN" == "1" ]]; then
    say "dry-run: copy $src -> $dst"
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
  fi
}

say "Frank Workflow bootstrap"
say "root=$ROOT"
say "home=$INSTALL_HOME"
say "project=$TARGET_PROJECT"
say "name=$PROJECT_NAME"

if [[ "$LIVE" == "1" ]]; then
  "$ROOT/scripts/check-env.sh" --live
else
  "$ROOT/scripts/check-env.sh"
fi

if [[ "$DRY_RUN" == "1" ]]; then
  "$ROOT/scripts/install.sh" --dry-run
else
  FRANK_WORKFLOW_HOME="$INSTALL_HOME" "$ROOT/scripts/install.sh"
fi

write_file "$TARGET_PROJECT/.frank-workflow/config.toml" "[overlay]
enabled = true
project = \".frank-workflow/project.md\""

write_file "$TARGET_PROJECT/.frank-workflow/project.md" "## Project Overlay

Project: $PROJECT_NAME

Use this file for project-specific workflow notes. Keep private secrets and credentials out of Git."

if [[ ! -e "$TARGET_PROJECT/AGENTS.md" || "$FORCE" == "1" ]]; then
  if [[ "$DRY_RUN" == "1" ]]; then
    say "dry-run: render AGENTS.md"
  else
    PERSONA_FILE="$ROOT/templates/personas/neutral.md" "$ROOT/scripts/render-agents.sh" "$ROOT/templates/AGENTS.template.md" "$TARGET_PROJECT/AGENTS.md" >/dev/null
  fi
else
  say "skip existing: $TARGET_PROJECT/AGENTS.md"
fi

copy_if_needed "$ROOT/templates/CLAUDE.template.md" "$TARGET_PROJECT/CLAUDE.md"
copy_if_needed "$ROOT/templates/review-request.md" "$TARGET_PROJECT/.frank-workflow/review-request.md"
copy_if_needed "$ROOT/templates/post-dev-review.md" "$TARGET_PROJECT/.frank-workflow/post-dev-review.md"
copy_if_needed "$ROOT/templates/qa-report.md" "$TARGET_PROJECT/.frank-workflow/qa-report.md"

if [[ "$DRY_RUN" != "1" ]]; then
  CLAUDE_BRIDGE_DRY_RUN=1 "$ROOT/bridges/claude/claude-official-bridge" send "$ROOT/templates/review-request.md" >/dev/null
  CODEX_BRIDGE_DRY_RUN=1 "$ROOT/bridges/codex/codex-bridge" status >/dev/null
  GEMINI_BRIDGE_DRY_RUN=1 "$ROOT/bridges/gemini/gemini-bridge" status >/dev/null
fi

say "bootstrap complete"
say "next: cd '$TARGET_PROJECT' && edit AGENTS.md / .frank-workflow/project.md"
