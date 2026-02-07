---
name: add-task
description: Adds a single new task to a phase. Use when asked to "add task to phase X", "create a new task", or when a task is identified mid-phase. Creates local artifacts and pushes to tracker.
metadata:
  version: "0.2.0"
---

# Add Task

Creates a new task locally and pushes it to the project tracker.

## When to Use

- User asks to "add a task to phase X" or "create pXX-task-XXX"
- A new task is identified mid-phase that wasn't in the original breakdown

## Input

- Phase folder path (e.g., `.agents/artifacts/phases/phase-01-core/`) **required**
- Task title and description
- Task number (auto-increment if not provided)

## Procedure

1. **Read config**: Get active tracker adapter from `.agents/config.json`
2. **Load adapter**: If adapter is not `none`, read from `adapters/{adapter-name}.md`
3. **Extract phase number** from folder name (e.g., `phase-01-core` → `01`)
4. **Determine next task number**:
   - List existing tasks in `{phase-folder}/tasks/`
   - Find highest number and increment
5. **Generate task ID**: `p{phase-number}-task-{task-number}` (e.g., `p01-task-003`)
6. **Create folder**: `{phase-folder}/tasks/{task-id}/`
7. **Create state file**: `{task-id}-state.json` with state PENDING
8. **Append to phase.md**: Add task entry to `{phase-folder}/phase.md`
9. **Push to tracker**: If adapter configured, create item using **Create Item** operation
10. **Store tracker ID** in `state.json` under `trackerId`

## Task ID Format

| Phase   | Task ID Format | Example        |
| ------- | -------------- | -------------- |
| Phase 1 | `p01-task-XXX` | `p01-task-001` |
| Phase 2 | `p02-task-XXX` | `p02-task-003` |

## Adapter

Uses project tracker adapter. See `adapters/_template.md` for interface.
