#!/usr/bin/env bash
# What: interactive setup; writes config/lab.env used by every other script and the HTML guide.
# Why:  one source of truth for variables (profile, region, git remote, parallelism) — no guessing later.
set -euo pipefail

LAB_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$LAB_ROOT/config/lab.env"

ask() { # ask <var> <prompt> [default]
  local var="$1" prompt="$2" default="${3:-}" ans
  if [[ -n "$default" ]]; then
    read -r -p "$prompt [$default]: " ans || true
    ans="${ans:-$default}"
  else
    read -r -p "$prompt: " ans || true
  fi
  printf -v "$var" '%s' "$ans"
}

echo "AWS Transform Demo Lab — setup"
echo "Answers are saved to $ENV_FILE and interpolated into the HTML guide."
echo

ask AWS_PROFILE  "Isengard AWS profile (the sandbox Transform runs in)"
ask AWS_REGION   "AWS Region" "us-west-2"
ask GIT_REMOTE   "Git remote for the bundled estate (blank = local only)"
ask RUN_LOCATION "Run location: local-mac | local-win | aws-cloudshell" "local-mac"
ask PARALLELISM  "Parallel atx jobs" "3"
ask WORKSPACE    "Workspace dir (where split repos live)" "$HOME/atx-demo-workspace"

mkdir -p "$(dirname "$ENV_FILE")"
cat > "$ENV_FILE" <<EOF
AWS_PROFILE=$AWS_PROFILE
AWS_REGION=$AWS_REGION
GIT_REMOTE=$GIT_REMOTE
RUN_LOCATION=$RUN_LOCATION
PARALLELISM=$PARALLELISM
LAB_ROOT=$LAB_ROOT
WORKSPACE=$WORKSPACE
CAMPAIGN_ID=
EOF
chmod 600 "$ENV_FILE"

echo
echo "Wrote $ENV_FILE"
echo "Next: bin/preflight.sh  then  scripts/deploy-estate.sh  then  bin/build-guide.sh"
