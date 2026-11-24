#!/usr/bin/env bash
# What: verify local tools + AWS identity before any demo step.
# Why:  a missing dep found mid-demo costs trust; find it now.
set -euo pipefail

say() { printf "\033[1;36m[preflight]\033[0m %s\n" "$*"; }
ok()  { printf "  \033[32m✓\033[0m %s\n" "$*"; }
bad() { printf "  \033[31m✗\033[0m %s\n" "$*"; FAIL=1; }

FAIL=0
LAB_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$LAB_ROOT/config/lab.env"

say "Checking required tools"
for cmd in git python3 aws atx; do
  if command -v "$cmd" >/dev/null 2>&1; then ok "$cmd: $(command -v $cmd)"; else bad "$cmd not found"; fi
done

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  say "Checking AWS identity for profile=$AWS_PROFILE region=$AWS_REGION"
  if ident=$(AWS_PROFILE="$AWS_PROFILE" aws sts get-caller-identity --region "$AWS_REGION" 2>&1); then
    ok "$ident"
  else
    bad "aws sts get-caller-identity failed: $ident"
    echo "    → run 'isengardcli credentials $AWS_PROFILE --role Admin' or re-auth."
  fi
else
  say "config/lab.env not found — run bin/setup.sh next."
fi

if [[ $FAIL -ne 0 ]]; then
  echo
  echo "Preflight failed. Fix the ✗ items above, then re-run."
  exit 1
fi
echo
say "Preflight OK."
