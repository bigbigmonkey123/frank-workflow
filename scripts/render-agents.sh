#!/usr/bin/env bash
set -euo pipefail
TEMPLATE="${1:-templates/AGENTS.template.md}"
OUT="${2:-AGENTS.generated.md}"
PERSONA_FILE="${PERSONA_FILE:-templates/personas/neutral.md}"
PERSONA_RULES=$(cat "$PERSONA_FILE")
export PERSONA_RULES
python3 - "$TEMPLATE" "$OUT" <<'PY'
import os, sys
src, dst = sys.argv[1:]
text = open(src).read().replace('{{PERSONA_RULES}}', os.environ.get('PERSONA_RULES',''))
open(dst,'w').write(text)
PY
echo "rendered $OUT"
