#!/usr/bin/env bash
# Personal Claude Code stack installer. Idempotent — safe to re-run.
#
#   ./install.sh            preview what would change (default)
#   ./install.sh --apply    actually copy files
#
# Never touches settings.json. That merge is manual and deliberate; see README.

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${CLAUDE_HOME:-$HOME/.claude}"
APPLY=false
[[ "${1:-}" == "--apply" ]] && APPLY=true

say()  { printf '%s\n' "$*"; }
step() { printf '\n\033[1m%s\033[0m\n' "$*"; }

if ! $APPLY; then
  say "DRY RUN — nothing will be written. Re-run with --apply to install."
fi
say "Source: $SRC"
say "Target: $DEST"

copy_file() {
  local src="$1" target="$2" label="$3"
  if [[ -f "$target" ]] && ! cmp -s "$src" "$target"; then
    say "  MODIFY  $label (existing file differs — backed up to $(basename "$target").bak)"
    $APPLY && cp "$target" "$target.bak"
  elif [[ -f "$target" ]]; then
    say "  SAME    $label"
    return 0
  else
    say "  ADD     $label"
  fi
  $APPLY && cp "$src" "$target"
  return 0
}

step "1. Agents -> $DEST/agents/"
$APPLY && mkdir -p "$DEST/agents"
for f in "$SRC"/agents/*.md; do
  [[ -e "$f" ]] || continue
  copy_file "$f" "$DEST/agents/$(basename "$f")" "$(basename "$f")"
done

step "2. Skills -> $DEST/skills/"
$APPLY && mkdir -p "$DEST/skills"
for d in "$SRC"/skills/*/; do
  [[ -d "$d" ]] || continue
  name="$(basename "$d")"
  if [[ -d "$DEST/skills/$name" ]]; then
    say "  MERGE   $name/ (existing directory — files overwritten, extras left alone)"
  else
    say "  ADD     $name/"
  fi
  if $APPLY; then
    mkdir -p "$DEST/skills/$name"
    cp -R "$d." "$DEST/skills/$name/"
  fi
done

step "3. Hooks -> $DEST/hooks/"
$APPLY && mkdir -p "$DEST/hooks"
for f in "$SRC"/hooks/*.sh; do
  [[ -e "$f" ]] || continue
  copy_file "$f" "$DEST/hooks/$(basename "$f")" "$(basename "$f")"
  $APPLY && chmod +x "$DEST/hooks/$(basename "$f")"
done

step "4. Global CLAUDE.md -> $DEST/CLAUDE.md"
if [[ -f "$DEST/CLAUDE.md" ]]; then
  say "  SKIP    CLAUDE.md already exists. Merge by hand — this file is yours and the"
  say "          installer will not overwrite your standing instructions."
  say "          Compare:  diff \"$DEST/CLAUDE.md\" \"$SRC/global/CLAUDE.md\""
else
  say "  ADD     CLAUDE.md"
  $APPLY && cp "$SRC/global/CLAUDE.md" "$DEST/CLAUDE.md"
fi

step "5. settings.json — MANUAL"
say "  Not touched by design. Open both and merge the keys you want:"
say "    $SRC/global/settings.template.json"
say "    $DEST/settings.json"
say "  Replace YOURNAME in every deny path with: $(basename "$HOME")"

step "Done."
if ! $APPLY; then
  say "This was a dry run. Re-run with --apply."
else
  say "Installed. Remaining manual steps:"
  say "  1. Merge settings.json (step 5 above)."
  say "  2. Wire the hook in a project's .claude/settings.json with an ABSOLUTE path:"
  say "     $DEST/hooks/guard-commands.sh"
  say "  3. Copy templates/CLAUDE.md.template into each new repo and fill it in."
fi
