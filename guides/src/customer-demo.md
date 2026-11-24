# AWS Transform — Customer Demo Script

Milestone-based 45–60 minute demo. Check each box as you finish; progress survives refresh. Every command block has a **caption** explaining what it does, and every variable has a tooltip explaining what to use when.

## The story you're telling

Enterprises spend ~30% of engineering capacity on dependency and runtime toil. AWS Transform now covers the full **migrate → modernize → continuously modernize** lifecycle. You'll show two halves:

1. **Assess** — find what's out of date, insecure or not safe for AI agents, and decide what to fix first.
2. **Transform** — fix it at scale, from one interactive run to parallel campaigns.

Keep saying the line: *migration gets you there, modernization makes it work, AI is what makes it matter.*

## Pre-demo (2 min before customer arrives)

### M0 — Sanity check

```bash :: preflight + build + open the guide; takes ~15 seconds
bash {{LAB_ROOT}}/bin/preflight.sh && bash {{LAB_ROOT}}/bin/build-guide.sh && open {{LAB_ROOT}}/guides/build/customer-demo.html
```

Why: no surprises on screen. If preflight fails, don't start the demo.

## Part 1 — Assess (20 min)

### M1 — Open the estate and name the problem

```bash :: list the 21-codebase Harbourline Mutual estate
ls -1 {{WORKSPACE}}
```

**What the customer sees:** 21 repos, built between 1998 and 2024, in 20 languages, from one fictional Australian mutual bank. Looks like their own estate.

Say: *"This is what the agent will assess. Same variety you have — COBOL, VB.NET, AngularJS, Python 2, modern Spring Boot. We'll look at it the way AWS Transform does."*

### M2 — ARA on one hero repo

```bash :: Agentic Readiness Analysis on the loan service — 65 planted ARA findings across the estate
cd {{WORKSPACE}}/loan-service-java && AWS_PROFILE={{AWS_PROFILE}} atx custom def exec -p . -n AWS/agentic-readiness-analysis -f .transform/ara.yaml
```

**What the customer sees:** a readiness verdict (Agent-Ready / Pilot-Ready / Remediation Required / Not Agent-Integrable) with specific AUTH/ENG findings. Point at the evidence strings — exact file + line.

Say: *"ARA asks: can an AI agent safely act on this system? It checks identity, idempotency, audit trail, human-in-the-loop. Not opinion — evidence."*

### M3 — MODA on a different hero repo

```bash :: Modernization Readiness Analysis on a .NET Framework WCF service
cd {{WORKSPACE}}/payments-wcf-dotnet && AWS_PROFILE={{AWS_PROFILE}} atx custom def exec -p . -n AWS/modernization-readiness-analysis -f .transform/moda.yaml
```

**What the customer sees:** infra, app, data, security and ops gaps mapped to AWS modernization pathways. No overlap with ARA questions.

Say: *"MODA asks a different question: what does it take to modernize this to run well on AWS? These two analyses stack — MODA findings often explain ARA findings."*

### M4 — Portfolio roll-up

```bash :: ARA + MODA across all 21 codebases in parallel, then portfolio recipe
PARALLELISM={{PARALLELISM}} bash {{LAB_ROOT}}/scripts/run-ara-moda.sh
```

**What the customer sees:** a portfolio scorecard: 1 Agent-Ready, 2 Pilot-Ready, 6 Remediation Required, 12 Not Agent-Integrable, 1 not analysed (the COTS). Systemic patterns: secrets in 14+ repos, no machine identity, no idempotency, EOL SDKs.

Say: *"This is the picture a CTO wants: not 21 reports, one roadmap. Phase 1 blockers in weeks 0-6. Phase 2 safety in weeks 6-12. Phase 3 modernisation over quarters — that's where Transform campaigns come in."*

## Part 2 — Transform (20 min)

### M5 — Interactive upgrade of one Lambda

```bash :: interactive Python 3.8 -> 3.13 on App1 with plan review
cd {{WORKSPACE}}/App1_python3.8 && AWS_PROFILE={{AWS_PROFILE}} atx -t
```

**What the customer sees:** the agent reads the code, explains its plan, waits for approval, then edits. Tests pass on the new runtime where they failed before (`distutils` removal, `datetime.utcnow()`, `typing.Dict`).

Say: *"You'd use this for the first run in a new repo — the engineer stays in the loop. After it works, you turn off the human."*

### M6 — Parallel headless across all six apps

```bash :: same transformation, no human, six apps in flight, results to CSV
PARALLELISM={{PARALLELISM}} bash {{LAB_ROOT}}/scripts/run-atx-all.sh && cat {{LAB_ROOT}}/guides/build/atx-results.csv
```

**What the customer sees:** a CSV of app, status, duration, result branch. Each branch is `atx-result-staging-*` — review and PR, never `main`.

Say: *"This is how you clear a backlog. Six apps here. In a customer environment it's hundreds, running on a schedule or on every commit."*

### M7 — Campaign and custom transformation (optional, 5 min)

```bash :: run the same transformation under a campaign id from the AWS Transform web app
CAMPAIGN_ID={{CAMPAIGN_ID}} PARALLELISM={{PARALLELISM}} bash {{LAB_ROOT}}/scripts/run-atx-all.sh
```

If `CAMPAIGN_ID` is orange, create a campaign in the Transform web app first and fill it into `config/lab.env`.

Say: *"A campaign is how your platform team tracks one transformation across hundreds of repos on a dashboard. Same command, one extra flag."*

## Part 3 — Continuous modernization (10 min)

### M8 — Baseline a clean repo, then drift it

```bash :: baseline analysis on onboarding-api (our one modern "control" repo)
cd {{WORKSPACE}}/onboarding-api && AWS_PROFILE={{AWS_PROFILE}} atx custom def exec -p . -n AWS/agentic-readiness-analysis -f .transform/ara.yaml
```

```bash :: plant a bad commit (Text4Shell + hardcoded key + unsafe DELETE)
bash {{LAB_ROOT}}/scripts/introduce-drift.sh
```

```bash :: re-run — the agent catches the new findings on a previously clean repo
cd {{WORKSPACE}}/onboarding-api && AWS_PROFILE={{AWS_PROFILE}} atx custom def exec -p . -n AWS/agentic-readiness-analysis -f .transform/ara.yaml
```

**What the customer sees:** same repo, three new High findings that weren't there yesterday. All from one commit. Narrate: *"Continuous modernization means every PR gets this check. AI-assisted code gets reviewed by AI. That's how you keep the roadmap from undoing itself."*

## Wrap (5 min)

### M9 — Recap and ask

Three sentences:
1. "We assessed 21 systems in minutes; you have a roadmap, not a pile of reports."
2. "We transformed six Lambdas in parallel; the same mechanism scales to your estate."
3. "Continuous modernization keeps the roadmap honest on every commit."

Ask: *"Which five repos do you want us to run this on next week?"* That's the funded-pilot ask.

### M10 — Reset the lab

```bash :: wipe staging branches, reset repos to back-dated initial commit, clear atx ct state
bash {{LAB_ROOT}}/bin/reset.sh
```

Ready for the next customer.
