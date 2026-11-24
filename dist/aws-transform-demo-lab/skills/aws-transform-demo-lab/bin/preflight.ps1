# What: windows preflight — same checks as preflight.sh.
# Why:  colleagues on Windows laptops shouldn't need WSL to get past step 1.
$ErrorActionPreference = "Stop"
$lab = Resolve-Path (Join-Path $PSScriptRoot "..")
$envFile = Join-Path $lab "config\lab.env"
$fail = 0
function Ok($m)  { Write-Host "  [ok] $m"  -ForegroundColor Green }
function Bad($m) { Write-Host "  [!!] $m"  -ForegroundColor Red; $script:fail = 1 }

Write-Host "[preflight] Checking required tools" -ForegroundColor Cyan
foreach ($c in @("git","python","aws","atx")) {
  $cmd = Get-Command $c -ErrorAction SilentlyContinue
  if ($cmd) { Ok "$c : $($cmd.Source)" } else { Bad "$c not found" }
}

if (Test-Path $envFile) {
  $env_map = @{}; Get-Content $envFile | ForEach-Object {
    if ($_ -match '^(\w+)=(.*)$') { $env_map[$matches[1]] = $matches[2] }
  }
  Write-Host "[preflight] Checking AWS identity (profile=$($env_map.AWS_PROFILE))" -ForegroundColor Cyan
  try {
    $id = & aws sts get-caller-identity --profile $env_map.AWS_PROFILE --region $env_map.AWS_REGION 2>&1
    Ok $id
  } catch { Bad "aws sts get-caller-identity failed: $_" }
} else {
  Write-Host "[preflight] config/lab.env not found — run bin\setup.ps1 next." -ForegroundColor Yellow
}

if ($fail) { Write-Host "Preflight failed."; exit 1 }
Write-Host "[preflight] OK" -ForegroundColor Green
