---
name: sync-tasks
description: Parses a phase file and pushes all tasks to the configured project tracker. Creates local task folders and state files inside the phase folder.
version: 0.2.0
---

# Sync Tasks

Initializes tasks from a phase file both locally and in the configured project tracker.

## Trigger

Use when:

- User asks to "sync tasks for phase X" or "push phase tasks to tracker"
- After running phase-breakdown to populate a phase file

## Input

- Phase file path (e.g., `.agents/artifacts/phases/phase-01-core/phase.md`)

## Output

- Local `tasks/{task-id}/` folders inside the phase folder
- `{task-id}-state.json` for each task
- Tasks created in the project tracker (if adapter configured)
- Summary of tasks created

## Procedure

1. Read `.agents/config.json` to get the active tracker adapter name
2. If adapter is not `none`, read the adapter file from `adapters/{adapter-name}.md`
3. Parse the phase file path to extract phase folder (e.g., `phase-01-core`)
4. Parse the phase file for task entries (`### pXX-task-XXX: {title}`)
5. For each task:
   a. Create `{phase-folder}/tasks/{task-id}/` folder if it doesn't exist
   b. Create `{task-id}-state.json` with state PENDING and `phase` field (skip if already exists)
   c. If adapter configured: create item in tracker using the adapter's **Create Item** operation
   d. Store the tracker item ID in `state.json` under `trackerId`
6. Report summary: tasks created locally, tasks pushed to tracker, tasks skipped (already existed)

## State File Format

```json
{
  "id": "p01-task-001",
  "description": "Task description",
  "phase": "phase-01-core",
  "trackerId": null,
  "state": "PENDING",
  "stateHistory": [{ "state": "PENDING", "timestamp": "..." }],
  "commits": [],
  "failures": []
}
```

## Idempotency

Skip tasks that already have a `trackerId` in state.json. This makes it safe to re-run after adding new tasks to a phase file.

## Adapter

This skill uses a project tracker adapter. See `adapters/_template.md` for the interface.
