# AWS Transform Demo Lab — Setup Guide

Read-once walkthrough of everything the setup scripts just did and why each piece matters. Open this before the customer walks in.

## Why this exists

A credible Transform demo needs: a legacy estate that looks real, an Isengard account that won't surprise finance, repeatable steps that don't drift, and an explanation for every command. This lab gives you all four from one folder on disk.

## What's connected to what

- **Your machine** runs the `atx` CLI and the HTML guides.
- **Your Isengard account** (profile `{{AWS_PROFILE}}` in `{{AWS_REGION}}`) is where Transform executes.
- **Your git remote** (`{{GIT_REMOTE}}`) holds the 21 split-out codebases of the Harbourline Mutual estate.
- Nothing else is touched. No production, no customer data.

## Preparation checklist

### Step 1 — Verify tooling

```bash :: preflight: git / python / aws / atx + active AWS identity
bash {{LAB_ROOT}}/bin/preflight.sh
```

Why: a missing `atx` CLI in front of a customer is a 10-minute recovery. Catch it now.

### Step 2 — Confirm config

```bash :: inspect the config the HTML guides are built from
cat {{LAB_ROOT}}/config/lab.env
```

Variables in the command blocks below are rendered from this file. Green = set, orange = missing — re-run `bin/setup.sh` if anything is orange.

### Step 3 — Deploy the estate

```bash :: split estate/ into 21 git repos with back-dated commits (1998-2024)
bash {{LAB_ROOT}}/scripts/deploy-estate.sh
```

Why: AWS Transform works one-repo-per-codebase; back-dated history makes the "20-year-old bank" story believable on screen. If `GIT_REMOTE` is set, each repo is pushed.

### Step 4 — Confirm the estate

```bash :: list deployed repos
ls -1 {{WORKSPACE}}
```

You should see 21 directories plus the six `App*` custom-transform apps. If not, re-run step 3.

### Step 5 — Build the guides

```bash :: regenerate setup-guide.html and customer-demo.html from markdown
bash {{LAB_ROOT}}/bin/build-guide.sh
```

The customer-demo.html is the one you run during the demo. This file (setup-guide.html) is for your eyes only.

## Package and environment notes

- `atx` CLI: install via `brew install awslabs/atx/atx` (mac) or the MSI (win). Required for every step.
- `aws` CLI v2: used only to verify identity; `atx` manages its own auth.
- `python3` 3.10+: used by the guide builder. No other python deps.
- `git` 2.30+: back-dated commits need the `--date` support.
- Node and old Python runtimes: **not required on your machine** — the `custom/` apps build inside the Transform agent's environment, not yours.

## Why each piece exists

- **estate/** is bundled, not cloned: colleagues in isolated networks can run the lab without reaching your source repo.
- **config/lab.env** is 600-mode: it names the account Transform runs against; don't share the file.
- **guides/build/** is git-ignored: generated artifacts never land in a PR by accident.
- **scripts/** are thin wrappers around `atx` with a one-line why: every script prints its purpose before acting, so a presenter watching their screen can narrate to the customer.

## Safety rails

- Scripts refuse to run if `aws sts get-caller-identity` returns a non-Isengard account.
- Sample credentials are the AWS-provided example string (`AKIAIOSFODNN7EXAMPLE`); hostnames are `.example` / `.local`.
- Transform results land on `atx-result-staging-*` branches, never on `main`.
- `bin/reset.sh` asks for `yes` before destroying state.

## When the demo is over

```bash :: reset all repos, clear atx ct state in the account, remove built HTML
bash {{LAB_ROOT}}/bin/reset.sh
```

Then re-run `scripts/deploy-estate.sh` and `bin/build-guide.sh` before the next demo.
