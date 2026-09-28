# Day-one dev environment, Windows. Idempotent.
# Preview:  .\windows.ps1          Install:  .\windows.ps1 -Apply
#
# On a managed machine winget may be restricted. If it is, install from the
# company software portal instead and skip to the "Next" section at the bottom.

param([switch]$Apply)
$ErrorActionPreference = "Stop"
function Have($c) { $null -ne (Get-Command $c -ErrorAction SilentlyContinue) }
function Run($id) {
  if (Have "winget") {
    if ($Apply) { winget install --id $id --silent --accept-package-agreements --accept-source-agreements }
    else { Write-Host "would install: $id" }
  } else { Write-Host "winget unavailable - install $id from the software portal" }
}

if (-not $Apply) { Write-Host "DRY RUN - re-run with -Apply." }

if (-not (Have "git"))  { Run "Git.Git" }        else { Write-Host "have git" }
if (-not (Have "gh"))   { Run "GitHub.cli" }     else { Write-Host "have gh" }
if (-not (Have "node")) { Run "OpenJS.NodeJS.LTS" } else { Write-Host "have node" }
if (-not (Have "rg"))   { Run "BurntSushi.ripgrep.MSVC" } else { Write-Host "have rg" }
if (-not (Have "jq"))   { Run "jqlang.jq" }      else { Write-Host "have jq" }
if (-not (Have "uv"))   { Run "astral-sh.uv" }   else { Write-Host "have uv" }
if (-not (Have "dotnet")) { Write-Host "note: install the .NET SDK matching the product's target framework, not the newest one." }

# WSL2 is worth it: the guard hook, install.sh, and most agent tooling assume a
# POSIX shell. Git Bash covers the hook; WSL covers everything.
if (-not (Have "wsl")) {
  Write-Host "WSL not found. Strongly recommended:  wsl --install -d Ubuntu"
  Write-Host "It needs admin rights and a reboot. If you cannot get them, Git Bash"
  Write-Host "(ships with Git for Windows) is enough to run the guard hook."
}

if (-not (Have "claude")) {
  if ($Apply) { npm install -g @anthropic-ai/claude-code } else { Write-Host "would install: claude-code (npm)" }
}

Write-Host ""
Write-Host "Next:"
Write-Host "  1. gh auth login"
Write-Host "  2. git config --global user.name / user.email"
Write-Host "  3. git config --global core.autocrlf input   # or CRLF churn will fill every diff"
Write-Host "  4. ..\install.ps1 -Apply    (the Claude stack itself)"
