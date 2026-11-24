#!/usr/bin/env bash
# What: run ARA then MODA on every repo in $WORKSPACE, in parallel, collect .md/.json/.html.
# Why:  the "assess" half of the demo. Feeds the portfolio roll-up and the three-phase roadmap.
set -euo pipefail

LAB_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1090
source "$LAB_ROOT/config/lab.env"

OUT="$LAB_ROOT/guides/build/ara-moda"; mkdir -p "$OUT"
ONLY="${ONLY:-}"

run_one() {
  local repo="$1" name; name=$(basename "$repo")
  [[ -z "$ONLY" || ",$ONLY," == *",$name,"* ]] || return 0
  local cfg="$repo/.transform"
  for lens in agentic-readiness-analysis modernization-readiness-analysis; do
    local yaml="$cfg/${lens%%-*}.yaml"
    AWS_PROFILE="$AWS_PROFILE" atx custom def exec -p "$repo" -n "AWS/$lens" \
      ${yaml:+-f "$yaml"} --output "$OUT/$name-$lens" >/dev/null 2>&1 \
      && echo "  $name/$lens ok" \
      || echo "  $name/$lens FAIL"
  done
}

for repo in "$WORKSPACE"/*/; do
  while (( $(jobs -rp | wc -l) >= PARALLELISM )); do wait -n; done
  run_one "$repo" &
done
wait

# portfolio roll-up
AWS_PROFILE="$AWS_PROFILE" atx custom def exec -p "$WORKSPACE" -n "AWS/portfolio-readiness-rollup" \
  --output "$OUT/portfolio" >/dev/null 2>&1 || echo "  portfolio roll-up skipped (recipe may not be enabled)"
echo "Reports: $OUT"
