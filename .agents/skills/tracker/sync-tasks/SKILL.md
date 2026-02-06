---
name: sync-tasks
description: Parses a phase file and pushes all tasks to the configured project tracker. Creates local task folders and state files.
version: 0.1.0
---

# Sync Tasks

Initializes tasks from a phase file both locally and in the configured project tracker.

## Trigger

Use when:

- User asks to "sync tasks for phase X" or "push phase tasks to tracker"
- After running phase-breakdown to populate a phase file

## Input

- Phase file path (e.g. `.agents/artifacts/phases/phase-01-core.md`)

## Output

- Local `task-{id}/` folders with `task-{id}-state.json` for each task
- Tasks created in the project tracker (if adapter configured)
- Summary of tasks created

## Procedure

1. Read `.agents/config.json` to get the active tracker adapter name
2. If adapter is not `none`, read the adapter file from `adapters/{adapter-name}.md`
3. Parse the phase file for task entries (`### task-XXX: {title}`)
4. For each task:
   a. Create `.agents/artifacts/tasks/task-{id}/` folder if it doesn't exist
   b. Create `task-{id}-state.json` with state PENDING (skip if already exists)
   c. If adapter configured: create item in tracker using the adapter's **Create Item** operation
   d. Store the tracker item ID in `state.json` under `trackerId`
5. Report summary: tasks created locally, tasks pushed to tracker, tasks skipped (already existed)

## Idempotency

Skip tasks that already have a `trackerId` in state.json. This makes it safe to re-run after adding new tasks to a phase file.

## Adapter

This skill uses a project tracker adapter. See `adapters/_template.md` for the interface.
