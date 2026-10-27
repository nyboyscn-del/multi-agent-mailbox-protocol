# Partitioned Document Mailbox — Layout

Use this layout when the only surface shared by two agents is a single document.

```
01_PENDING
  Tasks waiting to be claimed. Each task is one block:
  [SubtaskID] [QUEUED] <one-line summary>
  <full task text>

02_RESULTS
  ACKs and results, appended by the executor as separate blocks:
  [SubtaskID] ACK ReadAt=<timestamp> RunID=<id>
  [SubtaskID] DONE <result summary + deliverable location>
  [SubtaskID] BLOCKED <reason>

03_FEEDBACK
  Requester's verification notes and CLOSE records:
  [SubtaskID] CLOSE Verdict=<PASS|FAIL> <verification notes>

04_CLOSED
  One-line index entries only (SubtaskID + close date + verdict).
  Original blocks are never moved — closing is an appended record,
  not a relocation.
```

Rules:

- Append only. Never edit, move, or delete another participant's blocks.
- ACK, RESULT, and CLOSE are separate blocks — never merged into one entry.
- One SubtaskID namespace per executor family (e.g. a prefix per task type).
- A scheduled executor that finds no QUEUED task in its namespace writes a single `NO_TASK` heartbeat line — and nothing else.
