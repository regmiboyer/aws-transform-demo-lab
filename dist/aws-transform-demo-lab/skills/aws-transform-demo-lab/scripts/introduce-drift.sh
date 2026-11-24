#!/usr/bin/env bash
# What: plant a bad commit in the clean onboarding-api so a second atx ct run surfaces NEW findings.
# Why:  the "continuous modernization" beat — shows the agent catching regressions on a repo that
#       previously came back clean.
set -euo pipefail
LAB_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1090
source "$LAB_ROOT/config/lab.env"
REPO="$WORKSPACE/onboarding-api"
[[ -d "$REPO/.git" ]] || { echo "onboarding-api not deployed"; exit 1; }
cd "$REPO"
cat >> src/main/java/com/harbourline/onboarding/DebugController.java <<'EOF'

// drifted change — rushed agent-assisted edit
@RestController class DebugController {
  // Text4Shell-vulnerable lookup
  String process(String s){ return org.apache.commons.text.StringSubstitutor.createInterpolator().replace(s); }
  // hardcoded key
  static final String KEY = "AKIAIOSFODNN7EXAMPLE";
  // unsafe DELETE — no auth, no idempotency
  @DeleteMapping("/customer/{id}") void del(@PathVariable String id){ /* ... */ }
}
EOF
git add -A
git -c user.email=rushed@harbourline.example -c user.name="Rushed Dev" commit -q -m "quick fix (agent-assisted)"
echo "Drift planted on onboarding-api. Undo: (cd $REPO && git reset --hard HEAD~1)"
