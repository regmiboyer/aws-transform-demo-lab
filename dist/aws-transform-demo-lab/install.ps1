# What: windows installer; mirror of install.sh.
# Usage: .\install.ps1 [-ClaudeCode] [-Kiro]   (default: both)
param([switch]$ClaudeCode, [switch]$Kiro)
$ErrorActionPreference = "Stop"
$src  = $PSScriptRoot
$name = "aws-transform-demo-lab"
$claude = if ($env:CLAUDE_SKILLS_DIR) { $env:CLAUDE_SKILLS_DIR } else { "$HOME\.claude\skills" }
$kiro   = if ($env:KIRO_SKILLS_DIR)   { $env:KIRO_SKILLS_DIR }   else { "$HOME\.kiro\skills" }
if (-not $ClaudeCode -and -not $Kiro) { $ClaudeCode = $true; $Kiro = $true }

function Install-To($dest, $label) {
  New-Item -ItemType Directory -Force -Path $dest | Out-Null
  $target = Join-Path $dest $name
  if (Test-Path $target) {
    $a = Read-Host "  $target exists. Overwrite? [y/N]"
    if ($a -ne "y" -and $a -ne "Y") { Write-Host "  skipped $label"; return }
    Remove-Item -Recurse -Force $target
  }
  Copy-Item -Recurse -Path $src -Destination $target
  Remove-Item -Force -ErrorAction SilentlyContinue (Join-Path $target "config\lab.env")
  Remove-Item -Recurse -Force -ErrorAction SilentlyContinue (Join-Path $target "guides\build")
  Remove-Item -Recurse -Force -ErrorAction SilentlyContinue (Join-Path $target ".git")
  Write-Host "  [ok] installed to $target  ($label)" -ForegroundColor Green
}

if ($ClaudeCode) { Install-To $claude "Claude Code" }
if ($Kiro)       { Install-To $kiro   "Kiro" }
Write-Host ""
Write-Host "Invoke from Kiro or Claude Code: `"set up the AWS Transform demo lab`""
