#!/usr/bin/env bash
# What: install this skill into Claude Code and/or Kiro from a fresh clone.
# Why:  colleagues clone the hosted repo and run one command — no manual copy-paste.
# Usage: ./install.sh [--claude-code] [--kiro] [--both]   (default: --both)
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
NAME="aws-transform-demo-lab"
MODE="${1:---both}"

CLAUDE_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
KIRO_DIR="${KIRO_SKILLS_DIR:-$HOME/.kiro/skills}"

install_to() {
  local dest="$1" label="$2"
  mkdir -p "$dest"
  local target="$dest/$NAME"
  if [[ -e "$target" ]]; then
    read -r -p "  $target exists. Overwrite? [y/N] " a
    [[ "$a" == "y" || "$a" == "Y" ]] || { echo "  skipped $label"; return; }
    rm -rf "$target"
  fi
  # copy everything except build artifacts and local env
  rsync -a --exclude 'config/lab.env' --exclude 'guides/build/' --exclude '.git' "$SRC/" "$target/"
  chmod +x "$target"/bin/*.sh "$target"/scripts/*.sh 2>/dev/null || true
  echo "  ✓ installed to $target  ($label)"
}

case "$MODE" in
  --claude-code) install_to "$CLAUDE_DIR" "Claude Code" ;;
  --kiro)        install_to "$KIRO_DIR"   "Kiro" ;;
  --both|"")     install_to "$CLAUDE_DIR" "Claude Code"; install_to "$KIRO_DIR" "Kiro" ;;
  *) echo "usage: $0 [--claude-code|--kiro|--both]"; exit 1 ;;
esac

echo
echo "Invoke from Kiro or Claude Code: \"set up the AWS Transform demo lab\""
