#!/usr/bin/env bash
# What: split estate/ into one git repo per codebase under $WORKSPACE with back-dated history.
#       Optionally push to $GIT_REMOTE (one subrepo per codebase or one prefixed path).
# Why:  AWS Transform operates one repo per codebase; back-dated commits make the
#       "20-year-old estate" story visibly true on screen.
set -euo pipefail

LAB_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1090
source "$LAB_ROOT/config/lab.env"

mkdir -p "$WORKSPACE"
shopt -s nullglob
count=0
for codebase in "$LAB_ROOT/estate"/*/; do
  name="$(basename "$codebase")"
  dest="$WORKSPACE/$name"
  [[ -d "$dest" ]] && { echo "  skip $name (exists)"; continue; }
  cp -R "$codebase" "$dest"
  # pick back-date from .meta/year or default 2010
  year=$(cat "$codebase/.meta/year" 2>/dev/null || echo 2010)
  date="${year}-06-15T09:00:00"
  (cd "$dest"
   git init -q -b main
   git add -A
   GIT_AUTHOR_DATE="$date" GIT_COMMITTER_DATE="$date" \
     git -c user.email=legacy@harbourline.example -c user.name="Harbourline Mutual" \
     commit -q -m "Initial import ($year)"
   if [[ -n "${GIT_REMOTE:-}" ]]; then
     # derive per-codebase remote by substituting %s if present, else append -<name>
     if [[ "$GIT_REMOTE" == *"%s"* ]]; then remote="${GIT_REMOTE//%s/$name}"; else remote="${GIT_REMOTE%.git}-${name}.git"; fi
     git remote add origin "$remote" 2>/dev/null || git remote set-url origin "$remote"
     git push -u origin main 2>/dev/null || echo "    push failed for $name — check $remote"
   fi)
  echo "  deployed $name ($year)"
  count=$((count+1))
done
echo "Deployed $count codebases to $WORKSPACE"
