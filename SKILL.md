---
name: aws-transform-demo-lab
description: Stand up, run and reset a self-contained AWS Transform demo lab (custom, continuous modernization, ARA, MODA) against an Isengard sandbox and the user's git. Use when the user says "set up the AWS Transform demo", "run a Transform demo lab", "prep for a Transform customer demo", or asks to reset it between demos.
---

# AWS Transform Demo Lab

A self-contained demo kit for AWS Transform capabilities (custom runtime upgrades, continuous modernization, ARA, MODA). Works from Kiro or Claude Code. Connects only to an Isengard AWS account and one git repo that holds the bundled sample estate.

## When to use

- A colleague wants to run an end-to-end Transform demo without Shisir in the room.
- Customer demo rehearsal: full assess → transform story on realistic legacy code.
- Resetting the lab between back-to-back demos.

## The flow (what you'll do and why)

Every step has a **why** so the presenter can explain it to the customer. Do not skip explanations — this skill is as much a training tool as a setup tool.

### Step 1 — Preflight (1 min)
Run `bin/preflight.sh` (mac/linux) or `bin\preflight.ps1` (windows). Checks: `git`, `python3`, `atx` CLI, AWS CLI, active AWS identity. **Why:** a failed demo in front of a customer is worse than no demo. Catch missing pieces before the room is watching.

### Step 2 — Interactive setup (3 min)
Run `bin/setup.sh` / `bin\setup.ps1`. It asks:
1. **AWS Isengard profile name** — the sandbox account Transform will run in.
2. **AWS Region** — where `atx ct` server and campaigns live.
3. **Git remote** (optional) — where to push the bundled estate as 21 separate repos. Leave blank for local-only.
4. **Run location** — `local-mac`, `local-win`, or `aws-cloudshell`.
5. **Parallelism** — how many `atx` jobs in flight. Default 3.

Writes `config/lab.env`. **Why:** one file captures every variable the HTML guide will interpolate, so the generated guide is specific to this machine, not generic.

### Step 3 — Estate deploy (5–10 min)
Run `scripts/deploy-estate.sh`. Splits `estate/` into 21 git repos, back-dates commits (1998 → 2024), optionally pushes to the remote from Step 2. **Why:** AWS Transform works one-repo-per-codebase. Back-dated history makes the "20-year-old estate" story believable on screen.

### Step 4 — Generate the demo guide (<1 min)
Run `bin/build-guide.sh`. Converts `guides/src/*.md` into two self-contained HTML files in `guides/build/`:
- `setup-guide.html` — the technical guide (what you just did, with variables filled in)
- `customer-demo.html` — the milestone demo script (separate, for running the demo itself)

Both HTML files have embedded JS: checkbox progress, localStorage persistence, copy-command buttons, variable tooltips. **Why:** the presenter opens one file in a browser, no server needed, progress survives refreshes.

### Step 5 — Run the demo
Open `guides/build/customer-demo.html`. Follow milestones M1 → M7 (one interactive upgrade → non-interactive → parallel → campaign → ARA/MODA on hero repos → portfolio roll-up → drift). Each milestone has a "what the customer sees" line.

### Step 6 — Reset
Run `bin/reset.sh` / `bin\reset.ps1`. Deletes `atx-result-staging-*` branches, clears `atx ct` server state in the account, resets `estate/` to pristine, clears `~/.atx/cache` for this lab only, re-runs preflight. **Why:** back-to-back demos must start from a known-good state. One command, no manual cleanup.

## Guardrails

- Runs only in the Isengard account from Step 2. Scripts refuse to run if the active identity doesn't match.
- Sample estate uses fake credentials (`AKIAIOSFODNN7EXAMPLE`) and `.example` hostnames. Safe to push to any sandbox git.
- Never writes to `main` of transformed repos — results go to `atx-result-staging-*` branches.
- `reset.sh` asks for `yes` confirmation before destroying state.

## File map

```
aws-transform-demo-lab/
├── SKILL.md                this file
├── bin/
│   ├── preflight.sh / .ps1   check deps + AWS identity
│   ├── setup.sh   / .ps1     interactive config → config/lab.env
│   ├── build-guide.sh        md → html with variable interpolation
│   └── reset.sh   / .ps1     back-to-pristine between demos
├── config/
│   ├── lab.env               generated; interpolated into HTML
│   └── lab.env.example       reference
├── estate/                   the 21-codebase Harbourline Mutual estate (bundled)
├── scripts/
│   ├── deploy-estate.sh      split → git repos → optional push
│   ├── run-atx-all.sh        headless parallel transform runs
│   ├── run-ara-moda.sh       ARA + MODA + portfolio roll-up
│   ├── introduce-drift.sh    plant a bad commit for the drift demo
│   └── sync-from-source.sh   one-time pull from aws_transform_capabilities
└── guides/
    ├── src/                  markdown source
    │   ├── setup-guide.md
    │   └── customer-demo.md
    └── build/                generated HTML (git-ignored)
```

## Invocation from Kiro / Claude Code

Users invoke this skill by saying any of:
- "set up the AWS Transform demo lab"
- "run the Transform demo"
- "reset the Transform demo lab"
- "/aws-transform-demo-lab setup|demo|reset"

When invoked:
1. If first time: run Step 1 → Step 4, then open `guides/build/setup-guide.html` and tell the user.
2. If `config/lab.env` exists: ask setup | demo | reset.
3. Always narrate *why* each step matters — the presenter will repeat it to the customer.

## Explanation discipline

Every script prints a one-line **"What this does / Why it matters"** before executing. Every HTML command block has a tooltip explaining every variable and flag. This is deliberate: the skill exists to teach the method, not just run it.
