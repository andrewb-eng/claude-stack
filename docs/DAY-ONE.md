# Day one on a new machine

In order. Each step assumes the one before it.

## Before you install anything

**Find out what is actually allowed.** This is not paranoia, it is the step that decides
whether the rest of this document applies. Ask, in writing, and keep the answer:

1. Is Claude Code approved for use against company source? Under what account — a company
   seat or a personal one? These have different data-retention terms and it matters.
2. Which repositories and which data may it see? Is production data off limits by policy
   or only by convention?
3. Is there an approved-tools list, and is anything on it that I should use instead of or
   alongside this?
4. Who signs off if I want to add a tool?

If the answer to (1) is no or "let me check," stop and read `PORTABILITY.md`. Do not install
and ask forgiveness. In a company whose customers get audited, the tooling you use on their
data is not a personal preference.

## Then, in order

**1. Dev environment.** `./bootstrap/macos.sh --apply` or `.\bootstrap\windows.ps1 -Apply`.
On Windows, set `core.autocrlf input` before you clone anything, or line-ending churn will
fill every diff you ever produce.

**2. Auth.** `gh auth login`, git identity, and whatever internal package registry or VPN
the team uses. Do this before the stack install so the first real command works.

**3. The stack.** `./install.sh` to preview, then `--apply`. Then merge
`global/settings.template.json` into `~/.claude/settings.json` by hand and replace every
`YOURNAME`.

**4. Verify the guard hook fires.** Do not assume. Wire it into a scratch repo, then have
Claude try `git reset --hard` and confirm it is blocked. A safety hook you never tested is
a safety hook you do not have.

**5. Clone the main repo and run `codebase-onboarding` on it.** Before you read a single
file yourself. It produces the architecture map and a draft `CLAUDE.md`, and the draft is
what you correct over the first two weeks rather than something you write from a blank page.

**6. Write down what you don't understand.** A `docs/questions.md` you add to daily for the
first month. Most of it answers itself; the rest is the list you take to your manager, and
it is far more credible than asking each question the moment it occurs to you.

## First-week discipline

**Do not automate anything in week one.** You do not yet know which manual steps exist
because nobody got to them and which exist because a controller insisted. Automating the
second kind is how a new hire creates an audit finding.

**Find the system of record for every number before you compute one.** In an ERP company
there is always a screen or report that is authoritative. Your output gets reconciled against
it, every time, or it does not go out.

**Ask what a closed period means here, and what happens if something posts to one.** Ask
before you need to know.

**Learn the deploy and release path before you write code that needs it.** Who lands, when,
what gates exist. `release-captain` is useless until you can tell it what CI actually runs
on, and CI configuration is the single most commonly wrong assumption in a new repo.
