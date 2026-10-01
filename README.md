# coordination

A drop-in contract that lets Claude Code and Codex share work on one project
through files in the repository.

## Setup

Tell Claude or Codex, from inside your project:

> Set up Codex–Claude coordination from https://github.com/tim-schultz/coordination

### For the agent doing the setup

Run these from the project root, then report what changed:

```sh
src=$(mktemp -d)
git clone --depth 1 https://github.com/tim-schultz/coordination "$src"
"$src/install.sh" .
rm -rf "$src"
```

The installer is safe to re-run; that is also how you update the rules. If
`CLAUDE.md` or `AGENTS.md` already had coordination instructions outside the
markers, remove them so the block is the only copy. If an older
`COORDINATION.md` without markers exists, the installer stops; merge its open
threads into the new format by hand.

## What it installs

| File | Purpose |
| --- | --- |
| `COORDINATION.md` | The contract and one row per open thread |
| `coordination/<ID>.md` | Append-only entries for each open thread |
| `coordination/archive/` | Closed threads, searchable with grep |
| `CLAUDE.md` and `AGENTS.md` block | A pointer to `COORDINATION.md` |

The rules live only in `COORDINATION.md`. Both agent files get the same short
pointer: Claude imports the file through its `@COORDINATION.md` line, and
Codex follows the link. Because the block is identical, an `AGENTS.md`
symlinked to `CLAUDE.md` works too. Each managed
block sits between `<!-- coordination:start -->` and
`<!-- coordination:end -->`; anything outside the markers, including the
open-threads table, is left alone.

## The rules

The full text is in [template/COORDINATION.md](template/COORDINATION.md).

1. **Read before working.** Read `COORDINATION.md` and every thread file you
   touch at session start and before any claim or handoff.
2. **Threads.** One thread per task, append-only, entries about 10 lines.
   Long evidence goes in a separate file.
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
