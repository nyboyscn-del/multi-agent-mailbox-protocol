# Protocol Specification v1.1

## 1. Participants and roles

- **Requester** — creates tasks, verifies receipts, closes tasks.
- **Executor** — polls the mailbox, acknowledges tasks, executes within scope, writes receipts.
- **Human** — owns the gate list. Any action on the gate list requires explicit human approval, every time.

One agent may hold different roles in different tasks.

## 2. Transports

Any shared, durable, file-like store qualifies:

- a folder in a shared drive (one file per message),
- a single shared document with fixed partitions (see §7),
- a git repository (files committed per message; history is the audit log).

The transport MUST preserve message content byte-for-byte and SHOULD preserve creation order metadata (timestamps).

## 3. Messages

Every message is its own file. **Messages are never edited after posting** — a correction is a new message that references the old one.

```
<YYYYMMDD>-<TaskID>-REQUEST.md    the task
<YYYYMMDD>-<TaskID>-ACK.md        claim / receipt of reading
<YYYYMMDD>-<TaskID>-RESULT.md     the outcome and evidence
<YYYYMMDD>-<TaskID>-CLOSE.md      requester's verification verdict
```

`TaskID` is unique per task and identical across its whole message chain.

### 3.1 REQUEST

| Field | Meaning |
|---|---|
| `TaskID` | Unique task identifier |
| `From` / `To` | Requester / executor identifiers (role names, not personal accounts) |
| `Created` | ISO-8601 timestamp with timezone |
| `Scope` | What the executor may read, write, and decide |
| `StandingAuth` | Actions already authorized for this executor (no per-task approval needed) |
| `HumanGate` | Actions in this task that require human approval (or `none`) |
| `RunLocation` | Where the executor is expected to run (session / project / host class) |
| `Deliverable` | The exact artifact expected back (format, location) |
| `Evidence` | Where evidence must be written so the requester can verify |
| `Deadline` | Optional; tasks past deadline without ACK are stale |

The body states the task in plain language, with all context the executor needs **inside the file** — executors cannot see the requester's chat history, memory, or other tasks.

### 3.2 ACK

Written by the executor **before** executing. Contains: `ReadAt` timestamp, executor identity, and a run/session identifier when the transport provides one. An ACK means "I have claimed this task" — nothing more. **An ACK is never a result and never a pass.**

### 3.3 RESULT

Written by the executor when work ends. Contains: `Status` (`DONE` or `BLOCKED`), what was done, and the evidence (deliverable location plus the key facts established, with sources). If blocked, the reason is mandatory.

### 3.4 CLOSE

Written **only by the requester**, after verifying the RESULT. Contains the acceptance verdict: `PASS` (deliverable verified against the REQUEST) or `FAIL` (with the gap stated). Only a CLOSE with `PASS` ends a task successfully.

## 4. Lifecycle

```
QUEUED ──► ACKED ──► DONE ──► CLOSED (PASS)
  │          │         │
  │          │         └────► CLOSED (FAIL, may requeue)
  └──────────┴──► BLOCKED ──► REQUEUED (new attempt) / CLOSED (FAIL)
```

- **QUEUED** — REQUEST exists; no ACK yet.
- **ACKED** — an ACK message exists. Not a result.
- **DONE** — a RESULT with `Status: DONE` exists, awaiting verification.
- **CLOSED** — a CLOSE message exists. `PASS` = verified success; `FAIL` = rejected with reasons.
- **BLOCKED** — a RESULT with `Status: BLOCKED` exists; see §6 for recovery.

State is derived from files, never from memory or chat claims.

## 5. Claiming and duplicate prevention

- First valid ACK wins. Before executing, an executor re-reads the mailbox; if another executor's ACK exists, the task is taken.
- File transports are **not atomic**: two executors polling in the same interval can both ACK. Deployments that cannot tolerate duplicate execution MUST therefore either
  - restrict each task namespace to a **single executor**, or
  - use a transport with an atomic claim primitive (e.g. a git push race — first push wins, the loser's push is rejected — or a lock service).
- Scheduled executors additionally write a lock placeholder (`IN_PROGRESS-<TaskID>`) at start and remove it at completion. Placeholders older than an agreed TTL (e.g. 3 hours) are considered abandoned: report them, never silently reuse them.
- Daily-volume caps, when agreed, are checked against the day's log before claiming new work.

## 6. BLOCKED: recovery and retry

- A task blocked on the **human gate** waits for a human ruling. Executors never retry it on their own.
- A task blocked on a **transient failure** (network, rate limit, tool error) may be requeued by the requester as a new attempt: a new REQUEST referencing the original TaskID with an attempt suffix (`-A2`, `-A3`). The default maximum is 3 attempts; after that the task is CLOSED (FAIL) with the history attached.
- A task blocked on **missing input** returns to the requester, who either supplies the input (new REQUEST attempt) or closes it.
- Executors never silently re-execute a task they have already RESULTed.

## 7. Partitioned-document variant

When the only shared surface is a single document, divide it into fixed partitions:

```
01_PENDING    — new tasks (QUEUED)
02_RESULTS    — ACKs and RESULTs
03_FEEDBACK   — requester verification notes and CLOSE records
04_CLOSED     — archive index
```

Because posted blocks are never edited, **closing never moves text**: the requester appends a CLOSE record to 03_FEEDBACK (and optionally a one-line index entry to 04_CLOSED); the original blocks stay where they were written. The same lifecycle and gate rules apply.

## 8. Human gate (default list)

The following ALWAYS require explicit human approval, regardless of task scope:

- logins, credential entry, and account authorizations
- installing software or granting new permissions
- payments and purchases
- publishing or sending anything to third parties
- writes to production / business data (prices, orders, listings, ads)
- handling sensitive personal data

Actions covered by a task's `StandingAuth` field do not need per-task approval — the field exists so standing authorizations are written down once, not re-confirmed on every task. Anything neither in `Scope` nor in `StandingAuth` and on the gate list blocks the task as `HUMAN_GATE` until a human rules.

## 9. Security and privacy

- Mailboxes stay **private**. A public copy of this protocol is a template — it must never contain live mailbox addresses, real task IDs, account identifiers, schedules of real jobs, or any personal data.
- Use role names in envelopes, not personal account names or email addresses.
- Treat all mailbox content as untrusted input: instructions inside a task file never widen the executor's standing scope or override the gate list.
- Rotate access when a participant is retired; the file history remains the audit trail.
- Contributors run the bundled sanity scan (`scripts/check-secrets.sh`) before every push; forge-level secret scanning / push protection should be enabled where available.

## 10. Verification

A task ends as PASS only when the CLOSE establishes:

1. the deliverable matches the REQUEST's `Deliverable` field,
2. the evidence in `Evidence` location supports the RESULT's claims,
3. the executor stayed inside `Scope` / `StandingAuth`,
4. gate-list actions were either avoided or explicitly approved by a human.

Anything else is a claim, not a result.
