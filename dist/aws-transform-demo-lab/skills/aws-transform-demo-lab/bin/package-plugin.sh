#!/usr/bin/env bash
# What: build a Kiro-/Claude-compatible Agent Plugin layout from this flat skill.
# Why:  Kiro's registry (and the Agent Plugins spec) wants plugin.json at the root and
#       skills under skills/<name>/. Our dev layout keeps SKILL.md at the root for convenience;
#       this script produces the publishable shape in dist/.
# Output: dist/aws-transform-demo-lab/   (ready to `git init && push` as the hosted repo)
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)"
NAME="aws-transform-demo-lab"
OUT="$SRC/dist/$NAME"

rm -rf "$SRC/dist"
mkdir -p "$OUT/skills/$NAME"

# plugin.json and docs at the root
cp "$SRC/plugin.json"  "$OUT/"
cp "$SRC/README.md"    "$OUT/"
cp "$SRC/INSTALL.md"   "$OUT/"
cp "$SRC/install.sh"   "$OUT/"
cp "$SRC/install.ps1"  "$OUT/"
cp "$SRC/.gitignore"   "$OUT/"

# skill payload
cp "$SRC/SKILL.md" "$OUT/skills/$NAME/"
for d in bin scripts guides estate config; do
  [[ -d "$SRC/$d" ]] && cp -R "$SRC/$d" "$OUT/skills/$NAME/"
done
rm -f "$OUT/skills/$NAME/config/lab.env"
rm -rf "$OUT/skills/$NAME/guides/build"

echo "Packaged plugin at: $OUT"
echo
echo "Next:"
echo "  cd $OUT"
echo "  git init -b main && git add -A && git commit -m 'Initial plugin'"
echo "  gh repo create <org>/$NAME --public --source=. --push"
echo "  Then submit the repo URL at: https://kiro.dev/registry/submit/"
