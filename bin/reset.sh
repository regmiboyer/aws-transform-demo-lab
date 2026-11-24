#!/usr/bin/env bash
# What: reset the lab to a pristine, demo-ready state.
# Why:  back-to-back demos must start identical. One command, no manual cleanup.
set -euo pipefail

LAB_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$LAB_ROOT/config/lab.env"
[[ -f "$ENV_FILE" ]] || { echo "config/lab.env missing — run bin/setup.sh first."; exit 1; }
# shellcheck disable=SC1090
source "$ENV_FILE"

echo "This will:"
echo "  • delete atx-result-staging-* branches in $WORKSPACE/*"
echo "  • reset each repo in $WORKSPACE to its back-dated first commit"
echo "  • clear atx ct source/analysis state in AWS profile=$AWS_PROFILE region=$AWS_REGION"
echo "  • delete guides/build/*.html (regenerate via bin/build-guide.sh)"
echo
read -r -p "Type 'yes' to proceed: " ans
[[ "$ans" == "yes" ]] || { echo "aborted."; exit 0; }

# 1. Repo state
if [[ -d "$WORKSPACE" ]]; then
  for d in "$WORKSPACE"/*/; do
    [[ -d "$d/.git" ]] || continue
    (cd "$d"
     git branch | grep 'atx-result-staging-' | xargs -r git branch -D >/dev/null 2>&1 || true
     # drop any drift commits — reset to the oldest commit (the back-dated initial)
     first=$(git rev-list --max-parents=0 HEAD | tail -1)
     git reset --hard "$first" >/dev/null
     git clean -fdx >/dev/null)
    echo "  reset $(basename "$d")"
  done
fi

# 2. atx ct state (best-effort; CLI may change)
if command -v atx >/dev/null; then
  AWS_PROFILE="$AWS_PROFILE" atx ct source list --region "$AWS_REGION" 2>/dev/null | \
    awk 'NR>1 {print $1}' | while read -r sid; do
      [[ -n "$sid" ]] && AWS_PROFILE="$AWS_PROFILE" atx ct source remove --id "$sid" --region "$AWS_REGION" >/dev/null 2>&1 || true
    done
fi

# 3. Built guides
rm -f "$LAB_ROOT/guides/build/"*.html

echo
echo "Reset complete. Re-run scripts/deploy-estate.sh and bin/build-guide.sh before the next demo."
