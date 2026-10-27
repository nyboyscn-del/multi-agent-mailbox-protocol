# Task Request

TaskID: <YYYYMMDD>-<NNN>
From: <requester role>
To: <executor role>
Created: <ISO-8601 with timezone>
Scope: <what the executor may read / write / decide>
StandingAuth: <actions already authorized for this executor, or none>
HumanGate: <none | list of actions needing human approval>
RunLocation: <where the executor runs — session / project / host class>
Deliverable: <exact artifact expected back, format and location>
Evidence: <where evidence must be written>
Deadline: <optional>

## Task

<Plain-language task description. Include ALL context the executor needs inside this file — the executor cannot see your chat history or other tasks.>

## Acceptance criteria

- <criterion 1>
- <criterion 2>

## Out of scope

- <anything explicitly not to be done>
