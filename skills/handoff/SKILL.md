---
name: handoff
description: Write an end-of-session handoff — a dated, evidence-dense record of what actually happened, what is unverified, and what the next person or session must decide. Use when the user says "write a handoff", "wrap up", "end of day summary", "what did we do today", or before a session ends with work still in flight.
---

# Handoff

A handoff exists so the next session — or the next person — can act without asking a question. It
is not a summary and it is not a status report to make anyone feel good. Its value is measured by
how little re-derivation it forces.

Write it to `docs/handoffs/YYYY-MM-DD-<subject>.md` in the repo by default. If the team has a
channel or tracker where these belong, post it there too, but the file in the repo is the copy that
survives.

## Before writing

1. **Read the last two handoffs.** Nothing already reported gets reported again, except to correct
   it.
2. **Verify claims against the repo rather than repeating what you remember.** A handoff citing
   `file.cs:214` is worth ten citing "I fixed the thing." Run `git log`, `git diff`, and the tests
   before writing that anything works.
3. **Check the board and any open tickets** for state the conversation did not cover.

## Structure

**Header.** Date, subject in specific terms, branch, and the one-line answer to "did anything
ship?" State it honestly in the first two lines. "Nothing shipped" is a fine opening and is far
better than burying it.

**What changed.** Each item with evidence: file and line, branch name, commit SHA, exact test
counts, exact command output. If you cannot cite it, say you are reporting it from memory.

**What is verified and what is not.** Two separate lists, never merged. For each unverified item,
say what would verify it and why you could not. An unverified thing presented as verified is the
one failure that makes the whole document worthless.

**Decisions made, and why.** Including the ones you made unilaterally. Someone reading this in a
month needs the reason, not just the outcome.

**Open questions and blocked items.** What needs a human, what it is blocked on, and how long it
has been open. **Carry forward unanswered asks from previous handoffs verbatim**, with their age.
An ask that quietly disappears between handoffs is how things get dropped.

**Collision surface.** Which files this work touches and which other in-flight branches sit in the
same place. This is the section that saves the most time and is the one most often skipped.

**Corrections.** When new information contradicts an earlier handoff, say plainly that a
previously reported fix did not close the issue. This is the highest-value part of any handoff and
the easiest to leave out.

**Next.** The two or three concrete things to pick up, in order, each with enough context to start
cold.

## Tone

Write for a peer. Do not soften findings, do not pad with what went well, and do not describe
effort. Nobody reading a handoff cares how hard something was; they care what state the system is
in and what they now have to decide.
