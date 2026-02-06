---
name: update-task-status
description: Syncs local task state to the configured project tracker.
version: 0.1.0
---

# Update Task Status

Pushes local task state changes to the project tracker.

## Trigger

Use when:

- User asks to "sync task status" or "update tracker for task-XXX"
- Optionally called by dev-cycle after each state transition

## Input

- Task ID, or "all" to sync all tasks

## Output

- Tracker items updated to match local state

## Procedure

1. Read `.agents/config.json` to get the active tracker adapter name
2. If adapter is `none`, skip (no tracker configured)
3. Read the adapter file from `adapters/{adapter-name}.md`
4. If single task: read `.agents/artifacts/tasks/task-{id}/task-{id}-state.json`
5. If "all": discover all task folders in `.agents/artifacts/tasks/`
6. For each task with a `trackerId`:
   a. Read current state from `state.json`
   b. Update tracker item status using the adapter's **Update Item Status** operation

## Adapter

This skill uses a project tracker adapter. See `adapters/_template.md` for the interface.
