# What: windows reset — delegates to WSL/git for the heavy lifting where possible.
$lab = Resolve-Path (Join-Path $PSScriptRoot "..")
$envFile = Join-Path $lab "config\lab.env"
if (-not (Test-Path $envFile)) { Write-Error "config/lab.env missing — run bin\setup.ps1"; exit 1 }
$env_map = @{}; Get-Content $envFile | ForEach-Object { if ($_ -match '^(\w+)=(.*)$') { $env_map[$matches[1]] = $matches[2] } }
Write-Host "This will reset $($env_map.WORKSPACE) and delete guides\build\*.html"
$ans = Read-Host "Type 'yes' to proceed"
if ($ans -ne "yes") { Write-Host "aborted."; exit 0 }
if (Test-Path $env_map.WORKSPACE) {
  Get-ChildItem $env_map.WORKSPACE -Directory | ForEach-Object {
    if (Test-Path (Join-Path $_.FullName ".git")) {
      Push-Location $_.FullName
      git branch | Select-String "atx-result-staging-" | ForEach-Object { git branch -D ($_.ToString().Trim()) 2>$null }
      $first = (git rev-list --max-parents=0 HEAD | Select-Object -Last 1)
      git reset --hard $first | Out-Null
      git clean -fdx | Out-Null
      Pop-Location
      Write-Host "  reset $($_.Name)"
    }
  }
}
Remove-Item -Force (Join-Path $lab "guides\build\*.html") -ErrorAction SilentlyContinue
Write-Host "Reset complete."
