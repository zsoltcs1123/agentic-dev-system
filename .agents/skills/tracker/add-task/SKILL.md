---
name: add-task
description: Adds a single new task to local artifacts and the configured project tracker. Requires a phase context.
version: 0.2.0
---

# Add Task

Creates a new task locally and pushes it to the project tracker.

## Trigger

Use when:

- User asks to "add a task to phase X" or "create pXX-task-XXX"
- A new task is identified mid-phase that wasn't in the original breakdown

## Input

- Phase folder path (e.g., `.agents/artifacts/phases/phase-01-core/`) **required**
- Task title and description
- Task number (auto-increment if not provided)

## Output

- Local `tasks/{task-id}/` folder inside the phase folder
- `{task-id}-state.json` with state PENDING
- Task created in project tracker (if adapter configured)
- Task appended to phase.md

## Procedure

1. Read `.agents/config.json` to get the active tracker adapter name
2. If adapter is not `none`, read the adapter file from `adapters/{adapter-name}.md`
3. Extract phase number from folder name (e.g., `phase-01-core` → `01`)
4. Determine next task number:
   - List existing tasks in `{phase-folder}/tasks/`
   - Find highest task number and increment
5. Generate task ID: `p{phase-number}-task-{task-number}` (e.g., `p01-task-003`)
6. Create `{phase-folder}/tasks/{task-id}/` folder
7. Create `{task-id}-state.json` with state PENDING and `phase` field
8. Append task entry to `{phase-folder}/phase.md`
9. If adapter configured: create item in tracker using the adapter's **Create Item** operation
10. Store the tracker item ID in `state.json` under `trackerId`

## Task ID Format

Task IDs are phase-prefixed to prevent collisions:

| Phase   | Task ID Format | Example        |
| ------- | -------------- | -------------- |
| Phase 1 | `p01-task-XXX` | `p01-task-001` |
| Phase 2 | `p02-task-XXX` | `p02-task-003` |

## Adapter

This skill uses a project tracker adapter. See `adapters/_template.md` for the interface.
