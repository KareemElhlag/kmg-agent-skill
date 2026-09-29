#!/usr/bin/env bash
# Created By: Karim-(KaReem Elhlag)-Abdelhady
# init-temp.sh — isolated scratch-directory initialization & hygiene guard.
#
# Contract (SKILL.md §4):
#   * One scratch directory per session: temp/ at the project root.
#   * ALL intermediate artifacts live there (gate logs, curl dumps, probes, one-off scripts).
#   * temp/ is git-ignored by contract and safe to wipe at any time.
#   * The project tree itself is never polluted with scratch files.
#
# Usage:
#   scripts/init-temp.sh              # initialize + hygiene check
#   scripts/init-temp.sh --check-only # hygiene check without creating anything
#   scripts/init-temp.sh --wipe       # empty temp/ (durable records must already exist)

set -euo pipefail

CHECK_ONLY=0
WIPE=0
for arg in "$@"; do
  case "$arg" in
    --check-only) CHECK_ONLY=1 ;;
    --wipe)       WIPE=1 ;;
    *) echo "unknown flag: $arg" >&2; exit 2 ;;
  esac
done

# Resolve the project root = directory containing this script's parent (the skill package root).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT"

TEMP_DIR="$ROOT/temp"
GITIGNORE="$ROOT/.gitignore"

# ── 1. Ensure .gitignore carries the temp/ contract ─────────────────────────
ensure_gitignore() {
  local marker="# kmg-agent-skill: isolated scratch (never commit probe output)"
  if [ ! -f "$GITIGNORE" ]; then
    if [ "$CHECK_ONLY" -eq 1 ]; then
      echo "FAIL: .gitignore missing (cannot honour the temp/ contract)."
      exit 1
    fi
    printf '%s\n' "$marker" > "$GITIGNORE"
  fi
  if ! grep -qxF 'temp/' "$GITIGNORE"; then
    if [ "$CHECK_ONLY" -eq 1 ]; then
      echo "FAIL: 'temp/' is not git-ignored."
      exit 1
    fi
    {
      echo ""
      echo "$marker"
      echo "temp/"
    } >> "$GITIGNORE"
    echo "OK: added temp/ to .gitignore"
  fi
}

# ── 2. Create or wipe the scratch directory ─────────────────────────────────
if [ "$WIPE" -eq 1 ]; then
  if [ -d "$TEMP_DIR" ]; then
    rm -rf "${TEMP_DIR:?}/"* 2>/dev/null || true
    echo "OK: temp/ wiped (durable records are the only source of truth)."
  else
    echo "OK: no temp/ to wipe."
  fi
  exit 0
fi

if [ "$CHECK_ONLY" -eq 0 ]; then
  mkdir -p "$TEMP_DIR"
  echo "OK: temp/ ready at $TEMP_DIR"
fi

ensure_gitignore

# ── 3. Hygiene: no stray scratch artifacts in the project tree ──────────────
# Heuristic scratch-name patterns commonly produced by agents (adjust per project).
STRAY_PATTERNS=(
  'gate*.txt' 'nexus*.txt' 'probe*.txt' 'scratch*.txt' 'output*.txt'
  'curl-dump*' '*-dump.json' 'tmp-*' '.scratch*'
)

stray_found=0
for pattern in "${STRAY_PATTERNS[@]}"; do
  # Search only tracked-top-level areas; skip temp/, node_modules, bin/obj, .git.
  while IFS= read -r -d '' f; do
    case "$f" in
      ./temp/*|*/node_modules/*|*/bin/*|*/obj/*|*/.git/*) continue ;;
    esac
    echo "STRAY: $f  (move into temp/ or delete — the tree must stay clean)"
    stray_found=1
  done < <(find . -path ./temp -prune -o -path ./node_modules -prune -o \
                -path ./.git -prune -o -type f -name "$pattern" -print0 2>/dev/null)
done

if [ "$stray_found" -eq 1 ]; then
  echo "HYGIENE: FAIL — stray scratch artifacts outside temp/."
  exit 1
fi

echo "HYGIENE: PASS — tree clean, temp/ isolated and git-ignored."
