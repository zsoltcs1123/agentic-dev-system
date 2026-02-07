---
name: sync-tasks
description: Parses a phase file and pushes all tasks to the configured project tracker. Use when asked to "sync tasks", "push phase to tracker", or after running phase-breakdown. Creates local task folders and state files.
metadata:
  version: "0.2.0"
---

# Sync Tasks

Initializes tasks from a phase file both locally and in the configured project tracker.

## When to Use

- User asks to "sync tasks for phase X" or "push phase tasks to tracker"
- After running phase-breakdown to populate a phase file

## Input

- Phase file path (e.g., `.agents/artifacts/phases/phase-01-core/phase.md`)

## Procedure

1. **Read config**: Get active tracker adapter from `.agents/config.json`
2. **Load adapter**: If adapter is not `none`, read from `adapters/{adapter-name}.md`
3. **Parse phase path**: Extract phase folder (e.g., `phase-01-core`)
4. **Parse phase file**: Find task entries (`### pXX-task-XXX: {title}`)
5. **For each task**:
   - Create `{phase-folder}/tasks/{task-id}/` folder if missing
   - Create `{task-id}-state.json` with state PENDING (skip if exists)
   - If adapter configured: create item using adapter's **Create Item** operation
   - Store tracker item ID in `state.json` under `trackerId`
6. **Report summary**: Tasks created locally, pushed to tracker, skipped

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

Skip tasks that already have a local folder or `trackerId`. Safe to re-run after adding new tasks to a phase file.

## Adapter

Uses project tracker adapter. See `adapters/_template.md` for interface.
