---
name: create-task
description: Creates a standardized task from any input. Use when asked to "create task", "add task", or when importing tasks. Outputs state.json and appends to phase.md.
metadata:
  version: "0.1.0"
---

# Create Task

Creates a standardized task from various input sources.

## When to Use

- User asks to "create task" or "add task"
- Importing tasks from external sources

## When NOT to Use

- Deep task analysis or implementation planning → use `plan-task`
- Updating existing task state → modify state.json directly

## Input

- Task description (freeform prompt, structured data, or external source)
- Phase identifier (folder name or number)
- Optional: priority (`low`, `medium`, `high`), dependencies (list of task IDs)

## Procedure

1. **Parse input**: Extract task info from prompt or structured input
2. **Enrich if needed**: If input is vague:
   - Light codebase scan to gather context (relevant files, existing patterns)
   - Only enough to write a clear description — no deep analysis (that's `plan-task`'s job)
   - If still unclear, ask user to clarify
3. **Determine phase**: From input or ask user
4. **Generate task ID**: Find next available `p{phase}-task-XXX` in the phase folder
5. **Build task object**: Map input to fields from `.agents/config.json`
6. **Create artifacts**:
   - Task folder: `.agents/artifacts/phases/{phase}/tasks/{task-id}/`
   - State file: `{task-id}-state.json`
   - Append entry to `{phase}/phase.md`

## Task ID Generation

Scan existing task folders in the phase to find the next available number:

```
.agents/artifacts/phases/phase-01-core/tasks/
├── p01-task-001/
├── p01-task-002/
└── p01-task-003/
→ Next ID: p01-task-004
```

## State File Format

Fields are defined in `.agents/config.json`. Default structure:

```json
{
  "id": "p01-task-001",
  "description": "Task description",
  "phase": "phase-01-core",
  "state": "PENDING",
  "priority": "medium",
  "stateHistory": [{ "state": "PENDING", "timestamp": "2024-01-15T10:00:00Z" }],
  "commits": [],
  "failures": []
}
```

## Phase.md Entry Format

Append to the Tasks section:

```markdown
### p01-task-001: {title}

{description}
Dependencies: none
```

## Error Handling

- Phase not found → ask user to specify or create phase first
- Ambiguous input → ask user to clarify before creating

## Guidelines

- Keep descriptions actionable and specific
- Default state is always `PENDING`
- Default priority is `medium` unless specified
- Do not perform deep analysis — that's `plan-task`'s responsibility
