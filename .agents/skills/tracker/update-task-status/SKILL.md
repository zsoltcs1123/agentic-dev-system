---
name: update-task-status
description: Syncs local task state to the configured project tracker.
version: 0.2.0
---

# Update Task Status

Pushes local task state changes to the project tracker.

## Trigger

Use when:

- User asks to "sync task status" or "update tracker for pXX-task-XXX"
- Optionally called by dev-cycle after each state transition

## Input

- Task ID (phase-prefixed, e.g., `p01-task-001`), or "all" to sync all tasks

## Output

- Tracker items updated to match local state

## Procedure

1. Read `.agents/config.json` to get the active tracker adapter name
2. If adapter is `none`, skip (no tracker configured)
3. Read the adapter file from `adapters/{adapter-name}.md`
4. **Locate task(s)**:
   - If single task: extract phase from task ID prefix (e.g., `p01-task-001` → phase `01`)
     - Find phase folder: `.agents/artifacts/phases/phase-{number}-*/`
     - Read `{phase-folder}/tasks/{task-id}/{task-id}-state.json`
   - If "all": discover all phase folders in `.agents/artifacts/phases/`
     - For each phase, discover all task folders in `{phase-folder}/tasks/`
5. For each task with a `trackerId`:
   a. Read current state from `state.json`
   b. Update tracker item status using the adapter's **Update Item Status** operation

## Task Discovery

Tasks are nested inside phase folders:

```
.agents/artifacts/phases/
├── phase-01-core/
│   └── tasks/
│       ├── p01-task-001/
│       └── p01-task-002/
└── phase-02-features/
    └── tasks/
        └── p02-task-001/
```

## Adapter

This skill uses a project tracker adapter. See `adapters/_template.md` for the interface.
