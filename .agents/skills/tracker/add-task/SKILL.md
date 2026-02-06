---
name: add-task
description: Adds a single new task to local artifacts and the configured project tracker.
version: 0.1.0
---

# Add Task

Creates a new task locally and pushes it to the project tracker.

## Trigger

Use when:

- User asks to "add a task" or "create task-XXX"
- A new task is identified mid-phase that wasn't in the original breakdown

## Input

- Task ID, title, description
- Optional: phase file to append to

## Output

- Local `task-{id}/` folder with `task-{id}-state.json`
- Task created in project tracker (if adapter configured)
- Task appended to phase file (if provided)

## Procedure

1. Read `.agents/config.json` to get the active tracker adapter name
2. If adapter is not `none`, read the adapter file from `adapters/{adapter-name}.md`
3. Create `.agents/artifacts/tasks/task-{id}/` folder
4. Create `task-{id}-state.json` with state PENDING
5. If phase file provided: append task entry to the phase file
6. If adapter configured: create item in tracker using the adapter's **Create Item** operation
7. Store the tracker item ID in `state.json` under `trackerId`

## Adapter

This skill uses a project tracker adapter. See `adapters/_template.md` for the interface.
