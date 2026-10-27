# Partitioned Document Mailbox — Layout

Use this layout when the only surface shared by two agents is a single document.

```
01_PENDING
  Tasks waiting to be claimed. Each task is one block:
  [SubtaskID] [QUEUED] <one-line summary>
  <full task text>

02_RESULTS
  ACK lines and results, appended by the executor:
  [SubtaskID] ACK ReadAt=<timestamp> RunID=<id>
  [SubtaskID] DONE <result summary + deliverable location>

03_FEEDBACK
  Requester's verification notes and follow-ups, per SubtaskID.

04_CLOSED
  Closed tasks, moved here by the requester only, with the closing date.
```

Rules:

- Append only. Never edit or delete another participant's blocks.
- One SubtaskID namespace per executor family (e.g. a prefix per task type).
- A scheduled executor that finds no QUEUED task in its namespace writes a single `NO_TASK` heartbeat line — and nothing else.
- The requester verifies results in 03 before moving anything to 04.
