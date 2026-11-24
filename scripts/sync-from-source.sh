#!/usr/bin/env bash
# What: one-time bundle step — copy the Harbourline estate + custom apps from the source repo.
# Why:  the skill ships self-contained. This script is for the maintainer, not the colleague running demos.
#       Run once when the upstream aws_transform_capabilities repo changes.
set -euo pipefail
LAB_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="${1:-$HOME/code/aws_transform_capabilities}"
[[ -d "$SRC" ]] || { echo "pass the path to aws_transform_capabilities as arg 1"; exit 1; }
mkdir -p "$LAB_ROOT/estate"
# copy custom/ apps
for d in "$SRC/custom"/App*/; do
  cp -R "$d" "$LAB_ROOT/estate/$(basename "$d")"
done
# copy Harbourline codebases
for d in "$SRC/continuous-modernization-assessment"/harbourline-*/; do
  cp -R "$d" "$LAB_ROOT/estate/$(basename "$d")"
done
# answer key, inventory, tech radar
cp "$SRC/continuous-modernization-assessment/EXPECTED_FINDINGS.md"   "$LAB_ROOT/estate/" 2>/dev/null || true
cp "$SRC/continuous-modernization-assessment/expected-findings.json" "$LAB_ROOT/estate/" 2>/dev/null || true
cp "$SRC/continuous-modernization-assessment/portfolio-inventory.csv" "$LAB_ROOT/estate/" 2>/dev/null || true
cp "$SRC/custom/inventory.csv" "$LAB_ROOT/estate/inventory.csv" 2>/dev/null || true
cp -R "$SRC/continuous-modernization-assessment/company-standards" "$LAB_ROOT/estate/" 2>/dev/null || true
echo "Bundled $(ls -1 "$LAB_ROOT/estate" | wc -l | tr -d ' ') items into estate/"
echo "Commit the result to the skill repo so colleagues get a self-contained lab."
