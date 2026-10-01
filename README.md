# agent-coordination

A drop-in contract that lets Claude Code and Codex share work on one project
through files in the repository.

## Setup

Tell Claude or Codex, from inside your project:

> Set up Codex–Claude coordination from https://github.com/OWNER/agent-coordination

### For the agent doing the setup

Run these from the project root, then report what changed:

```sh
git clone --depth 1 https://github.com/OWNER/agent-coordination /tmp/agent-coordination
/tmp/agent-coordination/install.sh .
rm -rf /tmp/agent-coordination
```

The installer is safe to re-run; that is also how you update the rules.

## What it installs

| File | Purpose |
| --- | --- |
| `COORDINATION.md` | The contract and one row per open thread |
| `coordination/<ID>.md` | Append-only entries for each open thread |
| `docs/archive/coordination/` | Closed threads, searchable with grep |
| `CLAUDE.md` block | Imports `COORDINATION.md` with `@`, so Claude always has it loaded |
| `AGENTS.md` block | Tells Codex to read `COORDINATION.md` at session start |

The rules live only in `COORDINATION.md`. The `CLAUDE.md` and `AGENTS.md`
blocks are short pointers, so there is one copy to keep current. Each managed
block sits between `<!-- coordination:start -->` and
`<!-- coordination:end -->`; anything outside the markers, including the
open-threads table, is left alone.

## The rules

The full text is in [template/COORDINATION.md](template/COORDINATION.md).

1. **Read before working.** Read `COORDINATION.md` and every thread file you
   touch at session start and before any claim or handoff.
2. **Threads.** One thread per task or milestone, append-only, entries about
   10 lines. Long evidence goes in the plan or a separate file.
3. **Rows.** The owner edits its row in place; whoever hands off updates Next.
4. **Claims.** Name exact files; one owner per file; never revert others' work.
5. **Close.** Append CLOSE, delete the row, move the file to the archive.
   Ending a session does not close a thread.
6. **Delegates** never write entries; the owner reports for them.
7. **Shared files.** Re-read before writing; targeted edits only.

Entries use `### <AGENT>-<YYYYMMDD>-<NNN> | <UTC> | <TYPE>` with the fields
Thread, Owner / Participants, From / To, Task / Reply to, Scope, Message,
Verification and Next. Types: OPEN, CLAIM, UPDATE, QUESTION, DECISION, REVIEW,
HANDOFF, RELEASE, ACK, CLOSE, REOPEN.

## Development

`./test.sh` installs into fresh and existing temporary projects and checks
that existing content survives, rules update, and re-runs do not duplicate.
