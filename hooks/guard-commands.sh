#!/bin/bash
# PreToolUse hook on Bash.
#
# Enforces the standing orders that agents drift away from under pressure.
# Exit code 2 blocks the command and returns the stderr message to the agent,
# so it learns why instead of retrying.
#
# Wire it up in .claude/settings.json with an ABSOLUTE path — relative paths
# break because subagents and worktree sessions run from different directories:
#
#   "hooks": { "PreToolUse": [ { "matcher": "Bash", "hooks": [
#     { "type": "command", "command": "/absolute/path/to/guard-commands.sh" } ] } ] }
#
# The lead session (the one you talk to) is exempt from the push and
# default-branch blocks, because those actions ARE the lead's job when you say
# so. Spawned subagents are not. See IS_SUBAGENT below.

INPUT=$(cat)
[ -z "$INPUT" ] && exit 0

# Fail CLOSED, not open. A guard that waves everything through when a dependency
# is missing is invisible until the moment it matters.
if command -v jq >/dev/null 2>&1; then
  CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')
  TRANSCRIPT=$(printf '%s' "$INPUT" | jq -r '.transcript_path // empty')
elif command -v python3 >/dev/null 2>&1; then
  CMD=$(printf '%s' "$INPUT" | python3 -c \
    'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null)
  TRANSCRIPT=$(printf '%s' "$INPUT" | python3 -c \
    'import sys,json; print(json.load(sys.stdin).get("transcript_path",""))' 2>/dev/null)
else
  echo "Blocked: guard-commands.sh needs jq or python3 on PATH and found neither. Install one, or this safety hook cannot inspect commands." >&2
  exit 2
fi

if [ -z "$CMD" ]; then
  echo "Blocked: guard-commands.sh received input it could not parse, so it cannot tell whether this command is safe. Tell the human; do not retry." >&2
  exit 2
fi

# POSITIVE lead detection, fail-closed: treated as the lead ONLY with affirmative
# evidence it is the main session; a subagent in every other case. The dangerous
# mistake is letting a spawned teammate push, so anything unidentified stays blocked.
IS_SUBAGENT=1
case "$TRANSCRIPT" in
  *"/tasks/"*) IS_SUBAGENT=1 ;;
  *"/projects/"*.jsonl) IS_SUBAGENT=0 ;;
  *) IS_SUBAGENT=1 ;;
esac

# 1. Destructive git, everyone. There is no task where an agent needs these.
if printf '%s' "$CMD" | grep -qE 'git[[:space:]]+push[[:space:]]+(--force|-f)([[:space:]]|$)'; then
  echo "Blocked: force-push rewrites history other people have pulled. If you truly need this, a human does it." >&2
  exit 2
fi
if printf '%s' "$CMD" | grep -qE 'git[[:space:]]+reset[[:space:]]+--hard'; then
  echo "Blocked: 'git reset --hard' destroys uncommitted work with no recovery. Use 'git stash' or commit first, or ask the human." >&2
  exit 2
fi

# 2. No pushing — SUBAGENTS ONLY. The lead pushes when the human says so.
if [ "$IS_SUBAGENT" = "1" ]; then
  if printf '%s' "$CMD" | grep -qE '(^|[;&|]|&&)[[:space:]]*git[[:space:]]+([^;&|]*[[:space:]])?push'; then
    cat >&2 <<'MSG'
Blocked: teammates never push. Commit to your own worktree branch, report the
ticket done, and stop. The lead coordinates the landing when the human says to.
MSG
    exit 2
  fi
fi

# 3. No committing onto the default branch — SUBAGENTS ONLY.
#    Checks the branch of the caller's own cwd, so an agent working in its own
#    worktree on its own branch is fine; this catches the accidental
#    "cd main-repo && git commit".
if [ "$IS_SUBAGENT" = "1" ]; then
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ "$BRANCH" = "master" ] || [ "$BRANCH" = "main" ] || [ "$BRANCH" = "develop" ]; then
    if printf '%s' "$CMD" | grep -qE '(^|[;&|]|&&)[[:space:]]*git[[:space:]]+(commit|merge|rebase|reset[[:space:]]+--hard)'; then
      cat >&2 <<MSG
Blocked: you are on '$BRANCH' and you are a spawned teammate. Teammates never
commit to a shared branch. Work in your own git worktree on your own branch.
If you are not in one, stop and tell the lead rather than creating one yourself.
MSG
      exit 2
    fi
  fi
fi

# 4. Production database writes. Read-only inspection is fine; mutation is not.
if printf '%s' "$CMD" | grep -qiE '(psql|sqlcmd|mysql|sqlite3)[^;&|]*(DROP|TRUNCATE|DELETE FROM|UPDATE )'; then
  cat >&2 <<'MSG'
Blocked: this looks like a data-mutating query run from the shell. Mutations to
any shared or production database go through a human, a migration, or the
application — never an ad-hoc agent command. If this targets a local scratch
database, say so to the human and let them run it.
MSG
  exit 2
fi

exit 0
