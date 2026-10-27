# Task ACK

TaskID: <same as REQUEST>
From: <executor role>
To: <requester role>
ReadAt: <ISO-8601 with timezone, when the task was claimed>
RunID: <session / run identifier if the platform provides one>

Claimed. Execution starts under the REQUEST's Scope.
(An ACK is a claim receipt only — it is not a result.)
