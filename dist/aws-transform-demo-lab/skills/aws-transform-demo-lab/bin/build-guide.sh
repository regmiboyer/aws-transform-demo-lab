#!/usr/bin/env bash
# What: generate guides/build/*.html from guides/src/*.md with variables from config/lab.env
#       interpolated and JS progress-tracking injected.
# Why:  the presenter needs a single browser-openable file with their exact commands pre-filled
#       and checkable milestones that survive refresh.
set -euo pipefail

LAB_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$LAB_ROOT/config/lab.env"
[[ -f "$ENV_FILE" ]] || { echo "config/lab.env missing — run bin/setup.sh first."; exit 1; }
# shellcheck disable=SC1090
source "$ENV_FILE"

mkdir -p "$LAB_ROOT/guides/build"
python3 "$LAB_ROOT/bin/_build_guide.py" \
  --src "$LAB_ROOT/guides/src" \
  --out "$LAB_ROOT/guides/build" \
  --env "$ENV_FILE"

echo
echo "Built:"
ls -1 "$LAB_ROOT/guides/build"
echo
echo "Open in browser:"
echo "  open $LAB_ROOT/guides/build/setup-guide.html"
echo "  open $LAB_ROOT/guides/build/customer-demo.html"
