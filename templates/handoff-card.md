# Handoff Card (one-shot dispatch)

For direct dispatch into a live agent session (no mailbox), keep the card self-contained:

```
HANDOVER <ID> — <one-line title>

Executor: <who runs this>
Deliverable: <what comes back, and where it is written>

Background:
<Only the facts the executor needs. No chat-history references.>

Steps:
1. <step>
2. <step>

Hard boundaries:
- <what must never be done; gate-list actions stop and report>

Receipt:
Write the receipt to <location> with: ID, status, evidence, blockers.
```

Rules:

- One card = one outcome. Split multi-outcome work into multiple cards.
- The receipt location is agreed before dispatch, and the card is not "done" until the receipt exists there.
- Chat is for triggering and acceptance only — the card and the receipt are the record.
