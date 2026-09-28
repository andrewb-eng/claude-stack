# Personal Claude Code stack

Everything that makes me fast, in a form that installs onto a new machine in about ten
minutes. Nothing here is specific to a previous employer or client; it is all mine.

## What's in it

```
global/CLAUDE.md              standing instructions — how to write code, how to talk to me
global/settings.template.json permissions deny/allow, model, plugins (MERGE, don't copy)
agents/                       seven specialist reviewers and workers
skills/                       reusable procedures Claude loads on demand
hooks/guard-commands.sh       PreToolUse guard: no subagent pushes, no destructive git, no ad-hoc DB writes
templates/                    CLAUDE.md and AGENTS.md starters for each new repo
bootstrap/                    day-one dev environment, macOS and Windows
install.sh / install.ps1      idempotent installer, dry-run by default
docs/DAY-ONE.md               the order to do things in on a new machine
docs/PORTABILITY.md           what to do if Claude Code isn't the approved tool
```

## Install

```bash
./bootstrap/macos.sh          # preview the dev environment
./bootstrap/macos.sh --apply
./install.sh                  # preview the Claude stack
./install.sh --apply
```

Windows: `.\bootstrap\windows.ps1 -Apply` then `.\install.ps1 -Apply`.

Both are idempotent and dry-run by default. Neither writes `settings.json` — that merge is
manual on purpose, because blowing away an existing settings file is the one mistake that
is annoying to undo.

## The agents

| Agent | Use it when | Edits? |
|---|---|---|
| `code-quality-pragmatist` | after implementing, before review — catches over-engineering | no |
| `ultrathink-debugger` | a bug resists a quick fix, is intermittent, or is environment-specific | yes |
| `karen` | something is marked done and you are not sure it is | no |
| `security-compliance-reviewer` | anything touching credentials, customer data, or a third-party API | no |
| `financial-data-auditor` | before any computed money figure reaches a person or the ledger | no |
| `skeptic` | a review produced a list of claimed problems and someone must decide which are real | no |
| `release-captain` | finished work needs to land green on the default branch | yes |

Five of the seven are read-only by design. A reviewer that edits hides the problems you
called it for.

The reviewers exist because the agent that wrote the code is the worst judge of whether it is
broken, and the agent that found a bug is the worst judge of whether it is real.

## The skills

- **`team`** — become the lead of a multi-agent run: tickets, worktrees, plan approval, triage.
- **`handoff`** — an evidence-dense end-of-session record, so the next session starts cold without asking.
- **`codebase-onboarding`** — analyze an unfamiliar repo and generate its architecture map and starter `CLAUDE.md`. This is the first thing to run on a new codebase.
- **`context-budget`** — audit what is eating the context window across agents, skills, and MCP servers.

## Per-repo setup

For each repo you work in:

1. `cp templates/CLAUDE.md.template <repo>/CLAUDE.md` and fill it in. Run the
   `codebase-onboarding` skill first if the repo is new to you; it drafts most of it.
2. If other agent tools are in use on the team, add `AGENTS.md` from the template too, and
   keep the two in sync. Contradictory instruction files are worse than one.
3. Wire the hook in `<repo>/.claude/settings.json` with an **absolute** path:

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{ "type": "command", "command": "/absolute/path/to/.claude/hooks/guard-commands.sh" }]
    }]
  }
}
```

Relative paths break, because subagents and worktree sessions run from different directories.

## Maintaining this

The `CLAUDE.md` in each repo earns entries by being violated. Do not write down a convention
nobody has broken; write down the thing that cost a cycle. Same for the gotchas section — every
entry should be traceable to a specific afternoon it wasted.

When an agent produces bad output twice in the same way, that is a prompt bug, not a model
problem. Fix the role file.
