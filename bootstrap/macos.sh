#!/usr/bin/env bash
# Day-one dev environment, macOS. Idempotent — safe to re-run.
# Preview:  ./macos.sh          Install:  ./macos.sh --apply
set -euo pipefail
APPLY=false; [[ "${1:-}" == "--apply" ]] && APPLY=true
run() { if $APPLY; then echo "+ $*"; "$@"; else echo "would run: $*"; fi; }
have() { command -v "$1" >/dev/null 2>&1; }

$APPLY || echo "DRY RUN — re-run with --apply."

# Xcode CLT gives you git, clang, make. Everything else assumes it.
have git || run xcode-select --install

if ! have brew; then
  echo "Homebrew is missing. On a managed Mac it may be blocked or already installed"
  echo "to a non-default prefix. Install it yourself before continuing:"
  echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  exit 1
fi

# The set that earns its place: everything here gets used weekly.
PKGS=(
  git gh          # version control + PR/CI from the terminal
  jq              # required by the guard hook
  ripgrep fd      # search that does not make you wait
  node            # Claude Code, tooling
  uv              # python versions + venvs, fast
  bat             # readable file previews
)
for p in "${PKGS[@]}"; do
  if brew list --formula "$p" >/dev/null 2>&1; then echo "have $p"; else run brew install "$p"; fi
done

# Claude Code
have claude || run npm install -g @anthropic-ai/claude-code

# .NET, if you will be building against an ERP that runs on it. Comment out if not.
have dotnet || echo "note: dotnet not found. Install the SDK matching the product's target framework, not the newest one."

echo
echo "Next:"
echo "  1. gh auth login"
echo "  2. git config --global user.name / user.email"
echo "  3. ../install.sh --apply    (the Claude stack itself)"
