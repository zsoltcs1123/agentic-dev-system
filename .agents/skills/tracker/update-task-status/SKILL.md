---
name: update-task-status
description: Syncs local task state to the configured project tracker. Use when asked to "sync status", "update tracker", or after task state changes. Supports single task or bulk sync.
metadata:
  version: "0.2.0"
---

# Update Task Status

Pushes local task state changes to the project tracker.

## When to Use

- User asks to "sync task status" or "update tracker for pXX-task-XXX"
- After state transitions in dev-cycle
- Periodic sync to keep tracker current

## Input

- Task ID (phase-prefixed, e.g., `p01-task-001`), or "all" to sync all tasks

## Procedure

1. **Read config**: Get active tracker adapter from `.agents/config.json`
2. **Check adapter**: If `none`, skip (no tracker configured)
3. **Load adapter**: Read from `adapters/{adapter-name}.md`
4. **Locate task(s)**:
   - Single task: Extract phase from ID prefix → find phase folder → read state.json
   - "all": Discover all phase folders → discover all task folders
5. **For each task with `trackerId`**:
   - Read current state from `state.json`
   - Update tracker using adapter's **Update Item Status** operation

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

Uses project tracker adapter. See `adapters/_template.md` for interface.
