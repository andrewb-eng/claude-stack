# If Claude Code isn't the approved tool

Most of this stack is markdown. That is deliberate — the tooling is the part most likely to
be decided by someone else, so as little as possible depends on it.

## What survives a tool change

**Everything in `agents/`.** These are system prompts. They work as Copilot custom chat modes,
Cursor rules, Codex `AGENTS.md` sections, or pasted into a chat window. The value is the
content, not the format.

**Everything in `skills/`.** Same. A skill is a procedure written down; the loading mechanism
is incidental.

**`global/CLAUDE.md`.** Rename it and it is a Cursor `.cursorrules`, a Copilot
`copilot-instructions.md`, or an `AGENTS.md`. Same words.

**`templates/`.** Per-repo instructions are a convention every tool has adopted, under
different filenames.

## What does not survive

- `settings.template.json` — Claude Code specific. The *intent* (deny reads of credential
  paths, deny destructive bash) translates to other tools' allowlists, but the syntax does not.
- `hooks/guard-commands.sh` — depends on Claude Code's PreToolUse hook contract and its
  transcript-path convention for distinguishing lead from subagent. Nothing else has this.
- The `team` skill's mechanics — the Agent/SendMessage/Task tools are Claude Code's. The
  *operating rules* in it (ticket quality, one writer per worktree, spawn before you reply,
  the reviewer/promoter separation) are tool-independent and worth keeping.

## Mapping to the likely alternatives

**GitHub Copilot** (most likely at a Microsoft-stack company). Put `global/CLAUDE.md` at
`.github/copilot-instructions.md`. Each agent becomes a custom chat mode file under
`.github/chatmodes/`. There is no subagent orchestration, so the `team` skill becomes a
manual checklist: you play the lead, you invoke each reviewer yourself, you do the triage.

**Cursor.** `global/CLAUDE.md` → `.cursor/rules/`. Agents map to rules with `description`
frontmatter so they load contextually.

**Codex / anything reading `AGENTS.md`.** `templates/AGENTS.md.template` is already there for
this. Keep it in sync with `CLAUDE.md` or make one a pointer to the other. Never let them
disagree — whichever tool reads the stale one will be confidently wrong.

**Nothing approved at all.** The agents are still a review checklist, and a good one. Run
`security-compliance-reviewer` and `financial-data-auditor` on yourself before every PR. The
discipline is most of the value; the automation is a speed multiplier on top of it.

## The rule

Do not rebuild this stack around whatever tool is approved on day one. Approvals change, and
the migration cost should stay near zero. Keep the substance in markdown, keep the
tool-specific glue thin and clearly separated, and the next switch costs an afternoon.
