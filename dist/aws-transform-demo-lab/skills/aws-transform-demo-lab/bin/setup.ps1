# What: windows interactive setup — mirror of setup.sh.
# Why:  single source of config for the generated HTML guides on Windows demos.
$lab = Resolve-Path (Join-Path $PSScriptRoot "..")
$envFile = Join-Path $lab "config\lab.env"
function Ask($prompt, $default="") {
  $p = if ($default) { "$prompt [$default]" } else { $prompt }
  $a = Read-Host $p
  if (-not $a) { return $default } else { return $a }
}
Write-Host "AWS Transform Demo Lab - setup"
$AWS_PROFILE  = Ask "Isengard AWS profile"
$AWS_REGION   = Ask "AWS Region" "us-west-2"
$GIT_REMOTE   = Ask "Git remote for estate (blank = local only)"
$RUN_LOCATION = Ask "Run location (local-mac|local-win|aws-cloudshell)" "local-win"
$PARALLELISM  = Ask "Parallel atx jobs" "3"
$WORKSPACE    = Ask "Workspace dir" "$HOME\atx-demo-workspace"

$content = @"
AWS_PROFILE=$AWS_PROFILE
AWS_REGION=$AWS_REGION
GIT_REMOTE=$GIT_REMOTE
RUN_LOCATION=$RUN_LOCATION
PARALLELISM=$PARALLELISM
LAB_ROOT=$lab
WORKSPACE=$WORKSPACE
CAMPAIGN_ID=
"@
Set-Content -Path $envFile -Value $content -Encoding utf8
Write-Host "Wrote $envFile"
Write-Host "Next: bin\preflight.ps1  then  scripts\deploy-estate.sh (WSL) or run locally, then bin\build-guide.sh"
