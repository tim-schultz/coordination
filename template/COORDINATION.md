# Codex–Claude Coordination

<!-- coordination:start -->
## Contract (v4)

This file shows the current state of shared work between Codex and Claude. It
is loaded into every agent's context, so it holds only these rules and one row
per open thread. Thread history lives in separate files. User instructions and
repository rules take precedence.

### Rules

1. **Read before working.** At session start and before claiming or handing
   off work, read this file and the thread file of every thread you touch.
2. **Threads.** Use one thread per task or milestone; a long effort opens a
   new thread for each milestone and closes it at that milestone's RELEASE.
   A thread's ID is its first entry's ID (such as `CLAUDE-20260930-042`). Its
   entries live in `coordination/<ID>.md`, append-only, in the format below.
   Keep an entry to about 10 lines and put long evidence (hash lists, command
   output) in the plan or a separate file.
3. **Rows.** Each open thread has one short row below. The owner keeps it
   current by editing it in place. Anyone who hands work to another agent
   updates the row's Next. Never append entries here.
4. **Claims.** Name the exact files you will edit in a CLAIM entry. One owner
   per file; ask for a handoff before editing another agent's file. Never
   revert another agent's work.
5. **Close.** When nothing remains, the owner appends a CLOSE entry with the
   outcome, deletes the row and moves the file to
   `docs/archive/coordination/<ID>.md`. No closing ACKs are needed. Anyone
   may reopen a thread by moving it back, appending REOPEN and adding a row.
   Ending a session does not close a thread.
6. **Delegates** never write entries; the owning agent posts one entry
   covering its delegates' scopes and results.
7. **Shared files.** Re-read before writing and use targeted edits. Never
   rewrite another agent's entries or rows.

### Finding history

- Open threads: `ls coordination/`
- A thread: `coordination/<ID>.md`, or `docs/archive/coordination/<ID>.md`
  once closed
- Search: `grep -rn "<text>" coordination docs/archive/coordination`

### Entry format

Use UTC timestamps. Entry IDs are `<AGENT>-<YYYYMMDD>-<NNN>`, taking the next
unused number for your agent and date. Types: `OPEN`, `CLAIM`, `UPDATE`,
`QUESTION`, `DECISION`, `REVIEW`, `HANDOFF`, `RELEASE`, `ACK`, `CLOSE`,
`REOPEN`.

```markdown
### <entry ID> | <UTC timestamp> | <TYPE>
- Thread: <thread ID>
- Owner / Participants: <owner> / <participants>
- From / To: <author> / <recipient>
- Task / Reply to: <task; earlier entry ID if replying>
- Scope: <owned or affected files; none for discussion>
- Message: <progress, question, decision or handoff>
- Verification: <commands and results, or not run with reason>
- Next: <responsible agent and concrete action; none when closing>
```
<!-- coordination:end -->

## Open threads

| Thread | Owner | State | Next |
| --- | --- | --- | --- |
