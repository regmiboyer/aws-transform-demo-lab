#!/usr/bin/env bash
# What: run atx custom transformations headless across every row in estate/inventory.csv in parallel.
# Why:  the "scale" beat of the demo — six apps transformed at once, one CSV of results.
set -euo pipefail

LAB_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1090
source "$LAB_ROOT/config/lab.env"

CSV="$LAB_ROOT/estate/inventory.csv"
[[ -f "$CSV" ]] || { echo "missing $CSV"; exit 1; }
RESULTS="$LAB_ROOT/guides/build/atx-results.csv"
mkdir -p "$(dirname "$RESULTS")"
echo "app,status,duration_s,branch" > "$RESULTS"

run_one() {
  local app="$1" transformation="$2" build_cmd="$3" plan_ctx="$4"
  local dir="$WORKSPACE/$app" start branch status
  [[ -d "$dir" ]] || { echo "$app,missing-dir,0," >> "$RESULTS"; return; }
  start=$SECONDS
  if (cd "$dir" && AWS_PROFILE="$AWS_PROFILE" atx custom def exec -p . -n "$transformation" -c "$build_cmd" -g "$plan_ctx" -x ${CAMPAIGN_ID:+-i "$CAMPAIGN_ID"}) >/dev/null 2>&1; then
    status=ok
  else
    status=fail
  fi
  branch=$(cd "$dir" && git branch | awk '/atx-result-staging-/ {print $NF; exit}')
  echo "$app,$status,$((SECONDS-start)),$branch" >> "$RESULTS"
  echo "  $app → $status"
}

tail -n +2 "$CSV" | while IFS=',' read -r app _from _to transformation build_cmd plan_ctx; do
  while (( $(jobs -rp | wc -l) >= PARALLELISM )); do wait -n; done
  run_one "$app" "$transformation" "$build_cmd" "$plan_ctx" &
done
wait
echo "Results: $RESULTS"
