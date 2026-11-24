# Install

## One-liner (from the hosted repo)

```bash
# macOS / Linux / WSL
git clone https://github.com/<org>/aws-transform-demo-lab.git && \
  bash aws-transform-demo-lab/install.sh
```

```powershell
# Windows
git clone https://github.com/<org>/aws-transform-demo-lab.git
cd aws-transform-demo-lab
.\install.ps1
```

Installs to **both** `~/.claude/skills/aws-transform-demo-lab` and `~/.kiro/skills/aws-transform-demo-lab` by default.

## Install into one host only

```bash
bash install.sh --claude-code   # Claude Code only
bash install.sh --kiro          # Kiro only
```

```powershell
.\install.ps1 -ClaudeCode
.\install.ps1 -Kiro
```

## Custom locations

Set before running the installer:

```bash
CLAUDE_SKILLS_DIR=/opt/skills/claude KIRO_SKILLS_DIR=/opt/skills/kiro bash install.sh
```

## Verify

Open Kiro or Claude Code and say: **"set up the AWS Transform demo lab"**.

The agent reads `SKILL.md` and walks you through preflight → setup → estate deploy → build guide.

## Uninstall

```bash
rm -rf ~/.claude/skills/aws-transform-demo-lab ~/.kiro/skills/aws-transform-demo-lab
```

## Update

Re-run the installer from a fresh `git pull`. It prompts before overwriting and preserves nothing locally — your `config/lab.env` stays untouched (installer excludes it).
