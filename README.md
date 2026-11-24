# AWS Transform Demo Lab (skill)

Self-contained demo kit for AWS Transform (custom, continuous modernization, ARA, MODA). Drive from Kiro, Claude Code or a plain terminal. Connects only to one Isengard account and one git remote.

## Quick start

```bash
bash bin/setup.sh          # answers 5 questions → config/lab.env
bash bin/preflight.sh      # verify tools + AWS identity
bash scripts/deploy-estate.sh
bash bin/build-guide.sh
open guides/build/customer-demo.html
```

When the demo ends:

```bash
bash bin/reset.sh
```

## Windows

```powershell
bin\setup.ps1
bin\preflight.ps1
# then use WSL / git-bash for scripts/*.sh (they rely on bash + git date rewriting)
bash bin/build-guide.sh
start guides\build\customer-demo.html
```

## What's bundled

- `estate/` — Harbourline Mutual 21-codebase estate + the six `App*` custom-transform apps. Answer key included.
- `guides/src/` — markdown source for the two HTML guides.
- `bin/` — preflight, setup, build-guide, reset (bash + powershell).
- `scripts/` — deploy-estate, run-atx-all, run-ara-moda, introduce-drift, sync-from-source (maintainer-only).

## Security note

Push this skill only to a repo that has passed your security + vuln scan. The sample estate uses the AWS-provided example credentials and `.example` hostnames — safe to commit. `config/lab.env` is written 600-mode and git-ignored.

## Maintainer

To refresh the bundled estate from the upstream `aws_transform_capabilities` repo:

```bash
bash scripts/sync-from-source.sh ~/code/aws_transform_capabilities
git add estate && git commit -m "Sync estate from aws_transform_capabilities"
```
