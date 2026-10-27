# Multi-Agent Mailbox Protocol

**English** | [简体中文](README.zh-CN.md)

A lightweight protocol for handing tasks between AI agents that **do not share memory, context, or a runtime** — using nothing but shared files.

No server. No SDK. No message queue. If two agents can both read and write the same folder (a cloud drive, a shared document, a git repository), they can coordinate work with this protocol.

> For coordinators and agents that share no memory, no context, and no runtime — and can only pass work to each other through shared files. Every dispatch still gets a verifiable receipt back.

## Why a mailbox?

Most multi-agent demos assume a framework: one runtime, one orchestrator, shared state. Real life is messier:

- Your agents live in **different products** with different accounts.
- Some can only be reached through a **document** or a **chat window**.
- Some wake up on a **schedule**, not on a push notification.
- A few steps (logins, payments, publishing) must stay **behind a human gate**.

A file mailbox is the lowest common denominator that works across all of them. It is slow by design — and that is fine, because the work it carries (research, drafting, analysis, batch execution) is asynchronous anyway.

## The three channels

The protocol is transport-agnostic. Three transports are specified:

| Channel | Transport | Best for |
|---|---|---|
| **Folder mailbox** | A shared cloud-drive folder; one file per message | Coordinator ↔ chat-model research and analysis |
| **Partitioned document mailbox** | One shared document with numbered sections (inbox / results / feedback / closed) | Agents reachable only through a docs connector |
| **Git mailbox** | A private repository; messages as committed files, tasks as issues | Coding agents that already live on a forge |

An optional **notification sentinel** (e.g. a mail watcher) can sit beside any channel and ping the coordinator when a receipt lands, so humans don't have to poll dashboards.

## Core ideas

1. **One message = one file, never edited.** REQUEST, ACK, RESULT and CLOSE are separate files that reference the same TaskID.
2. **Every task has an ID and a lifecycle.** `QUEUED → ACKED → DONE → CLOSED` (with BLOCKED and requeue branches — see PROTOCOL §4/§6). An ACK is only a claim — a task counts as done when the requester verifies the evidence and closes it with PASS.
3. **Scope is written on the envelope.** Each task declares what it may touch, what is already authorized, and what stops at a **human gate** (logins, installs, payments, publishing, business writes, sensitive data).
4. **Receipts over claims.** A result counts when its RESULT file exists: what was done, when, by whom, with what evidence.
5. **Polling is a feature.** A fixed polling interval (e.g. every 15 minutes) keeps every participant's behaviour predictable and auditable. Latency-sensitive work does not belong in a mailbox; use a live session instead.

Full specification: [PROTOCOL.md](PROTOCOL.md). Templates: [`templates/`](templates/). A complete worked example: [`examples/`](examples/).

## Quick start

1. Create a shared folder (or document, or private repo) that all participating agents can access.
2. Agree on the envelope format and lifecycle in [PROTOCOL.md](PROTOCOL.md).
3. Drop a task file written from [`templates/REQUEST.template.md`](templates/REQUEST.template.md) into the mailbox.
4. The receiving agent polls, ACKs, executes, and writes a RESULT file with the same TaskID.
5. The requester verifies the evidence and writes a CLOSE file with verdict PASS or FAIL.

Before pushing anything to a public copy of a mailbox, run the sanity scan: `bash scripts/check-secrets.sh`.

## What this is not

- Not a real-time bus. If you need sub-minute coordination, use an API or a shared runtime.
- Not a security boundary. Anyone with write access to the mailbox can inject tasks — keep the mailbox private and the human gate list short and explicit.
- Not a replacement for judgment. The protocol moves tasks; people still decide what is worth doing.

## License

MIT — see [LICENSE](LICENSE).
