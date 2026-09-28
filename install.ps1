# Personal Claude Code stack installer (Windows PowerShell). Idempotent.
#
#   .\install.ps1            preview what would change (default)
#   .\install.ps1 -Apply     actually copy files
#
# Never touches settings.json. That merge is manual and deliberate; see README.

param([switch]$Apply)

$ErrorActionPreference = "Stop"
$Src  = Split-Path -Parent $MyInvocation.MyCommand.Path
$Dest = if ($env:CLAUDE_HOME) { $env:CLAUDE_HOME } else { Join-Path $env:USERPROFILE ".claude" }

function Step($m) { Write-Host "`n$m" -ForegroundColor White }

if (-not $Apply) { Write-Host "DRY RUN - nothing will be written. Re-run with -Apply to install." }
Write-Host "Source: $Src"
Write-Host "Target: $Dest"

function Copy-One($srcFile, $target, $label) {
  if (Test-Path $target) {
    if ((Get-FileHash $srcFile).Hash -eq (Get-FileHash $target).Hash) {
      Write-Host "  SAME    $label"; return
    }
    Write-Host "  MODIFY  $label (existing file differs - backed up to $label.bak)"
    if ($Apply) { Copy-Item $target "$target.bak" -Force }
  } else {
    Write-Host "  ADD     $label"
  }
  if ($Apply) { Copy-Item $srcFile $target -Force }
}

Step "1. Agents -> $Dest\agents\"
if ($Apply) { New-Item -ItemType Directory -Force -Path "$Dest\agents" | Out-Null }
Get-ChildItem "$Src\agents\*.md" -ErrorAction SilentlyContinue | ForEach-Object {
  Copy-One $_.FullName (Join-Path "$Dest\agents" $_.Name) $_.Name
}

Step "2. Skills -> $Dest\skills\"
if ($Apply) { New-Item -ItemType Directory -Force -Path "$Dest\skills" | Out-Null }
Get-ChildItem "$Src\skills" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
  $t = Join-Path "$Dest\skills" $_.Name
  if (Test-Path $t) { Write-Host "  MERGE   $($_.Name)\ (files overwritten, extras left alone)" }
  else { Write-Host "  ADD     $($_.Name)\" }
  if ($Apply) {
    New-Item -ItemType Directory -Force -Path $t | Out-Null
    Copy-Item "$($_.FullName)\*" $t -Recurse -Force
  }
}

Step "3. Hooks -> $Dest\hooks\"
Write-Host "  NOTE    The guard hook is a bash script. It runs under Git Bash or WSL."
Write-Host "          On native Windows without either, skip it and rely on the"
Write-Host "          settings.json deny list instead."
if ($Apply) { New-Item -ItemType Directory -Force -Path "$Dest\hooks" | Out-Null }
Get-ChildItem "$Src\hooks\*.sh" -ErrorAction SilentlyContinue | ForEach-Object {
  Copy-One $_.FullName (Join-Path "$Dest\hooks" $_.Name) $_.Name
}

Step "4. Global CLAUDE.md -> $Dest\CLAUDE.md"
if (Test-Path "$Dest\CLAUDE.md") {
  Write-Host "  SKIP    CLAUDE.md already exists. Merge by hand - the installer will not"
  Write-Host "          overwrite your standing instructions."
} else {
  Write-Host "  ADD     CLAUDE.md"
  if ($Apply) { Copy-Item "$Src\global\CLAUDE.md" "$Dest\CLAUDE.md" -Force }
}

Step "5. settings.json - MANUAL"
Write-Host "  Not touched by design. Merge the keys you want from:"
Write-Host "    $Src\global\settings.template.json"
Write-Host "  Replace YOURNAME in every deny path, and change the //Users/ prefixes to"
Write-Host "  //C:/Users/ for Windows paths."

Step "Done."
if (-not $Apply) { Write-Host "This was a dry run. Re-run with -Apply." }
